vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      workspace = { checkThirdParty = false },
      completion = { callSnippet = "Replace" },
      telemetry = { enable = false },
      diagnostics = { globals = { "vim", "Snacks" } },
    },
  },
})

vim.lsp.config("nixd", {
  settings = {
    nixd = {
      nixpkgs = { expr = "import <nixpkgs> {}" },
      formatting = { command = { "nixfmt" } },
      options = {
        nixos = { expr = '(builtins.getFlake "github:NixOS/nixpkgs/nixos-unstable").lib.nixosSystem { system = "aarch64-darwin"; modules = []; }.options' },
        ["home-manager"] = { expr = '(builtins.getFlake "github:nix-community/home-manager").lib.homeManagerConfiguration { pkgs = import <nixpkgs> {}; modules = []; }.options' },
        nix_darwin = { expr = '(builtins.getFlake "github:LnL7/nix-darwin").lib.darwinSystem { system = "aarch64-darwin"; modules = []; }.options' },
      },
    },
  },
})

vim.lsp.config("rust_analyzer", {
  settings = {
    ["rust-analyzer"] = {
      check = { command = "clippy" },
    },
  },
})

vim.lsp.config("yamlls", {
  settings = {
    yaml = {
      schemaStore = { enable = true },
      validate = true,
    },
  },
})

vim.lsp.enable({
  "lua_ls",
  "nixd",
  "gopls",
  "terraformls",
  "helm_ls",
  "ruby_lsp",
  "rust_analyzer",
  "pyright",
  "ts_ls",
  "bashls",
  "clangd",
  "jsonls",
  "yamlls",
})
