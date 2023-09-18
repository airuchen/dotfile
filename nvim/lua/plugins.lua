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
      'crispgm/telescope-heading.nvim'
    },
    config = function()
      require("plugins.telescope_settings")
    end
  },

  -- Vim Be Good movement training
  {'ThePrimeagen/vim-be-good', lazy = true, cmd = "VimBeGood"},

  -- Git integration
  'tpope/vim-fugitive',

  {'sindrets/diffview.nvim', opts={}},

  {'lewis6991/gitsigns.nvim', opts={ 
    signcolumn = false,
  }},

  {
    "NeogitOrg/neogit",
    lazy = true,
    cmd = "Neogit",
    opts = {
      kind = "split_above",
      commit_editor = {
        kind = "split_above",
      },
      disable_hint = true,
      telescope_sorter = function()
        return require("telescope").extensions.fzf.native_fzf_sorter()
      end,
      mappings = {
        status = {
          ["b"] = false,
          ["B"] = "BranchPopup",
        },
      },
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
    config = function()
      require('illuminate').configure({
        filetypes_allowlist = {
          "cpp",
          "python",
          "lua",
          "haskell",
          "bash",
        },
        under_cursor = false,
        min_count_to_highlight = 2
      })
      -- TODO nicer stuff for this?
      vim.cmd([[
      hi def link IlluminatedWordText Visual
      hi def link IlluminatedWordRead DiffChange
      " hi IlluminatedWordWrite cterm=reverse ctermbg=241 gui=reverse gui=underline guibg=#665c54
      hi def link IlluminatedWordWrite DiffDelete
      ]])
    end
  },

  {
    'nvim-orgmode/orgmode',
    config = function()
      require('plugins.treesitter_config')
      require('orgmode').setup({
        org_agenda_files = {'~/Documents/org/**/*'},
        org_default_notes_file = '~/Documents/org/refile.org',
      })
    end,
    build = function()
      require('plugins.treesitter_config')
      pcall(require('nvim-treesitter.install').update({with_sync = true}))
    end,
  },
  {'akinsho/org-bullets.nvim', lazy = true, ft = 'org', opts = {} },

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
