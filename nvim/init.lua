-- Don't parse modelines
vim.opt.modeline = false
-- Don't parse .editorconfig files
vim.g.editorconfig_enable = false
-- nvim >= 0.9
vim.g.editorconfig = false

-- Plugins
pcall(require, 'impatient')
require('plugins')

require('core.options')
require('core.keybinds')
require('core.ft')
require('core.sb').setup()
