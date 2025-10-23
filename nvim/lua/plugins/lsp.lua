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

    -- Disable semantic tokens for cleaner, minimal highlighting
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client then
      client.server_capabilities.semanticTokensProvider = nil
    end

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
    nm('<leader>H', function()
      local hints_on = vim.lsp.inlay_hint.is_enabled({ bufnr = ev.buf })
      vim.lsp.inlay_hint.enable(not hints_on, { bufnr = ev.buf })
    end, "Toggle inlay hints")
    -- Using inc-rename instead
    nm('<leader>cr', vim.lsp.buf.rename, "LSP Rename")
    nm('<leader>d', vim.diagnostic.open_float, "LSP current diagnostic")
    nm('<leader>cf', vim.lsp.buf.format, "Format file")
    nm('<space>a', '<cmd>ClangdSwitchSourceHeader<CR>', "Source <-> Header")
    nm('[d', vim.diagnostic.goto_prev, "Next diagnostic")
    nm(']d', vim.diagnostic.goto_next, "Prev diagnostic")

    -- If telescope is installed these will use telescope
    nm('<leader>a', vim.lsp.buf.code_action, "LSP code actions")
    nm('<leader>f', vim.lsp.buf.code_action, "LSP code actions")
    nm('<leader>r', vim.lsp.buf.references, "LSP references")

    vm('<leader>cf', function() vim.lsp.buf.range_formatting(vim.lsp.util.make_range_params()) end, "Format range")
  end
})

