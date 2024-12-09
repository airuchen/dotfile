local setup_harpoon = function()
  local harpoon = require("harpoon")
  harpoon:setup()

  vim.keymap.set("n", "<space>m", function() harpoon:list():add() end, { desc = "Add to harpoon"})
  vim.keymap.set("n", "<leader>p", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, { desc = "Harpoon menu"})

  -- TODO; this overlaps with illuminate
  vim.keymap.set("n", "<m-n>", function() harpoon:list():select(1) end, { desc = "Harpoon 1"})
  vim.keymap.set("n", "<m-e>", function() harpoon:list():select(2) end, { desc = "Harpoon 2"})
  vim.keymap.set("n", "<m-i>", function() harpoon:list():select(3) end, { desc = "Harpoon 3"})
  vim.keymap.set("n", "<m-o>", function() harpoon:list():select(4) end, { desc = "Harpoon 4"})

  -- Toggle previous & next buffers stored within Harpoon list
  vim.keymap.set("n", "<C-P>", function() harpoon:list():prev() end, { desc = "Harpoon prev"})
  vim.keymap.set("n", "<C-B>", function() harpoon:list():next() end, { desc = "Harpoon next"})
end

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

  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = setup_harpoon
  }
}
