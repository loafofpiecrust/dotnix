-- Eager plugins that just need setup() called

require("gitsigns").setup({
  signs = {
    add = { text = "▎" },
    change = { text = "▎" },
    delete = { text = "" },
    topdelete = { text = "" },
    changedelete = { text = "▎" },
    untracked = { text = "▎" },
  },
  on_attach = function(buffer)
    local gs = package.loaded.gitsigns
    local function map(mode, l, r, desc)
      vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
    end
    map("n", "]h", function()
      gs.nav_hunk("next")
    end, "Next hunk")
    map("n", "[h", function()
      gs.nav_hunk("prev")
    end, "Prev hunk")
    map({ "n", "v" }, "<leader>ghs", ":Gitsigns stage_hunk<CR>", "Stage hunk")
    map({ "n", "v" }, "<leader>ghr", ":Gitsigns reset_hunk<CR>", "Reset hunk")
    map("n", "<leader>ghS", gs.stage_buffer, "Stage buffer")
    map("n", "<leader>ghu", gs.undo_stage_hunk, "Undo stage hunk")
    map("n", "<leader>ghR", gs.reset_buffer, "Reset buffer")
    map("n", "<leader>ghp", gs.preview_hunk_inline, "Preview hunk inline")
    map("n", "<leader>ghb", function()
      gs.blame_line({ full = true })
    end, "Blame line")
  end,
})

require("todo-comments").setup({})

require("yanky").setup({
  highlight = { timer = 200 },
})
vim.keymap.set({ "n", "x" }, "p", "<Plug>(YankyPutAfter)")
vim.keymap.set({ "n", "x" }, "P", "<Plug>(YankyPutBefore)")
vim.keymap.set("n", "<c-p>", "<Plug>(YankyPreviousEntry)")
vim.keymap.set("n", "<c-n>", "<Plug>(YankyNextEntry)")

require("mini.ai").setup({})
require("mini.pairs").setup({})
require("mini.files").setup({
  mappings = {
    go_in = "l",
    -- go_in_plus = "<CR>",
    go_out = "h",
    go_out_plus = "H",
    synchronize = "=",
  },
})

-- Auto-sync and open file on Enter (so new files get created without extra confirmation)
vim.api.nvim_create_autocmd("User", {
  pattern = "MiniFilesBufferCreate",
  callback = function(args)
    local buf = args.data.buf_id

    vim.keymap.set("n", "<CR>", function()
      local files = require("mini.files")
      files.synchronize()
      files.go_in({ close_on_file = true })
    end, { buffer = buf })

    -- Show file info on gi
    vim.keymap.set("n", "gi", function()
      local entry = require("mini.files").get_fs_entry()
      if not entry then
        return
      end
      local stat = vim.uv.fs_stat(entry.path)
      if not stat then
        return
      end
      local size = stat.size < 1024 and stat.size .. "B"
        or stat.size < 1048576 and string.format("%.1fK", stat.size / 1024)
        or string.format("%.1fM", stat.size / 1048576)
      local perms = string.format("%o", stat.mode % 4096)
      Snacks.notifier.notify(
        string.format("%s  %s  %s", os.date("%Y-%m-%d %H:%M", stat.mtime.sec), size, perms),
        "info",
        { title = entry.name, timeout = 5000 }
      )
    end, { buffer = buf, desc = "File info" })

    -- Interactive chmod on gx
    vim.keymap.set("n", "gx", function()
      local entry = require("mini.files").get_fs_entry()
      if not entry then
        return
      end
      local stat = vim.uv.fs_stat(entry.path)
      if not stat then
        return
      end
      local current = string.format("%o", stat.mode % 4096)
      vim.ui.input({ prompt = "chmod (" .. current .. "): " }, function(input)
        if not input or input == "" then
          return
        end
        vim.system({ "chmod", input, entry.path }, {}, function(obj)
          vim.schedule(function()
            if obj.code == 0 then
              Snacks.notifier.notify(entry.name .. " → " .. input, "info", { title = "chmod", timeout = 3000 })
            else
              Snacks.notifier.notify(obj.stderr or "failed", "error", { title = "chmod" })
            end
          end)
        end)
      end)
    end, { buffer = buf, desc = "chmod" })
  end,
})

-- Close buffers of files deleted via mini.files (if unmodified)
vim.api.nvim_create_autocmd("User", {
  pattern = "MiniFilesActionDelete",
  callback = function(args)
    local path = args.data.from
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_loaded(buf) and vim.api.nvim_buf_get_name(buf) == path then
        if not vim.bo[buf].modified then
          vim.api.nvim_buf_delete(buf, {})
        end
        break
      end
    end
  end,
})

-- Surround things with other things
require("mini.surround").setup({
  mappings = {
    add = "s",
    delete = "ds",
    replace = "cs",
    find_left = "gs",
    find = "",
    find_right = "",
    highlight = "",
    update_n_lines = "",
  },
})
vim.keymap.set({"n", "x"}, "S", "s", { remap = true, desc = "Surround add" })

-- Improved f and /
require("flash").setup({
  modes = {
    char = { enabled = true },
    search = { enabled = false },
  },
})

require("persistence").setup({})

-- Full blown file manager
require("oil").setup({
  view_options = {
    show_hidden = true,
  },
})

-- Automatically load project environments
require("direnv").setup({
  autoload_direnv = true,
  keybindings = false,
  notifications = {
    silent_autoload = false,
  },
})

-- Find files fucking fast
require("fff").setup({
  prompt = "⚡ ",
  title = "Find File",
  prompt_vim_mode = true,
  grep = {
    modes = { "regex" },
  },
  layout = {
    prompt_position = "top",
    preview_position = "right",
    preview_size = 0.55,
    anchor = "center",
    height = 0.8,
    width = 0.85,
  },
  preview = {
    line_numbers = true,
  },
})

require("snacks-fff").setup({
  find_files = {
    prompt = "⚡ ",
    title = "Find File",
  },
  live_grep = {
    prompt = "⚡ ",
  },
})

require("helm-ls").setup({})
