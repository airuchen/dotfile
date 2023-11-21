return {
  -- Git integration
  {'tpope/vim-fugitive' },

  -- diff view for neogit
  {
    'sindrets/diffview.nvim',
    lazy = true,
    dependencies = {
      { 'nvim-tree/nvim-web-devicons', opts = {}},
    },
    opts = {}
  },

  -- Inline git status and blame
  {
    'lewis6991/gitsigns.nvim',
    opts = {
      signcolumn = false,
      numhl = true,
      current_line_blame_opts = {
        virt_text_pos = 'right_align'
      },
      -- TODO: consider enabling some keybinds, like jumping between hunks and staging
    }
  },

  -- Git plugin, similar to fugitive
  {
    "NeogitOrg/neogit",
    lazy = true,
    cmd = "Neogit",
    opts = {
      kind = "split_above",
      disable_line_numbers = false,
      git_services = {
        ["github.com"] = "https://github.com/${owner}/${repository}/compare/${branch_name}?expand=1",
        ["bitbucket.org"] = "https://bitbucket.org/${owner}/${repository}/pull-requests/new?source=${branch_name}&t=1",
        ["gitlab.com"] = "https://gitlab.com/${owner}/${repository}/merge_requests/new?merge_request[source_branch]=${branch_name}",
        ["gitlab.node%-robotics.com"] = "https://gitlab.node-robotics.com/${owner}/${repository}/merge_requests/new?merge_request[source_branch]=${branch_name}",
      },
      commit_editor = {
        kind = "split_above",
        disable_line_numbers = false,
      },
      disable_hint = true,
      telescope_sorter = function()
        return require("telescope").extensions.fzf.native_fzf_sorter()
      end,
      mappings = {
        popup = {
          -- keep regular b motion
          ["b"] = false,
          ["B"] = "BranchPopup",
        },
        status = {
          [">"] = "Toggle",
          ["o"] = "SplitOpen",
          -- more like fugitive
          -- ["x"] = false,
          -- ["X"] = "Discard",
        },
      },
    },
    keys = {
      { "<leader>n", function() require('neogit').open() end, desc = "Neogit" }
    },
  },
}
