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
        org_id_link_to_org_use_id = true,
        mappings = {
          -- Auto-inserts bullet points, etc
          org_return_uses_meta_return = true,
          capture = {
            org_capture_refile = false,
          },
          org = {
            org_refile = false
          },
        },
        org_capture_templates = {
          t = {
            description = 'Task',
            template = '* TODO %?\n  %u',
          },
          c = {
            description = "Clipboard",
            template = "* %?\n\n%x",
          },
        }
      })
    end,
  },

  {
    "chipsenkbeil/org-roam.nvim",
    -- dir = "~/git/org-roam.nvim",
    dependencies = {
      {
        "nvim-orgmode/orgmode",
      },
    },
    -- cond = false,
    event = 'VeryLazy',
    config = function()
      require("org-roam").setup({
        directory = "~/Documents/org/roam",
        bindings = {
          prefix = "<localleader>r"
        },
        templates = {
          d = {
            description = "Default",
            template = "%?",
            target = "%<%Y%m%d%H%M%S>-%[slug].org",
          },
          l = {
            description = "Learning",
            template = "#+filetags: learning\n\n* Context\n%?\n\n* Description\n",
            target = "%<%Y%m%d%H%M%S>-%[slug].org",
          },
          b = {
            description = "Bug",
            template = "#+filetags: bug\n\n* Symptoms\n%?\n* Cause\n\n* Solution\n",
            target = "%<%Y%m%d%H%M%S>-%[slug].org",
          },
          t = {
            description = "Task",
            template = "* TODO %?",
            target = "tasks/%<%Y%m%d%H%M%S>-%[slug].org",
          },
          c = {
            description = "Clipboard",
            template = "* %?\n\n%x",
            target = "%<%Y%m%d%H%M%S>-%[slug].org",
          },
        },
      })
    end
  }
}
