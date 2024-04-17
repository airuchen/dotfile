-- Don't parse modelines
vim.opt.modeline = false
-- Don't parse .editorconfig files
vim.g.editorconfig_enable = false
-- nvim >= 0.9
vim.g.editorconfig = false

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

-- paste with the yank content
vim.api.nvim_set_keymap('n', 'p', '"0p', {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', 'P', '"0P', {noremap = true, silent = true})
vim.api.nvim_set_keymap('x', 'p', '"0p', {noremap = true, silent = true})
vim.api.nvim_set_keymap('x', 'P', '"0P', {noremap = true, silent = true})

-- Merge all plugin specs from lua/plugins
require("lazy").setup("plugins", {
  dev = {
    path = "~/git",
  },
  performance = {
    rtp = {
      disabled_plugins = {
        "editorconfig",
        "netrwPlugin", -- also needed if running NeoTree
      },
    },
  },
})

require("config.options")
require("config.keybinds")
require("config.ft")
require("statusbar").setup()
require('oil').setup({
    view_options = {
        show_hidden = true,
    },
})
