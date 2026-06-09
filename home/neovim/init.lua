require("config.options")
require("config.autocmds")
require("config.keymaps")

-- These plugins are loaded on-demand via autocmds in config/autocmds.lua
local deferred = {
  ["lsp"] = true,
  ["completion"] = true,
  ["format"] = true,
  ["lint"] = true,
  ["noice"] = true,
  ["trouble"] = true,
  ["neogit"] = true,
}

local plugin_dir = vim.fn.stdpath("config") .. "/lua/plugins"
for _, file in ipairs(vim.fn.readdir(plugin_dir)) do
  if file:match("%.lua$") then
    local mod = file:gsub("%.lua$", "")
    if not deferred[mod] then
      require("plugins." .. mod)
    end
  end
end
