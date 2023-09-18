local nvim_lsp = require('lspconfig')
local lsp_sigs = require('lsp_signature')
local capabilities = require('cmp_nvim_lsp').default_capabilities()

local function nm(key, rhs, desc)
  local opts = {buffer = 0, silent = true, remap = false, desc = desc}
  vim.keymap.set('n', key, rhs, opts)
end

local function vm(key, rhs, desc)
  local opts = {buffer = 0, silent = true, remap = false, desc = desc}
  vim.keymap.set('v', key, rhs, opts)
end

local custom_attach = function()
  lsp_sigs.on_attach({
      bind = true,
      hint_enable = false,
      handler_opts = {
        border = "shadow"
      }
    })

  nm('<c-]>', vim.lsp.buf.definition, "Jump to definition")
  nm('<leader>h', vim.lsp.buf.hover, "LSP hover")
  nm('<leader>H', function() vim.lsp.inlay_hint(0, nil) end, "Toggle inlay hints")
  nm('<leader>cr', vim.lsp.buf.rename, "LSP Rename")
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

-- nvim_lsp.pyls.setup{
--   on_attach=custom_attach
-- }
-- pip install "python-lsp-server[all]" pyls-mypy python-lsp-black
nvim_lsp.pylsp.setup{
  on_attach = custom_attach,
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
nvim_lsp.cmake.setup{
  on_attach = custom_attach,
  capabilities = capabilities
}

-- For sphinx documentation
nvim_lsp.esbonio.setup{
  on_attach = custom_attach,
  capabilities = capabilities
}

-- Shortens the time before CursorHold is triggered, which sets inlay hints for current line
vim.o.updatetime=1000
require("clangd_extensions").setup {
  inlay_hints = {
    inline = vim.fn.has("nvim-0.10") == 1,
    only_current_line = true,
  }
}

local clangd_attach = function()
  require("clangd_extensions.inlay_hints").setup_autocmd()
  require("clangd_extensions.inlay_hints").set_inlay_hints()
  custom_attach()
end

nvim_lsp.clangd.setup{
  cmd = { "clangd", "--log=error", "--background-index", "--clang-tidy", "--header-insertion=never", "-j=6" },
  on_attach = clangd_attach,
  capabilities = capabilities
}



local rt = require("rust-tools")

-- Install rustup
-- rustup component add rust-analyzer
rt.setup({
  -- rust-tools options
  -- tools = { },
  server = {
    cmd = { "rustup", "run", "nightly", "rust-analyzer" },
    on_attach = function(_, bufnr)
      custom_attach()
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
