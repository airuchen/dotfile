local o = vim.o
local g = vim.g

-- Syntax and colors
o.termguicolors = true

o.background = "dark"

-- Misc settings
-- Listmode chars, tab, trailing spaces, long lines, end-of-line
vim.opt.listchars = { tab = ">-" , trail = ".", extends = ">", eol = "$"}
vim.opt.fillchars:append { diff = "╱" } -- nicer diff fillchar

-- Don't treat 04 as octal
o.nrformats = "bin,hex"

-- New diff mode
vim.opt.diffopt:append("linematch:60")

-- Search settings
o.showmatch = true
o.ignorecase = true
o.smartcase = true
o.incsearch = true
o.hlsearch = true
o.inccommand = "split" -- show preview of offscreen substitute commands

-- UI settings
o.title = true -- Set terminal title
o.visualbell = true
o.showcmd = true -- Show partial commands in the status line (like pending, <leader>, etc)
o.cmdheight = 1
o.lazyredraw = true
-- o.ttyfast = true " Does nothing in neovim

-- Linenumbers
o.number = true -- Make cursor line show real line in relativenumber
o.relativenumber = true -- relative line numbers
o.signcolumn = "yes"
o.scrolloff = 10 -- Try to keep cursor away from window top/bottom
o.cursorline = true -- Hilight cursor line
o.colorcolumn = "120" -- Max line length marker
o.laststatus = 2 -- Always show status line

-- Behaviour
o.hidden = true -- Keep files open after hiding buffers
o.history = 1000 -- Number of history items to keep
o.mouse = "a" -- Mouse in all modes
-- vim.cmd("behave xterm") -- Set mouse behaviour (deprecated in 0.10))
o.mousemodel = "extend"
o.selection = "inclusive"
o.backspace = "indent,eol,start"

-- make h, l wrap lines
-- vim.opt.whichwrap:append("<,>,h,l")
-- no delay on esc
-- This breaks arrow keys and stuff in insert, use ttimeoutlen instead
-- set noesckeys
o.ttimeoutlen = 1

-- Supress flash/beep
-- autocmd VimEnter * set vb t_vb=

-- Tab settings
o.tabstop = 2
o.softtabstop = 2
o.shiftwidth = 2
o.expandtab = true
-- o.cinoptions += "c1,"

-- Indention settings
o.autoindent = true
o.smartindent = true

o.linebreak = true -- Wrapping settings
o.joinspaces = false -- Only add one space when joining lines

-- Autocomplete on :
vim.opt.iskeyword:append { ":" }

-- Autocomplete to longest common string
o.wildmode = "list:longest,full"

-- Allow cursor to go everywhere in block select
o.virtualedit = "block"

-- Undo settings
o.undofile = true
o.undolevels = 500
o.undoreload = 500

o.backupskip="/tmp/*,$TMPDIR/*,$TMP/*,$TEMP/*,/dev/*"

local grp = vim.api.nvim_create_augroup("HistorySettings", { clear = true })
vim.api.nvim_create_autocmd("BufReadPre", {
    pattern = {"/tmp/*", "/dev/*"},
    group = grp,
    desc = "No undo/swap for tmp files",
    callback = function()
      vim.bo.undofile = false
      vim.bo.swapfile = false
    end
  })

-- Netrw settings
-- Hide banner
g.netrw_banner = 0
-- Use tree style
g.netrw_liststyle = 3
-- 1024 based human readable sizes
g.netrw_sizestyle = 'H'
-- Hide ignored files by default (use <a> to cycle)
g.netrw_hide = 1
g.netrw_list_hide = "netrw_gitignore#Hide()"
-- let g:netrw_list_hide='\.clangd/,\.pyc$,\__pycache__/,compile_commands.json'

-- :find settings
-- Search in ros workspace if it's there
-- if vim.env.ROS_WORKSPACE then
--   o.path = o.path .. vim.env.ROS_WORKSPACE .. "/src/**"
-- else
--   o.path = o.path .. "**"
-- end

-- GUI
if vim.fn.has("gui_running") == 1 then
  -- guifont=DejaVu_Sans_Mono:h9:cANSI -- windows
  o.guifont = "DejaVu Sans Mono:h11"
  -- o.guifont = "FiraCode Nerd Font:Retina:h11"
  -- TODO: Not needed?
  -- o.guioptions = ""
end

if vim.g.neovide then
  vim.g.neovide_fullscreen = false
  vim.g.neovide_remember_window_position = false
  vim.g.neovide_remember_window_size = false
  vim.g.neovide_scroll_animation_length = 0
  vim.g.neovide_cursor_animation_length = 0.05
  vim.g.neovide_cursor_trail_size = 0.1
  vim.g.neovide_cursor_vfx_mode = "railgun"
  vim.g.neovide_hide_mouse_when_typing = true
end

-- Tree-sitter

-- Set up folds based on treesitter
o.foldmethod = "expr"
o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
o.foldtext = "v:lua.vim.treesitter.foldtext()"
o.foldlevel = 999

-- Highlight yanked text
local yank = vim.api.nvim_create_augroup("yank_highlight", { clear = true })
local on_yank = require('vim.highlight').on_yank
vim.api.nvim_create_autocmd("TextYankPost", {
    pattern = "*",
    group = yank,
    desc = "highlight on yank",
    callback = function() on_yank({timeout = 50}) end
  })

local ws_group = vim.api.nvim_create_augroup("whitespace", { clear = true })
vim.api.nvim_create_autocmd({"BufWinEnter", "InsertLeave", "BufEnter"}, {
  pattern = "*",
  group = ws_group,
  desc = "highlight trailing whitespace",
  callback = function()
    vim.cmd([[match Error /\s\+$/]])
  end})
vim.api.nvim_create_autocmd({"InsertEnter"}, {
  pattern = "*",
  group = ws_group,
  desc = "highlight trailing whitespace",
  callback = function()
    vim.cmd([[match Error /\s\+\%#\@<!$/]])
  end})
-- Hilight trailing spaces while not in insert
-- autocmd BufWinEnter * match Error /\s\+$/
-- autocmd InsertEnter * match Error /\s\+\%#\@<!$/
-- autocmd InsertLeave * match Error /\s\+$/
-- autocmd BufWinLeave * call clearmatches()
