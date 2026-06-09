# Neovim Config

Personal Neovim configuration managed via Nix, migrated from Doom Emacs.

## Adding plugins

Plugins are installed via Nix in home-manager config under
`programs.neovim.plugins`. LSP servers, formatters, and linters go in
`programs.neovim.extraPackages`.

- **Eager plugins** are listed directly (e.g. `gitsigns-nvim`). They load at
  startup and are configured in a file under `lua/plugins/`. The `init.lua`
  auto-requires every `lua/plugins/*.lua` file that isn't in the `deferred`
  list.
- **Deferred plugins** are wrapped with `{ plugin = ...; optional = true; }`
  in Nix. They are loaded via `vim.cmd.packadd()` in
  `lua/config/autocmds.lua` (e.g. LSP, completion, and formatting load on
  first `BufReadPost`).
- **Plugins not in nixpkgs** can be added inline with
  `pkgs.unstable.vimUtils.buildVimPlugin { ... }` using `builtins.fetchGit`.
  Pin the full commit SHA in `rev`.

## Conventions

- Prefer Lua API functions (e.g. `vim.api.nvim_win_set_cursor`,
  `vim.api.nvim_buf_set_mark`) over `vim.cmd("normal! ...")`. The `normal!`
  form executes keystrokes and depends on default keybindings being intact,
  which breaks when mappings are remapped. Direct API calls are deterministic
  regardless of the user's keymap.
