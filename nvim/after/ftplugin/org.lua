-- Hides links in regular text
vim.wo.conceallevel = 2

-- Don't expand links when cursor is over them
-- disable this to edit links sensibly
-- vim.wo.concealcursor = 'nc'
-- Refile with telescope
local refile = require('telescope').extensions.orgmode.refile_heading
vim.keymap.set('n', '<leader>or', refile, { buffer = 0, desc = "org refile" })
