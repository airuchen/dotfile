vim.api.nvim_create_autocmd('FileType', {
  pattern = 'org',
  group = vim.api.nvim_create_augroup('orgmode_telescope_nvim', { clear = true }),
  callback = function(opts)
    -- Hides links
    vim.opt.conceallevel = 2
    -- disable this to edit links sensibly
    vim.opt.concealcursor = 'nc'
    -- Refile with telescope
    vim.keymap.set('n', '<leader>or', require('telescope').extensions.orgmode.refile_heading,
      { buffer = opts.buf, desc = "org refile" })
  end,
})


return {
  {
    'nvim-orgmode/orgmode',
    -- version = "v0.3",
    dependencies = {
      {
        'akinsho/org-bullets.nvim',
        lazy = true,
        ft = 'org',
        opts = {},
      },
    },
    ft = 'org',
    event = 'VeryLazy',
    config = function()
      require('orgmode').setup({
        org_agenda_files = { '~/Documents/org/**/*' },
        org_default_notes_file = '~/Documents/org/0_refile.org',
        org_startup_indented = true,
        -- org_startup_folded = "content",
        -- We have a telescope plugin for this
        mappings = {
          -- Auto-inserts bullet points, etc
          org_return_uses_meta_return = true,
          capture = {
            org_capture_refile = false,
          },
          org = {
            org_refile = false
          },
        }
      })
    end,
  },
}
