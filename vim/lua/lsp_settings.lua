local nvim_lsp = require('lspconfig')
local lsp_sigs = require('lsp_signature')
local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())

local custom_attach = function(client)
  lsp_sigs.on_attach({
      bind = true,
      hint_enable = false,
      handler_opts = {
        border = "shadow"
      }
    })

  local opts = {buffer = 0, silent = true, remap = false}
  vim.keymap.set('n', '<c-]>', vim.lsp.buf.definition, opts)
  vim.keymap.set('n', '<leader>h', vim.lsp.buf.hover, opts)
  vim.keymap.set('n', '<leader>f', vim.lsp.buf.code_action, opts)
  vim.keymap.set('n', '<leader>cr', vim.lsp.buf.rename, opts)
  -- vim.keymap.set('n', '<leader>r', vim.lsp.buf.references, opts)
  vim.keymap.set('n', '<leader>d', vim.lsp.diagnostic.show_line_diagnostics, opts)
  vim.keymap.set('n', '<leader>cf', vim.lsp.buf.formatting, opts)
  vim.keymap.set('v', '<leader>cf', function() vim.lsp.buf.range_formatting(vim.lsp.util.make_range_params()) end, opts)
  vim.keymap.set('n', '<space>a', '<cmd>ClangdSwitchSourceHeader<CR>', opts)
  vim.keymap.set('n', '[d', vim.lsp.diagnostic.goto_prev, opts)
  vim.keymap.set('n', ']d', vim.lsp.diagnostic.goto_next, opts)
end

nvim_lsp.clangd.setup{
  cmd = { "clangd-13", "--log=error", "--inlay-hints", "--background-index", "--clang-tidy", "--header-insertion=never", "-j=6", '--suggest-missing-includes', '--cross-file-rename'},
  on_attach = custom_attach,
  capabilities = capabilities
}

-- nvim_lsp.pyls.setup{
--   on_attach=custom_attach
-- }
nvim_lsp.pylsp.setup{
  on_attach = custom_attach,
  capabilities = capabilities
}

-- TODO write something that finds the build dir using catkin/colcon/$ROS_WORKSPACE if it exists
nvim_lsp.cmake.setup{
  on_attach = custom_attach,
  capabilities = capabilities
}

-- For sphinx documentation
nvim_lsp.esbonio.setup{
  on_attach = custom_attach,
  capabilities = capabilities
}
require('orgmode').setup_ts_grammar()

require'nvim-treesitter.configs'.setup {
  -- haskell freezes telescope
  ensure_installed = { "org", "c", "python", "lua", "yaml", "html", "cpp", "bash", "regex", "css", "javascript", "rst", "latex", "bibtex", "dockerfile" },     -- one of "all", "language", or a list of languages
  highlight = {
    enable = true,              -- false will disable the whole extension
    disable =  {'org'},
    additional_vim_regex_highlighting = {'org'},
  },
  -- in visual mode, select by tree
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = "gnn",
      node_incremental = "grn",
      scope_incremental = "grc",
      node_decremental = "grm",
    }
  },
  textobjects = {
    move = {
      enable = true,
      goto_next_start = {
        ["]m"] = "@function.outer",
        ["]]"] = "@class.outer",
        ["<space>]"] = "@function.outer",
      },
      goto_next_end = {
        ["]M"] = "@function.outer",
          ["]["] = "@class.outer",
      },
      goto_previous_start = {
        ["[m"] = "@function.outer",
        ["[["] = "@class.outer",
        ["<space>["] = "@function.outer",
      },
      goto_previous_end = {
        ["[M"] = "@function.outer",
        ["[]"] = "@class.outer",
      },
    },
    lsp_interop = {
      enable = true,
      peek_definition_code = {
        ["<leader>F"] = "@function.outer",
        ["<leader>C"] = "@class.outer",
      },
    },
  },
}

