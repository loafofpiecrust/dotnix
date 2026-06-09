require("conform").setup({
  formatters_by_ft = {
    lua = { "stylua" },
    nix = { "nixfmt" },
    go = { "gofumpt" },
    terraform = { "terraform_fmt" },
    tf = { "terraform_fmt" },
    ruby = { "rubocop" },
    rust = { "rustfmt" },
    python = { "ruff_format", "ruff_organize_imports" },
    javascript = { "prettierd" },
    typescript = { "prettierd" },
    javascriptreact = { "prettierd" },
    typescriptreact = { "prettierd" },
    json = { "prettierd" },
    yaml = { "prettierd" },
    html = { "prettierd" },
    css = { "prettierd" },
    markdown = { "prettierd" },
    sh = { "shfmt" },
    bash = { "shfmt" },
  },
  format_on_save = function(bufnr)
    if vim.b[bufnr].disable_format_on_save then
      return
    end
    return { timeout_ms = 3000, lsp_format = "fallback" }
  end,
})
