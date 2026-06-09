local wk = require("which-key")
wk.setup({
  preset = "helix",
  delay = function(ctx)
    return ctx.plugin and 0 or 200
  end,
})

-- Better up/down (respects wrapped lines)
vim.keymap.set({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
vim.keymap.set({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

-- Redo
vim.keymap.set("n", "U", "<C-r>", { desc = "Redo" })

-- Switch to alternate buffer
vim.keymap.set("n", "gb", "<C-^>", { desc = "Switch to last buffer" })

-- Add comment line below/above
vim.keymap.set("n", "gco", function()
  local row = vim.api.nvim_win_get_cursor(0)[1]
  local indent = vim.api.nvim_get_current_line():match("^%s*") or ""
  local prefix = vim.split(vim.bo.commentstring, "%%s")[1]
  vim.api.nvim_buf_set_lines(0, row, row, false, { indent .. prefix })
  vim.api.nvim_win_set_cursor(0, { row + 1, 0 })
  vim.cmd("startinsert!")
end, { desc = "Add comment below" })

vim.keymap.set("n", "gcO", function()
  local row = vim.api.nvim_win_get_cursor(0)[1]
  local indent = vim.api.nvim_get_current_line():match("^%s*") or ""
  local prefix = vim.split(vim.bo.commentstring, "%%s")[1]
  vim.api.nvim_buf_set_lines(0, row - 1, row - 1, false, { indent .. prefix })
  vim.api.nvim_win_set_cursor(0, { row, 0 })
  vim.cmd("startinsert!")
end, { desc = "Add comment above" })

-- Window navigation (auto-focus new split, like Doom's SPC w s / SPC w v)
vim.keymap.set("n", "<leader>j", "<C-w>w", { desc = "Jump to next window" })
vim.keymap.set("n", "<leader>wh", "<C-w>h", { desc = "Go left" })
vim.keymap.set("n", "<leader>wj", "<C-w>j", { desc = "Go down" })
vim.keymap.set("n", "<leader>wk", "<C-w>k", { desc = "Go up" })
vim.keymap.set("n", "<leader>wl", "<C-w>l", { desc = "Go right" })
vim.keymap.set("n", "<leader>wH", "<C-w>H", { desc = "Move window left" })
vim.keymap.set("n", "<leader>wJ", "<C-w>J", { desc = "Move window down" })
vim.keymap.set("n", "<leader>wK", "<C-w>K", { desc = "Move window up" })
vim.keymap.set("n", "<leader>wL", "<C-w>L", { desc = "Move window right" })
vim.keymap.set("n", "<leader>ws", "<cmd>split<cr><C-w>j", { desc = "Split horizontal" })
vim.keymap.set("n", "<leader>wv", "<cmd>vsplit<cr><C-w>l", { desc = "Split vertical" })
vim.keymap.set("n", "<leader>wd", "<C-w>q", { desc = "Close" })
vim.keymap.set("n", "<leader>wD", "<cmd>only<cr>", { desc = "Close other windows" })

-- Window resize
vim.keymap.set("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase window height" })
vim.keymap.set("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease window height" })
vim.keymap.set("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease window width" })
vim.keymap.set("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase window width" })

-- Move lines
vim.keymap.set("n", "<A-j>", "<cmd>execute 'move .+' . v:count1<cr>==", { desc = "Move down" })
vim.keymap.set("n", "<A-k>", "<cmd>execute 'move .-' . (v:count1 + 1)<cr>==", { desc = "Move up" })
vim.keymap.set("v", "<A-j>", ":<C-u>execute \"'<,'>move '>+\" . v:count1<cr>gv=gv", { desc = "Move down" })
vim.keymap.set("v", "<A-k>", ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<cr>gv=gv", { desc = "Move up" })

-- Buffers
vim.keymap.set("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Prev buffer" })
vim.keymap.set("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next buffer" })
vim.keymap.set("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Delete buffer" })
vim.keymap.set("n", "<leader>br", "<cmd>edit!<cr>", { desc = "Revert buffer" })

-- Tabs
vim.keymap.set("n", "<leader><tab>", "<cmd>tabnext #<cr>", { desc = "Last tab" })

-- Clear search highlight
vim.keymap.set({ "i", "n" }, "<esc>", "<cmd>noh<cr><esc>", { desc = "Escape and clear hlsearch" })

-- Better indenting (stays in visual mode)
vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")

