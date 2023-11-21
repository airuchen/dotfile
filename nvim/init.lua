-- Don't parse modelines
vim.opt.modeline = false
-- Don't parse .editorconfig files
vim.g.editorconfig_enable = false
-- nvim >= 0.9
vim.g.editorconfig = false

-- Required if we want to use nvim-tree
-- vim.g.loaded_netrw = 1
-- vim.g.loaded_netrwPlugin = 1

-- Lazy bootstrap
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Merge all plugin specs from lua/plugins
require("lazy").setup("plugins")

require("config.options")
require("config.keybinds")
require("config.ft")
require("statusbar").setup()
