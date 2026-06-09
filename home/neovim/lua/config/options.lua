vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.g.editorconfig = true

local opt = vim.opt

opt.autowrite = true
opt.clipboard = "unnamedplus"
opt.completeopt = "menu,menuone,noselect"
opt.conceallevel = 2
opt.confirm = true
opt.cursorline = true
opt.expandtab = true
opt.fillchars = { fold = " ", foldopen = "▾", foldclose = "▸", diff = "╱", eob = " " }
opt.grepformat = "%f:%l:%c:%m"
opt.grepprg = "rg --vimgrep"
opt.ignorecase = true
opt.inccommand = "nosplit"
opt.jumpoptions = "view"
opt.laststatus = 3
opt.linebreak = true
opt.list = true
opt.mouse = "a"
opt.number = true
opt.pumblend = 10
opt.pumheight = 10
opt.relativenumber = true
opt.scrolloff = 4
opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" }
opt.shiftround = true
opt.shiftwidth = 2
opt.shortmess:append({ W = true, I = true, c = true, C = true })
opt.showmode = false
opt.sidescrolloff = 8
opt.signcolumn = "yes"
opt.smartcase = true
opt.smartindent = true
opt.splitbelow = true
opt.splitkeep = "screen"
opt.splitright = true
opt.tabstop = 2
opt.termguicolors = true
opt.textwidth = 80
opt.timeoutlen = 300
opt.undofile = true
opt.undolevels = 10000
opt.updatetime = 200
opt.virtualedit = "block"
opt.wildmode = "longest:full,full"
opt.winminwidth = 5

-- Spell checking (like Doom's spell +aspell)
opt.spell = true
opt.spelllang = { "en" }
opt.spelloptions = { "camel" }

-- Soft wrap with breakindent for visual display
opt.wrap = true
opt.breakindent = true
opt.breakindentopt = "shift:2"

-- Auto hard-wrap comments at textwidth, leave normal text alone
-- (like Doom's auto-fill-mode + comment-auto-fill-only-comments)
opt.formatoptions = "cqjro1n"

-- Treesitter folding (like Doom's fold module)
opt.foldmethod = "expr"
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
opt.foldlevel = 99
opt.foldlevelstart = 99
opt.foldenable = true
opt.foldtext = ""

vim.cmd.colorscheme("bamboo")

-- Auto dark/light theme (like Doom's auto-dark)
-- local function set_theme()
--   local handle = io.popen("defaults read -g AppleInterfaceStyle 2>/dev/null")
--   if not handle then return end
--   local result = handle:read("*a")
--   handle:close()
--   if result:match("Dark") then
--     vim.o.background = "dark"
--   else
--     vim.o.background = "light"
--   end
--   vim.cmd.colorscheme("gruvbox")
-- end
-- set_theme()

-- Re-check on focus gain
-- vim.api.nvim_create_autocmd("FocusGained", {
--   group = vim.api.nvim_create_augroup("auto_dark_mode", { clear = true }),
--   callback = set_theme,
-- })
