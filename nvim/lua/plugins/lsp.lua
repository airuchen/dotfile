vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    local lsp_sigs = require('lsp_signature')
    lsp_sigs.on_attach({
      bind = true,
      hint_enable = false,
      handler_opts = {
        border = "shadow"
      }
    })

    local function nm(key, rhs, desc)
      local opts = { buffer = ev.buf, silent = true, remap = false, desc = desc }
      vim.keymap.set('n', key, rhs, opts)
    end

    local function vm(key, rhs, desc)
      local opts = { buffer = ev.buf, silent = true, remap = false, desc = desc }
      vim.keymap.set('v', key, rhs, opts)
    end


    nm('<c-]>', vim.lsp.buf.definition, "Jump to definition")
    nm('<leader>h', vim.lsp.buf.hover, "LSP hover")
    nm('<leader>H', function() vim.lsp.inlay_hint(ev.buf, nil) end, "Toggle inlay hints")
    -- Using inc-rename instead
    -- nm('<leader>cr', vim.lsp.buf.rename, "LSP Rename")
    nm('<leader>d', vim.diagnostic.open_float, "LSP current diagnostic")
    nm('<leader>cf', vim.lsp.buf.format, "Format file")
    nm('<space>a', '<cmd>ClangdSwitchSourceHeader<CR>', "Source <-> Header")
    nm('[d', vim.diagnostic.goto_prev, "Next diagnostic")
    nm(']d', vim.diagnostic.goto_next, "Prev diagnostic")

    -- Telescope handles those
    -- nm('<leader>f', vim.lsp.buf.code_action, "LSP code actions")
    -- nm('<leader>r', vim.lsp.buf.references, "LSP code References")

    vm('<leader>cf', function() vim.lsp.buf.range_formatting(vim.lsp.util.make_range_params()) end, "Format range")
  end
})

function setup_lsp()
  local nvim_lsp = require('lspconfig')
  local capabilities = require('cmp_nvim_lsp').default_capabilities()


  -- pip install "python-lsp-server[all]" pyls-mypy python-lsp-black
  nvim_lsp.pylsp.setup {
    cmd = { vim.loop.os_homedir() .. "/venvs/pylsp/bin/pylsp" },
    capabilities = capabilities,
    settings = {
      pylsp = {
        plugins = {
          pyls_mypy = {
            enabled = true,
            live_mode = false
          },
          black = {
            enabled = true,
          }
        }
      }
    }
  }

  -- TODO write something that finds the build dir using catkin/colcon/$ROS_WORKSPACE if it exists
  -- https://github.com/regen100/cmake-language-server
  -- Can in theory format with cmake-format, but that's not in the PATH since it's in the venv, so it doesn't find it
  nvim_lsp.cmake.setup {
    cmd = { vim.loop.os_homedir() .. "/venvs/cmake_lsp/bin/cmake-language-server" },
    capabilities = capabilities
  }

  -- For sphinx documentation
  -- https://github.com/swyddfa/esbonio
  -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#esbonio
  -- https://docs.esbon.io/en/latest/lsp/getting-started.html#lsp-getting-started
  nvim_lsp.esbonio.setup {
    cmd = { vim.loop.os_homedir() .. "/venvs/esbonio/bin/esbonio" },
    capabilities = capabilities
  }


  -- https://github.com/regen100/cmake-language-server
  require("clangd_extensions").setup {}

  nvim_lsp.clangd.setup {
    cmd = { "clangd", "--log=error", "--background-index", "--clang-tidy", "--header-insertion=never", "-j=6" },
    capabilities = capabilities
  }

  -- requires lua-language-server
  nvim_lsp.lua_ls.setup {
    -- Make vim runtime visible
    on_init = function(client)
      local path = client.workspace_folders[1].name
      if not vim.loop.fs_stat(path .. '/.luarc.json') and not vim.loop.fs_stat(path .. '/.luarc.jsonc') then
        client.config.settings = vim.tbl_deep_extend('force', client.config.settings, {
          Lua = {
            runtime = {
              -- Tell the language server which version of Lua you're using
              -- (most likely LuaJIT in the case of Neovim)
              version = 'LuaJIT'
            },
            -- Make the server aware of Neovim runtime files
            workspace = {
              checkThirdParty = false,
              library = {
                vim.env.VIMRUNTIME
                -- "${3rd}/luv/library"
                -- "${3rd}/busted/library",
              }
              -- or pull in all of 'runtimepath'. NOTE: this is a lot slower
              -- library = vim.api.nvim_get_runtime_file("", true)
            }
          }
        })

        client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
      end
      return true
    end,
    capabilities = capabilities
  }



  local rt = require("rust-tools")

  -- Install rustup
  -- rustup component add rust-analyzer
  rt.setup({
    -- rust-tools options
    tools = {
      inlay_hints = {
        auto = false,
      }
    },
    server = {
      cmd = { "rustup", "run", "nightly", "rust-analyzer" },
      on_attach = function(_, bufnr)
        -- Hover actions
        -- vim.keymap.set("n", "<C-space>", rt.hover_actions.hover_actions, { buffer = bufnr })
        -- Code action groups
        -- vim.keymap.set("n", "<Leader>a", rt.code_action_group.code_action_group, { buffer = bufnr })
      end,
    },
    dap = {
      adapter = {
        type = "executable",
        command = "lldb-vscode",
        name = "rt_lldb",
      }
    },
  })
end

return {
  -- Haskell syntax checker
  {'neovimhaskell/haskell-vim', lazy = true, ft = {'haskell'} },

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
    config = setup_lsp,
  },

  {
    "smjonas/inc-rename.nvim",
    config = function()
      require("inc_rename").setup()
    end,
    keys = {
      { "<leader>cr", ":IncRename ", desc = "LSP Rename" }
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
}
