-- Plugins

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

local plugins = {
  ---------------------
  --- Color Schemes ---
  ---------------------

  -- main color scheme should not be lazy
  {
    'folke/tokyonight.nvim',
    lazy = false,
    priority = 1000,
    config = function()
      require("tokyonight").setup({
        style = "night",
        light_style = "day",
        day_brightness = 0.5
      })
      vim.cmd("colorscheme tokyonight")
    end
  },

  {'ellisonleao/gruvbox.nvim', lazy = true},
  {"rebelot/kanagawa.nvim", lazy = true},

  -- Asyncrun
  {
    'skywind3000/asyncrun.vim',
    init = function()
      vim.cmd([[command! -bang -nargs=* -complete=file Make AsyncRun -mode=term -program=make @ <args>]])
    end
  },

  'tpope/vim-surround',

  -- bunch of [ ] mappings
  -- yo<x> toggles option x, yos is spellchecking
  -- =p pastes below with autoindent
  'tpope/vim-unimpaired',

  -- Align stuff
  {'godlygeek/tabular', lazy = true, cmd = "Tabularize"},

  -- Add text objects for separated lists, function arguments
  'wellle/targets.vim',

  -- Undo tree
  {'mbbill/undotree', lazy = true, cmd = {'UndotreeToggle', 'UndotreeFocus'}},

  -- Telescope
  {
    'nvim-telescope/telescope.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope-ui-select.nvim',
      'bi0ha2ard/telescope-ros.nvim',
      {'nvim-telescope/telescope-fzf-native.nvim', build = "make"},
      'gbrlsnchs/telescope-lsp-handlers.nvim',
      'crispgm/telescope-heading.nvim',
      'joaomsa/telescope-orgmode.nvim'
    },
    config = function()
      require("plugins.telescope_settings")
    end
  },

  -- Vim Be Good movement training
  {'ThePrimeagen/vim-be-good', lazy = true, cmd = "VimBeGood"},

  -- Git integration
  'tpope/vim-fugitive',

  {
    'sindrets/diffview.nvim',
    dependencies = {
      { 'nvim-tree/nvim-web-devicons', opts = {}},
    },
    opts = {}
  },

  {
    'lewis6991/gitsigns.nvim', opts = {
      signcolumn = false,
      numhl = true,
      current_line_blame_opts = {
        virt_text_pos = 'right_align'
      },
      -- TODO: consider enabling some keybinds, like jumping between hunks and staging
    }
  },

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

  -- Haskell syntax checker
  {'neovimhaskell/haskell-vim', lazy = true, ft = {'haskell'} },

  -- Unicode stuff like autocomplete with C-X C-Z
  'chrisbra/unicode.vim',

  -- Use ga to show character info, like :poop:, unicode codepoint
  'tpope/vim-characterize',

  -- Toggle comments (use gcc)
  {'numToStr/Comment.nvim', opts = {}},

  -- Latex helpers
  {
    'lervag/vimtex',
    lazy = true,
    ft = {'tex', 'latex', 'org'},
    config = function()
      if vim.fn.has("win32") then
        -- SumatraPDF with fwd/inverse search
        vim.g.vimtex_view_general_viewer = 'SumatraPDF'
        -- TODO check if these even still work
        vim.g.vimtex_view_general_options = '-reuse-instance -inverse-search "gvim --servername ' .. vim.v.servername .. ' --remote-silent +:\\%l<CR> \\%f" -forward-search @tex @line @pdf'
        vim.g.vimtex_view_general_options_latexmk = '-reuse-instance'
      else
        -- Okular
        vim.g.vimtex_view_general_viewer = 'okular'
        -- TODO check if these even still work
        vim.g.vimtex_view_general_options = '--unique @pdf\\#src:@line@tex'
        -- let g:vimtex_view_general_options_latexmk = '--unique'
      end
      vim.g.tex_comment_nospell=1 -- Don't spellcheck comments

      vim.g.tex_flavor='latex'
      -- Don't autoconvert quotes
      vim.g.Tex_SmartKeyQuote=0 -- TODO may to nothing?
    end
  },

  -- Ros
  {
    'taketwo/vim-ros',
    cond = function()
      return vim.fn.executable("ros2") == 1 or vim.fn.executable("rosrun") == 1
    end,
    config = function()
      vim.g.ros_make = 'current'
      vim.g.ros_build_system = 'catkin-tools'
      vim.g.ros_disable_warnings = 1
    end
  },

  -- Snippets, used for cmp as well
  {
    'L3MON4D3/LuaSnip',
    lazy = true,
    event = "InsertEnter",
    config = function() require("core.snippets") end
  },

  -- Autocomplete
  {
    'hrsh7th/nvim-cmp',
    lazy = true,
    event = "InsertEnter",
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-nvim-lua',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-cmdline',
      'saadparwaiz1/cmp_luasnip',
    },
    config = function() require('plugins.cmp_settings') end
  },

  -- Basic LSP config
  -- Needs clangd, pip3 install python-language-server cmake-language-server
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      'p00f/clangd_extensions.nvim',
      'hrsh7th/cmp-nvim-lsp',
      'simrat39/rust-tools.nvim',
      'ray-x/lsp_signature.nvim',
      -- TODO consider haskell-tools.nvim
    },
    config = function()
      require('plugins.lsp_settings')
    end,
    -- after = 'nvim-cmp'
  },

  -- Main treesitter plugin
  {
    'nvim-treesitter/nvim-treesitter',
    dependencies = {
      -- Show current context (TSContextEnable)
      'nvim-treesitter/nvim-treesitter-context',
      -- Add treesitter based text objects
      'nvim-treesitter/nvim-treesitter-textobjects'
    }
  },


  {
    -- Mostly obsoleted by LSP, we only use it for shellckeck
    'dense-analysis/ale',
    lazy = true,
    ft = { "bash", "sh" },
    config = function()
      -- Only run linters named in ale_linters settings
      vim.g.ale_linters_explicit = 1
      -- Explicitly specify which linters to use
      vim.g.ale_linters = { sh = {'shellcheck'} }
    end
  },

  -- Highlight current references
  {
    'RRethy/vim-illuminate',
    event = { "BufReadPre", "BufNewFile" },
    config = function()
        require('illuminate').configure({
        filetypes_denylist = {
            'dirvish',
            'fugitive',
            'nvimtree',
        },
        filetypes_allowlist = {
          "cpp",
          "python",
          "lua",
          "haskell",
          "bash",
        },
        under_cursor = true,
        min_count_to_highlight = 2
      })
    end,
  },

  {
    'nvim-orgmode/orgmode',
    dependencies = {
      {'akinsho/org-bullets.nvim', lazy = true, ft = 'org', opts = {} },
    },
    event = 'VeryLazy',
    config = function()
      require('plugins.treesitter_config')
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
    build = function()
      require('plugins.treesitter_config')
      pcall(require('nvim-treesitter.install').update({with_sync = true}))
    end,
  },

  -- toggle with <leader>tm
  'dhruvasagar/vim-table-mode',

  -- Make . work with commands that support it
  'tpope/vim-repeat',

  -- Debugger
  {
    'mfussenegger/nvim-dap',
    dependencies = {
      'theHamsta/nvim-dap-virtual-text',
      'rcarriga/nvim-dap-ui',
      'nvim-telescope/telescope-dap.nvim'
      -- Plug 'rcarriga/cmp-dap'
    },
    config = function() require('plugins.dap_settings') end
  },

  {
    "bi0ha2ard/ros-builder.nvim",
    dependencies = {
      -- to make sure the builder is there
      'skywind3000/asyncrun.vim',
    },
    opts = {
      keys = {
        build = "<leader>b",
        test = "<leader>bt",
      },
      systems = {
        colcon = {
          opts = {
            cmake_args = {"-DCMAKE_CXX_FLAGS=-ggdb"},
            mixins = {"compile-commands", "ccache"},
            build = { "--symlink-install" },
          },
        },
        catkin = {
          opts = {
            build = { "-j12", "--no-notify" },
          },
        }
      }
    }
  },

  -- File tree
  {
    'nvim-tree/nvim-tree.lua',
    event = "VeryLazy",
    cond = false, -- Oil is nicer
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

  -- Shows available keybinds at the bottom
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    init = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300
    end,
    opts = {}
  },
}

return require('lazy').setup(plugins)
