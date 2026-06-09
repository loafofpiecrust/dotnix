require("render-markdown").setup({
  preset = "lazy",
  heading = {
    icons = { "◈ ", "◇ ", "◆ ", "⟐ ", "⟡ ", "⟢ " },
  },
  code = {
    border = "thin",
  },
  win_options = {
    wrap = { default = false, rendered = true },
    linebreak = { default = false, rendered = true },
    breakindent = { default = false, rendered = true },
    colorcolumn = { default = vim.o.colorcolumn, rendered = "" },
  },
})
