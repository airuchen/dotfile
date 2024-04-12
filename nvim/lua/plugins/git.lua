return {
  -- Git integration
  { 'tpope/vim-fugitive' },

  -- diff view for neogit
  {
    'sindrets/diffview.nvim',
    lazy = true,
    cmd = { "DiffviewOpen", "DiffviewFileHistory" },
    dependencies = {
      { 'nvim-tree/nvim-web-devicons', opts = {} },
    },
    opts = {
      enhanced_diff_hl = true,
      default_args = {
        DiffviewOpen = { "--imply-local" }, -- make LSPs work in diff buffers
      }
    }
  },

  -- Inline git status and blame
  {
    'lewis6991/gitsigns.nvim',
    event = "BufReadPre",
    opts = {
      signcolumn = false,
      numhl = true,
      current_line_blame_opts = {
        virt_text_pos = 'right_align'
      },
      -- TODO: consider enabling some keybinds, like jumping between hunks and staging
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, desc, opts)
          opts = opts or {}
          opts.desc = desc
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        map('n', ']c', function()
          if vim.wo.diff then return ']c' end
          vim.schedule(function() gs.next_hunk() end)
          return '<Ignore>'
        end, "Next hunk", { expr = true })

        map('n', '[c', function()
          if vim.wo.diff then return '[c' end
          vim.schedule(function() gs.prev_hunk() end)
          return '<Ignore>'
        end, "Prev hunk", { expr = true })

        -- Actions
        map('n', '<leader>vs', gs.stage_hunk, "Stage hunk")
        map('n', '<leader>vr', gs.reset_hunk, "Reset hunk")
        map('v', '<leader>vs', function() gs.stage_hunk { vim.fn.line('.'), vim.fn.line('v') } end, "Stage selection")
        map('v', '<leader>vr', function() gs.reset_hunk { vim.fn.line('.'), vim.fn.line('v') } end, "Reset selection")
        map('n', '<leader>vS', gs.stage_buffer, "Stage buffer")
        map('n', '<leader>vu', gs.undo_stage_hunk, "Undo stage hunk")
        -- map('n', '<leader>vR', gs.reset_buffer)
        map('n', '<leader>vp', gs.preview_hunk, "Preview hunk")
        map('n', '<leader>vb', function() gs.blame_line { full = true } end, "Blame line")
        -- map('n', '<leader>tb', gs.toggle_current_line_blame)
        map('n', '<leader>vd', gs.diffthis, "Diff this (index)")
        map('n', '<leader>vD', function() gs.diffthis('~') end, "Diff this (commit)")
        -- map('n', '<leader>td', gs.toggle_deleted)

        -- Text object
        map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>', "Hunk")
      end,
    }
  },

  -- Git plugin, similar to fugitive
  {
    "NeogitOrg/neogit",
    branch = "nightly",
    lazy = true,
    cmd = "Neogit",
    opts = {
      kind = "split_above",
      disable_line_numbers = false,
      disable_context_highlighting = true, -- no annoying flickering
      disable_insert_on_commit = true, -- don't start in insert mode in commit editor
      disable_signs = true, -- no signs for collapsed things
      graph_style = "unicode", -- make log view look nicer
      git_services = {
        ["github.com"] = "https://github.com/${owner}/${repository}/compare/${branch_name}?expand=1",
        ["bitbucket.org"] = "https://bitbucket.org/${owner}/${repository}/pull-requests/new?source=${branch_name}&t=1",
        ["gitlab.com"] = "https://gitlab.com/${owner}/${repository}/merge_requests/new?merge_request[source_branch]=${branch_name}",
        ["gitlab.node%-robotics.com"] = "https://gitlab.node-robotics.com/${owner}/${repository}/merge_requests/new?merge_request[source_branch]=${branch_name}",
      },
      ignored_settings = {
        "NeogitPushPopup--force-with-lease",
        "NeogitPushPopup--force",
        "NeogitPullPopup--rebase",
        "NeogitCommitPopup--allow-empty",
        "NeogitCommitPopup--no-verify",
        "NeogitRevertPopup--no-edit",
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
          ["<"] = "Toggle",
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
