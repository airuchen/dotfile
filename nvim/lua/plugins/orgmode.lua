return {
  {
    'nvim-orgmode/orgmode',
    dependencies = {
      {'akinsho/org-bullets.nvim', lazy = true, ft = 'org', opts = {} },
    },
    event = 'VeryLazy',
    config = function()
      require('orgmode').setup({
        org_agenda_files = {'~/Documents/org/**/*'},
        org_default_notes_file = '~/Documents/org/refile.org',
        -- We have a telescope plugin for this
        mappings = {
          capture = {
            org_capture_refile = '<nop>'
          },
          org = {
            org_refile = '<nop>'
          },
        }
      })
    end,
  },
}
