return {
  -- Replaces netrw with editable buffer
  {
    'stevearc/oil.nvim',
    lazy = false, -- Needed so nvim . opens an oil:// buffer
    keys = {
      -- Note: this also goes to the parent dir in oil:// buffers
      { "<space>e", function() require('oil').open() end, desc = "Explore at file" }
    },
    opts = {
      columns = {
        "icon",
        "permissions",
        "size",
        "mtime",
      },
    }
  },

  -- File tree
  {
    'nvim-tree/nvim-tree.lua',
    event = "VeryLazy",
    cond = false, -- Oil is nicer, set to true to enable
    keys = {
      { "<leader>T", function() local api = require('nvim-tree.api'); api.tree.toggle() end, desc = "Toggle NvimTree" }
    },
    opts = {
      view = {
        number = true,
        relativenumber = true,
      },
      renderer = {
        special_files = { "Cargo.toml", "Makefile", "README.md", "CMakeLists.txt", "readme.md", "README.org" },
        add_trailing = true,
      },
      actions = {
        use_system_clipboard = false,
        change_dir = {
          enable = false,
        }
      },
      filters = {
        custom = { "^\\.git$" }

      },
    }
  },
}
