require("neogit").setup({
  disable_hint = true,
  graph_style = "kitty",
  mappings = {
    status = {
      ["]"] = "GoToNextHunkHeader",
      ["["] = "GoToPreviousHunkHeader",
      ["gr"] = "RefreshBuffer",
    },
    popup = {
      -- Match DOOM magit bindings, since it puts most commonly used operations
      -- unshifted. I push a LOT so it's annoying to shift P for that.
      ["_"] = "RevertPopup",
      ["O"] = "ResetPopup",
      ["v"] = false,
      ["F"] = "PullPopup",
      ["p"] = "PushPopup",
    },
    commit_editor = {
      ["gr"] = "Submit",
    },
    commit_editor_I = {
      ["<c-cr>"] = "Submit",
    },
    rebase_editor = {
      ["gr"] = "Submit",
    },
    rebase_editor_I = {
      ["<c-cr>"] = "Submit",
    },
  },
})

-- Jump to specific sections in Neogit status buffer
vim.api.nvim_create_autocmd("FileType", {
  pattern = "NeogitStatus",
  callback = function(event)
    local function goto_section(pattern)
      local lines = vim.api.nvim_buf_get_lines(event.buf, 0, -1, false)
      for i, line in ipairs(lines) do
        if line:match(pattern) then
          vim.api.nvim_win_set_cursor(0, { i, 0 })
          return
        end
      end
    end

    vim.keymap.set("n", "gu", function() goto_section("^Unstaged changes") end,
      { buffer = event.buf, desc = "Go to unstaged" })
    vim.keymap.set("n", "gs", function() goto_section("^Staged changes") end,
      { buffer = event.buf, desc = "Go to staged" })
    vim.keymap.set("n", "gz", function() goto_section("^Stashes") end,
      { buffer = event.buf, desc = "Go to stashes" })
    vim.keymap.set("n", "v", "V", { buffer = event.buf, desc = "Visual line mode" })
  end,
})
