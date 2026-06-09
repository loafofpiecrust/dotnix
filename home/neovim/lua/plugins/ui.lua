require("lualine").setup({
  options = {
    theme = "auto",
    globalstatus = true,
    section_separators = { left = "", right = "" },
    component_separators = { left = "", right = "" },
  },
  sections = {
    lualine_a = { {
      "mode",
      fmt = function(s)
        return s:sub(1, 1)
      end,
    } },
    lualine_b = { "branch" },
    lualine_c = {
      { "diagnostics" },
      { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
      { "filename", path = 1 },
    },
    lualine_x = {
      -- {
      --   function()
      --     return vim.b.disable_format_on_save and "󰉥" or "󰉢"
      --   end,
      --   cond = function()
      --     return require("conform").list_formatters(0)[1] ~= nil
      --   end,
      -- },
    },
    lualine_y = { "progress" },
    lualine_z = { "location" },
  },
})

Snacks = require("snacks")
Snacks.setup({
  picker = {
    matcher = {
      cwd_bonus = true,
      frecency = true,
    },
    jump = { reuse_win = false },
  },
  notifier = { enabled = true },
  dashboard = { enabled = false },
})

-- Indent guides
require("ibl").setup({
  scope = { enabled = true, show_start = false, show_end = false },
})

-- Preview registers before picking one.
require("registers").setup({})
