local function augroup(name)
  return vim.api.nvim_create_augroup("config_" .. name, { clear = true })
end

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup("highlight_yank"),
  callback = function()
    vim.hl.on_yank()
  end,
})

-- Resize splits when window is resized
vim.api.nvim_create_autocmd("VimResized", {
  group = augroup("resize_splits"),
  callback = function()
    local current_tab = vim.fn.tabpagenr()
    vim.cmd("tabdo wincmd =")
    vim.cmd("tabnext " .. current_tab)
  end,
})

-- Go to last cursor position when opening a buffer
vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroup("last_loc"),
  callback = function(event)
    local exclude = { "gitcommit" }
    local buf = event.buf
    if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf]._last_loc then
      return
    end
    vim.b[buf]._last_loc = true
    local mark = vim.api.nvim_buf_get_mark(buf, '"')
    local lcount = vim.api.nvim_buf_line_count(buf)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Enforce formatoptions after ftplugins load (they tend to add 't')
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("formatoptions"),
  callback = function()
    vim.opt_local.formatoptions:remove("t")
    vim.opt_local.formatoptions:append("c")
  end,
})

-- Markdown: follow links with Enter
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("markdown_links"),
  pattern = "markdown",
  callback = function(event)
    vim.keymap.set("n", "<CR>", function()
      local col = vim.api.nvim_win_get_cursor(0)[2]
      local line = vim.api.nvim_get_current_line()
      local pos = 1
      while true do
        local s, e, target = line:find("%[.-%]%((.-)%)", pos)
        if not s then break end
        if col >= s - 1 and col <= e - 1 then
          target = target:gsub("#.*$", "")
          if target == "" then return end
          local bufdir = vim.fn.expand("%:p:h")
          local path = vim.fs.normalize(bufdir .. "/" .. target)
          if vim.uv.fs_stat(path) then
            vim.cmd.edit(path)
          else
            vim.notify("File not found: " .. target, vim.log.levels.WARN)
          end
          return
        end
        pos = e + 1
      end
    end, { buffer = event.buf, desc = "Follow markdown link" })
  end,
})

-- Disable spell in non-text filetypes
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("nospell"),
  pattern = { "help", "lspinfo", "notify", "qf", "checkhealth", "terminal", "NeogitStatus", "oil", "minifiles", "snacks_picker" },
  callback = function()
    vim.opt_local.spell = false
  end,
})

-- Close certain filetypes with <q>
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("close_with_q"),
  pattern = { "help", "lspinfo", "notify", "qf", "checkhealth", "neotest-output", "neotest-summary", "nvim-undotree" },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
  end,
})

-- Undotree: CR confirms and closes
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("undotree_keymaps"),
  pattern = "nvim-undotree",
  callback = function(event)
    vim.keymap.set("n", "<CR>", "<cmd>close<cr>", { buffer = event.buf, silent = true })
  end,
})

-- Auto-create parent directories when saving a file
vim.api.nvim_create_autocmd("BufWritePre", {
  group = augroup("auto_create_dir"),
  callback = function(event)
    if event.match:match("^%w%w+:[\\/][\\/]") then
      return
    end
    local file = vim.uv.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})

-- Terminal buffer setup
vim.api.nvim_create_autocmd("TermOpen", {
  group = augroup("terminal"),
  callback = function(event)
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.spell = false
    vim.opt_local.signcolumn = "no"
    vim.opt_local.scrollback = 10000

    -- Esc Esc to exit terminal mode (single Esc kept for TUI apps)
    vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { buffer = event.buf, desc = "Exit terminal mode" })
    -- Ctrl-based exits that won't conflict with CLI tools
    vim.keymap.set("t", "<C-/>", "<C-\\><C-n>", { buffer = event.buf, desc = "Exit terminal mode" })

    -- Window navigation from terminal mode
    vim.keymap.set("t", "<C-h>", "<C-\\><C-n><C-w>h", { buffer = event.buf, desc = "Go to left window" })
    vim.keymap.set("t", "<C-j>", "<C-\\><C-n><C-w>j", { buffer = event.buf, desc = "Go to lower window" })
    vim.keymap.set("t", "<C-k>", "<C-\\><C-n><C-w>k", { buffer = event.buf, desc = "Go to upper window" })
    vim.keymap.set("t", "<C-l>", "<C-\\><C-n><C-w>l", { buffer = event.buf, desc = "Go to right window" })

    vim.cmd("startinsert")

    -- Shorten buffer name to just the shell basename (e.g. "zsh" instead of "/nix/store/.../bin/zsh")
    -- vim.api.nvim_buf_set_name(event.buf, vim.fn.fnamemodify(vim.o.shell, ":t"))
  end,
})


---
--- Deferred plugin loading
---

-- Load UI-heavy plugins after startup is rendered
vim.api.nvim_create_autocmd("UIEnter", {
  group = augroup("deferred_ui"),
  once = true,
  callback = function()
    vim.schedule(function()
      vim.cmd.packadd("noice.nvim")
      vim.cmd.packadd("nui.nvim")
      require("plugins.noice")
    end)
  end,
})


-- Load LSP, completion, formatting, linting on first real buffer
vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
  group = augroup("deferred_lsp"),
  once = true,
  callback = function()
    local buf = vim.api.nvim_get_current_buf()
    vim.schedule(function()
      vim.cmd.packadd("nvim-lspconfig")
      vim.cmd.packadd("blink.cmp")
      vim.cmd.packadd("conform.nvim")
      vim.cmd.packadd("nvim-lint")
      vim.cmd.packadd("trouble.nvim")
      require("plugins.lsp")
      require("plugins.completion")
      require("plugins.format")
      require("plugins.lint")
      require("plugins.trouble")

      if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].filetype ~= "" then
        vim.api.nvim_exec_autocmds("FileType", { buffer = buf })
      end
    end)
  end,
})

