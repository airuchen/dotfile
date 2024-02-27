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
    event = 'VeryLazy',
    config = function()
      require('orgmode').setup_ts_grammar()
      require('orgmode').setup({
        org_agenda_files = { '~/Documents/org/**/*' },
        org_default_notes_file = '~/Documents/org/refile.org',
        org_startup_indented = true,
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
