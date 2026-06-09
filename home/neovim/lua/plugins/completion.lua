require("blink.cmp").setup({
  keymap = { preset = "super-tab" },
  appearance = {
    nerd_font_variant = "mono",
  },
  sources = {
    default = { "lsp", "path", "snippets", "buffer" },
  },
})
