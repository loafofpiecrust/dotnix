-- Parsers are provided by nix (nvim-treesitter.withAllGrammars).
-- Neovim 0.12 has built-in treesitter highlight support.
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("treesitter_start", { clear = true }),
  callback = function()
    pcall(vim.treesitter.start)
  end,
})

-- Textobjects
require("nvim-treesitter-textobjects").setup({
  move = {
    enable = true,
    goto_next_start = { ["]f"] = "@function.outer", ["]c"] = "@class.outer", ["]a"] = "@parameter.inner" },
    goto_next_end = { ["]F"] = "@function.outer", ["]C"] = "@class.outer" },
    goto_previous_start = { ["[f"] = "@function.outer", ["[c"] = "@class.outer", ["[a"] = "@parameter.inner" },
    goto_previous_end = { ["[F"] = "@function.outer", ["[C"] = "@class.outer" },
  },
  select = {
    enable = true,
    lookahead = true,
    keymaps = {
      ["af"] = "@function.outer",
      ["if"] = "@function.inner",
      ["ac"] = "@class.outer",
      ["ic"] = "@class.inner",
      ["aa"] = "@parameter.outer",
      ["ia"] = "@parameter.inner",
    },
  },
  swap = {
    enable = true,
    swap_next = { ["<leader>a"] = "@parameter.inner" },
    swap_previous = { ["<leader>A"] = "@parameter.inner" },
  },
})