-- Quit/Save
vim.keymap.set({ "n", "i", "x", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save file" })
vim.keymap.set("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit all" })

-- Which-key group labels
wk.add({
  { "<leader>f", group = "find" },
  { "<leader>g", group = "git" },
  { "<leader>b", group = "buffers" },
  { "<leader>c", group = "code" },
  { "<leader>x", group = "diagnostics" },
  { "<leader>s", group = "search" },
  { "<leader>t", group = "toggle" },
  { "<leader>q", group = "quit/session" },
  { "<leader>w", group = "window" },
  { "<leader>o", group = "open" },
})

-- Terminal (like Doom's SPC o s → eshell)
vim.keymap.set("n", "<leader>os", "<cmd>terminal<cr>", { desc = "Terminal" })

-- Find file from current buffer directory (like Doom's find-file)
vim.keymap.set("n", "<leader>.", function()
  require("mini.files").open(vim.api.nvim_buf_get_name(0))
end, { desc = "Find file (buffer dir)" })

-- Switch buffer (always opens in current window)
vim.keymap.set("n", "<leader>,", function()
  Snacks.picker.buffers({
    current = false,
    confirm = function(picker, item)
      picker:close()
      if item and item.buf then
        vim.api.nvim_set_current_buf(item.buf)
      end
    end,
  })
end, { desc = "Switch buffer" })

-- Resume last picker (like Doom's SPC-')
vim.keymap.set("n", "<leader>'", function()
  Snacks.picker.resume()
end, { desc = "Resume last search" })

-- Built-in undotree (Neovim 0.12)
vim.cmd.packadd("nvim.undotree")
vim.keymap.set("n", "<leader>u", "<cmd>Undotree<cr>", { desc = "Undotree" })

-- Oil file explorer
vim.keymap.set("n", "<leader>n", function()
  require("oil").open()
end, { desc = "Oil (file browser)" })

-- Find (snacks-fff for files/grep, snacks for the rest)
vim.keymap.set("n", "<leader>ff", function() require("snacks-fff").find_files() end, { desc = "Find files" })
vim.keymap.set("n", "<leader>fr", function() Snacks.picker.recent() end, { desc = "Recent files" })
vim.keymap.set("n", "<leader>fb", function() Snacks.picker.buffers() end, { desc = "Buffers" })
vim.keymap.set("n", "<leader>fp", function()
  Snacks.picker.projects({
    confirm = function(picker, item)
      picker:close()
      if item and item.file then
        local dir = item.file
        vim.cmd.cd(dir)
        local readme = dir .. "/README.md"
        if vim.uv.fs_stat(readme) then
          vim.cmd.edit(readme)
        end
        require("fff").change_indexing_directory(dir)
        vim.schedule(function()
          require("snacks-fff").find_files()
        end)
      end
    end,
  })
end, { desc = "Projects" })
vim.keymap.set("n", "<leader><space>", function() require("snacks-fff").find_files() end, { desc = "Find files" })

-- chmod current file
vim.keymap.set("n", "<leader>fm", function()
  local file = vim.fn.expand("%:p")
  if file == "" then
    return
  end
  local stat = vim.uv.fs_stat(file)
  if not stat then
    return
  end
  local current = string.format("%o", stat.mode % 4096)
  vim.ui.input({ prompt = "chmod (" .. current .. "): " }, function(input)
    if not input or input == "" then
      return
    end
    vim.system({ "chmod", input, file }, {}, function(obj)
      vim.schedule(function()
        if obj.code == 0 then
          Snacks.notifier.notify(vim.fn.expand("%:t") .. " → " .. input, "info", { title = "chmod", timeout = 3000 })
        else
          Snacks.notifier.notify(obj.stderr or "failed", "error", { title = "chmod" })
        end
      end)
    end)
  end)
end, { desc = "chmod file" })

-- Search
vim.keymap.set("n", "<leader>sg", function() require("snacks-fff").live_grep() end, { desc = "Grep" })
vim.keymap.set("n", "<leader>sw", function() require("snacks-fff").grep_word() end, { desc = "Grep word" })
vim.keymap.set("n", "<leader>sb", function() Snacks.picker.grep_buffers() end, { desc = "Grep buffers" })
vim.keymap.set("n", "<leader>sh", function() Snacks.picker.help() end, { desc = "Help pages" })
vim.keymap.set("n", "<leader>sk", function() Snacks.picker.keymaps() end, { desc = "Keymaps" })
vim.keymap.set("n", "<leader>sr", function() Snacks.picker.resume() end, { desc = "Resume" })
vim.keymap.set("n", "<leader>/", function() require("snacks-fff").live_grep() end, { desc = "Grep" })

-- Git
vim.keymap.set("n", "<leader>gg", function()
  vim.cmd.packadd("neogit")
  vim.cmd.packadd("diffview.nvim")
  require("plugins.neogit")
  vim.cmd("Neogit")
end, { desc = "Neogit" })
vim.keymap.set("n", "<leader>gf", function()
  Snacks.picker.git_files()
end, { desc = "Git files" })
vim.keymap.set("n", "<leader>gl", function()
  Snacks.picker.git_log()
end, { desc = "Git log" })
vim.keymap.set("n", "<leader>gs", function()
  Snacks.picker.git_status()
end, { desc = "Git status" })
vim.keymap.set("n", "<leader>gB", function()
  require("gitsigns").blame()
end, { desc = "Git blame buffer" })
vim.keymap.set("n", "<leader>gt", function()
  vim.cmd.packadd("diffview.nvim")
  vim.cmd("DiffviewFileHistory %")
end, { desc = "File history (timemachine)" })
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("diffview_keymaps", { clear = true }),
  pattern = { "DiffviewFiles", "DiffviewFileHistory" },
  callback = function(event)
    vim.keymap.set("n", "q", "<cmd>DiffviewClose<cr>", { buffer = event.buf, desc = "Close diffview" })
  end,
})
vim.keymap.set({ "n", "x" }, "<leader>go", function()
  Snacks.gitbrowse.open({ what = "permalink" })
end, { desc = "Open permalink in browser" })

-- Go to parent scope (treesitter) — useful for YAML, JSON, nested code
vim.keymap.set("n", "gp", function()
  local node = vim.treesitter.get_node()
  if not node then return end
  local crow, ccol = unpack(vim.api.nvim_win_get_cursor(0))
  local parent = node:parent()
  while parent and parent:parent() do
    local sr, sc = parent:range()
    if sr + 1 ~= crow or sc ~= ccol then
      vim.cmd("normal! m`")
      vim.api.nvim_win_set_cursor(0, { sr + 1, sc })
      return
    end
    parent = parent:parent()
  end
end, { desc = "Go to parent scope" })

-- Code (LSP actions, defined here but only functional after LSP loads)
vim.keymap.set("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line diagnostics" })
vim.keymap.set("n", "<leader>cr", vim.lsp.buf.rename, { desc = "Rename" })
vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action" })
vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
vim.keymap.set("n", "gr", vim.lsp.buf.references, { desc = "References" })
vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Hover" })