local setup_lsp = function()
  -- Suppress lspconfig deprecation warnings (ecosystem not ready for new API)
  local notify = vim.notify
  vim.notify = function(msg, ...)
    if msg:match("lspconfig") then
      return
    end
    notify(msg, ...)
  end

  local lspconfig = require('lspconfig')
  
  -- Restore original notify
  vim.notify = notify

  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

  lspconfig.rnix.setup {
    settings = {
      format = {
        enable = true,
      },
    }
  }

  -- pip install "python-lsp-server[all]" pyls-mypy python-lsp-black
  lspconfig.pylsp.setup {
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

  lspconfig.pyright.setup {
    cmd = { vim.loop.os_homedir() .. "/venvs/pylsp/bin/pyright-langserver", "--stdio" },
    capabilities = capabilities,
  }

  if vim.fn.executable("typescript-language-server") == 1 then
    lspconfig.ts_ls.setup {}
  end

  -- pnpm install -g @angular/language-server
  if vim.fn.executable("ngserver") == 1 then
    lspconfig.angularls.setup {}
  end

  -- https://github.com/regen100/cmake-language-server
  -- Can in theory format with cmake-format, but that's not in the PATH since it's in the venv, so it doesn't find it
  lspconfig.cmake.setup {
    cmd = { vim.loop.os_homedir() .. "/venvs/cmake_lsp/bin/cmake-language-server" },
    capabilities = capabilities,
    on_new_config = function(new_config, new_root_dir)
      -- Default, could potentially try some smarter things here
      local build_dir = "build"

      -- For ROS workspaces, we can set the actual build dir
      if vim.env.ROS_WORKSPACE then
        local it = vim.iter(vim.gsplit(new_root_dir, "/"))
        build_dir = vim.env.ROS_WORKSPACE .. "/build/" .. it:last()
      end
      new_config.init_options = {
        buildDirectory = build_dir
      }
    end
  }

  -- For sphinx documentation
  -- https://github.com/swyddfa/esbonio
  -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#esbonio
  -- https://docs.esbon.io/en/latest/lsp/getting-started.html#lsp-getting-started
  lspconfig.esbonio.setup {
    cmd = { vim.loop.os_homedir() .. "/venvs/esbonio/bin/esbonio" },
    capabilities = capabilities
  }


  -- https://github.com/regen100/cmake-language-server
  require("clangd_extensions").setup {}

  lspconfig.clangd.setup {
    -- cmd = { "docker", "exec", "ros2_jazzy_virtualized", "clangd", "--log=error", "--background-index", "--clang-tidy", "--header-insertion=never", "-j=6", "--compile-commands-dir=/home/wen/node/dev_containers/jazzy_dev/workspaces/ros2_jazzy_virtualized/workspace/build", "--path-mappings=/home/wen/node/dev_containers/jazzy_dev/workspaces/ros2_jazzy_virtualized/workspace=/home/virtual/workspace" },
    -- cmd = { "docker", "exec", "ros2_jazzy_virtualized", "clangd", "--log=error", "--background-index", "--clang-tidy", "--header-insertion=never", "-j=6"},
    cmd = { "clangd", "--log=error", "--background-index", "--clang-tidy", "--header-insertion=never", "-j=6" },
    capabilities = capabilities
  }

  -- requires lua-language-server
  lspconfig.lua_ls.setup {
    -- Make vim runtime visible
    on_init = function(client)
      local path = client.workspace_folders[1].name
      if not vim.loop.fs_stat(path .. '/.luarc.json') and not vim.loop.fs_stat(path .. '/.luarc.jsonc') then
        client.config.settings = vim.tbl_deep_extend('force', client.config.settings, {
          Lua = {
            diagnostics = {
              globals = { 'vim' }
            },
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

  lspconfig.hyprls.setup {}

  lspconfig.yamlls.setup {
    settings = {
      yaml = {
        schemas = {
          ["https://json.schemastore.org/github-workflow"] = "/.github/workflows/*",
          ["https://json.schemastore.org/github-action"] = "/.github/actions/*",
          -- Add more schemas if needed
        },
        validate = true,
        format = {
          enable = true,
        },
        hover = true,
        completion = true,
      },
    },
  }

  lspconfig.ts_ls.setup {
  }

  -- Needs vscode-langservers-extracted
  -- npm i -g vscode-langservers-extracted
  capabilities.textDocument.completion.completionItem.snippetSupport = true
  lspconfig.jsonls.setup {
    capabilities = capabilities
  }
end

return {
  -- Haskell syntax checker
  { 'neovimhaskell/haskell-vim', lazy = true, ft = { 'haskell' } },

  -- Basic LSP config
  -- Needs clangd, pip3 install python-language-server cmake-language-server
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      'p00f/clangd_extensions.nvim',
      'hrsh7th/cmp-nvim-lsp',
      'ray-x/lsp_signature.nvim',
      -- TODO consider haskell-tools.nvim
    },
    config = setup_lsp,
  },

  -- Install rustup
  -- rustup component add rust-analyzer
  -- Defaults should be fine, uses the attach autocmd
  {
    'mrcjkb/rustaceanvim',
    -- version = '^3', -- Recommended
    ft = { 'rust' },
    config = function()
      local executors = require("rustaceanvim.executors")
      vim.g.rustaceanvim = {
        tools = {
          executor = executors.quickfix,
          -- runs in background and adds failures as diagnostics
          test_executor = executors.background,
        },
        -- LSP configuration
        server = {
          on_attach = function(client, bufnr)
            local asyncrun_opts = { focus = false, listed = false, cwd = cwd }
            vim.keymap.set("n", "<leader>b",
              function() vim.call("asyncrun#run", "", asyncrun_opts, "cargo build") end,
              { buffer = bufnr, desc = "Cargo build" })
            vim.keymap.set("n", "<leader>bT", vim.cmd.RustTest, { buffer = bufnr, desc = "Run test under cursor" })
            vim.keymap.set("n", "<leader>bt", function() vim.cmd.RustLsp { 'testables', bang = true } end,
              { buffer = bufnr, desc = "Run tests" })
            vim.keymap.set("n", "<leader>br", function() vim.cmd.RustLsp { 'runnables', bang = true } end,
              { buffer = bufnr, desc = "Re-run rust runnable" })
          end,
          -- -- Original setting
          settings = {
            -- rust-analyzer language server configuration
            ['rust-analyzer'] = {
              cargo = {
                allFeatures = true,
                loadOutDirsFromCheck = true,
                runBuildScripts = true,
              },
              checkOnSave = {
                allFeatures = true,
                command = "clippy",
                extraArgs = { "--no-deps" },
              },
              -- leptos things
              procMacro = {
                ignored = {
                  leptos_macro = {
                    -- optional:
                    -- "component",
                    -- "server"
                  }
                }
              },
            },
          },
        },
        -- DAP configuration
        dap = {
        },
      }
    end
  },

  {
    "smjonas/inc-rename.nvim",
    config = function()
      require("inc_rename").setup()
    end,
    cond = false,
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
      vim.g.ale_linters = { sh = { 'shellcheck' } }
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
