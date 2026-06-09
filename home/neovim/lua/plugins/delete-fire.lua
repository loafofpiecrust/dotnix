-- Burn with animated fire when text is deleted!!
local particles = {}
local timer = nil
local attached_bufs = {}
local MAX_PARTICLES = 80
local FRAME_MS = 16
local DELETE_THRESHOLD = 8        -- minimum bytes deleted to trigger fire
local DELETE_THRESHOLD_MAX = 1000 -- maximum bytes deleted to trigger fire

local fire_chars = { "█", "▓", "▒", "░", "●", "•", "·" }
local fire_colors = {
  "#FFFF66",
  "#FFEE33",
  "#FFCC00",
  "#FFAA00",
  "#FF8800",
  "#FF6600",
  "#FF4400",
  "#EE2200",
  "#CC1100",
  "#991100",
  "#661100",
}

local function setup_highlights()
  for i, color in ipairs(fire_colors) do
    vim.api.nvim_set_hl(0, "DeleteFire" .. i, { fg = color, bg = "NONE" })
  end
end

local function close_particle(p)
  if p.win then
    pcall(vim.api.nvim_win_close, p.win, true)
    p.win = nil
  end
  if p.buf then
    pcall(vim.api.nvim_buf_delete, p.buf, { force = true })
    p.buf = nil
  end
end

local function spawn_particle(screen_row, screen_col, col_spread)
  if #particles >= MAX_PARTICLES then return end

  local angle = (math.random() * 0.6 + 0.2) * math.pi
  local speed = math.random() * 8 + 4
  table.insert(particles, {
    x = screen_col + math.random() * math.max(col_spread, 1),
    y = screen_row + (math.random() - 0.5) * 0.5,
    vx = math.cos(angle) * speed * (math.random() > 0.5 and 1 or -1),
    vy = -math.abs(math.sin(angle)) * speed,
    lifetime = math.random() * 500 + 300,
    age = 0,
    win = nil,
    buf = nil,
  })
end

local function render_particle(p)
  local progress = math.min(p.age / p.lifetime, 1.0)

  local char_idx = math.floor(progress * (#fire_chars - 1)) + 1
  local color_idx = math.floor(progress * (#fire_colors - 1)) + 1
  local char = fire_chars[math.min(char_idx, #fire_chars)]
  local hl = "DeleteFire" .. math.min(color_idx, #fire_colors)

  local row = math.floor(p.y + 0.5)
  local col = math.floor(p.x + 0.5)

  if row < 0 or row >= vim.o.lines - 1 or col < 0 or col >= vim.o.columns then
    return false
  end

  if not p.buf or not vim.api.nvim_buf_is_valid(p.buf) then
    p.buf = vim.api.nvim_create_buf(false, true)
    if not p.buf then return false end
    vim.bo[p.buf].bufhidden = "wipe"
  end

  pcall(vim.api.nvim_buf_set_lines, p.buf, 0, -1, false, { char })

  local win_cfg = {
    relative = "editor",
    row = row,
    col = col,
    width = 1,
    height = 1,
    style = "minimal",
    focusable = false,
    noautocmd = true,
    zindex = 300,
  }

  if p.win and vim.api.nvim_win_is_valid(p.win) then
    local ok = pcall(vim.api.nvim_win_set_config, p.win, win_cfg)
    if not ok then return false end
  else
    local ok, win = pcall(vim.api.nvim_open_win, p.buf, false, win_cfg)
    if not ok then return false end
    p.win = win
  end

  if p.win and vim.api.nvim_win_is_valid(p.win) then
    pcall(vim.api.nvim_set_option_value, "winhl", "Normal:" .. hl, { win = p.win })
    pcall(vim.api.nvim_set_option_value, "winblend", math.floor(progress * 70), { win = p.win })
  end

  return true
end

local function update_particles()
  local dt = FRAME_MS / 1000.0
  local alive = {}

  for _, p in ipairs(particles) do
    p.age = p.age + FRAME_MS
    if p.age >= p.lifetime then
      close_particle(p)
    else
      p.vy = p.vy - 30 * dt
      p.vx = p.vx * 0.96
      p.x = p.x + p.vx * dt
      p.y = p.y + p.vy * dt

      if render_particle(p) then
        table.insert(alive, p)
      else
        close_particle(p)
      end
    end
  end

  particles = alive

  if #particles == 0 and timer then
    timer:stop()
    timer = nil
  end
end

local function start_timer()
  if timer then return end
  timer = vim.uv.new_timer()
  timer:start(0, FRAME_MS, vim.schedule_wrap(update_particles))
end

local function on_text_deleted(deleted_bytes, buf, start_row, start_col, old_end_row, old_end_col)
  if buf ~= vim.api.nvim_get_current_buf() then return end
  if not vim.api.nvim_buf_is_valid(buf) or vim.bo[buf].buftype ~= "" then return end

  local winid = vim.fn.bufwinid(buf)
  if winid < 0 then return end

  local pos = vim.fn.screenpos(winid, start_row + 1, math.max(start_col, 0) + 1)
  if pos.row == 0 then return end

  local screen_row = pos.row - 1
  local screen_col = pos.col - 1

  local col_spread
  if old_end_row > 0 then
    col_spread = math.min(vim.api.nvim_win_get_width(winid) - start_col, 40)
  else
    col_spread = math.max(old_end_col, 1)
  end

  local count = math.min(math.max(deleted_bytes * 3, 6), 45)
  count = math.min(count, MAX_PARTICLES - #particles)

  for _ = 1, count do
    spawn_particle(screen_row, screen_col, col_spread)
  end

  start_timer()
end

local function attach_buffer(buf)
  if attached_bufs[buf] then return end
  if not vim.api.nvim_buf_is_valid(buf) then return end
  if vim.bo[buf].buftype ~= "" then return end

  attached_bufs[buf] = true

  vim.api.nvim_buf_attach(buf, false, {
    on_bytes = function(_, b, _, sr, sc, _, oer, oec, oeb, _, _, neb)
      if oeb - neb >= DELETE_THRESHOLD and oeb - neb < DELETE_THRESHOLD_MAX then
        vim.schedule(function()
          on_text_deleted(oeb - neb, b, sr, sc, oer, oec)
        end)
      end
    end,
    on_detach = function(_, b)
      attached_bufs[b] = nil
    end,
  })
end

local function setup()
  setup_highlights()

  vim.api.nvim_create_autocmd("ColorScheme", {
    group = vim.api.nvim_create_augroup("DeleteFireColors", { clear = true }),
    callback = setup_highlights,
  })

  local group = vim.api.nvim_create_augroup("DeleteFire", { clear = true })

  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) then
      attach_buffer(buf)
    end
  end

  vim.api.nvim_create_autocmd("BufEnter", {
    group = group,
    callback = function(args)
      attach_buffer(args.buf)
    end,
  })
end

setup()