-- Diagnostics
vim.keymap.set("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Diagnostics (Trouble)" })
vim.keymap.set("n", "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", { desc = "Buffer diagnostics" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Prev diagnostic" })

-- Toggles
vim.keymap.set("n", "<leader>tf", function()
  vim.b.disable_format_on_save = not vim.b.disable_format_on_save
  local state = vim.b.disable_format_on_save and "disabled" or "enabled"
  vim.notify("Format on save " .. state .. " (buffer)")
end, { desc = "Toggle format on save (buffer)" })
vim.keymap.set("n", "<leader>tn", "<cmd>set relativenumber!<cr>", { desc = "Toggle relative numbers" })
vim.keymap.set("n", "<leader>tw", "<cmd>set wrap!<cr>", { desc = "Toggle word wrap" })
vim.keymap.set("n", "<leader>ts", "<cmd>set spell!<cr>", { desc = "Toggle spell check" })

-- Command palette (like Doom's SPC ;)
vim.keymap.set("n", "<leader>;", function()
  Snacks.picker.commands()
end, { desc = "Command palette" })

-- Flash 2-char jump (like Doom's go → avy-goto-char-2)
vim.keymap.set({ "n", "x", "o" }, "go", function()
  require("flash").jump({ search = { mode = "search", max_length = 2 } })
end, { desc = "Flash 2-char jump" })

-- Direnv bindings (like Doom's SPC e → envrc-command-map)
wk.add({ { "<leader>e", group = "direnv" } })
vim.keymap.set("n", "<leader>ea", "<cmd>Direnv allow<cr>", { desc = "Direnv allow" })
vim.keymap.set("n", "<leader>ed", "<cmd>Direnv deny<cr>", { desc = "Direnv deny" })
vim.keymap.set("n", "<leader>er", "<cmd>Direnv reload<cr>", { desc = "Direnv reload" })
vim.keymap.set("n", "<leader>es", "<cmd>Direnv status<cr>", { desc = "Direnv status" })

-- Session (persistence.nvim)
vim.keymap.set("n", "<leader>qs", function()
  require("persistence").load()
end, { desc = "Restore session" })
vim.keymap.set("n", "<leader>ql", function()
  require("persistence").load({ last = true })
end, { desc = "Restore last session" })
vim.keymap.set("n", "<leader>qd", function()
  require("persistence").stop()
end, { desc = "Don't save session" })
