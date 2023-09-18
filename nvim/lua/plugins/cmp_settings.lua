local function prequire(...)
  local status, lib = pcall(require, ...)
  if (status) then return lib end
  return nil
end

local luasnip = prequire('luasnip')
luasnip.config.setup({
    -- history = true
    region_check_events = 'CursorMoved',
    update_events = 'TextChanged,TextChangedI'
  }
)
local cmp = prequire("cmp")

vim.keymap.set({"i", "s"}, "<c-k>", function()
  if luasnip.expand_or_jumpable() then
    luasnip.expand_or_jump()
  end
end, { silent = true })

vim.keymap.set({"i", "s"}, "<c-j>", function()
  if luasnip.jumpable(-1) then
    luasnip.jump(-1)
  end
end, { silent = true })
vim.keymap.set({"i"}, "<c-l>", function()
  if luasnip.choice_active() then
    luasnip.change_choice(1)
  end
end)


-- Gets all visible buffers for the buffer completion source
local get_bufnrs = function()
  local bufs = {}
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    bufs[vim.api.nvim_win_get_buf(win)] = true
  end
  return vim.tbl_keys(bufs)
end

-- Completion
vim.opt.wildmenu = true -- Show completion menu

-- Ignore files
vim.opt.wildignore = {
		"*.png", "*.pgm", "*.ltsmap", "*bmp",
		-- C
		"*.o", "*.d", "*.so",
		-- Clangd index
		"*.idx", "compile_commands.json",
    "*/.clangd/*",
		-- ROS
    "CATKIN_IGNORE", "COLCON_IGNORE",
		-- Python
		"*.pyc",
		-- Java
		"*.class",
		-- LaTeX
		"*.aux", "*.log", "*.out", "*.toc", "*.pdf"
	}

-- Always show autocomplete menu
-- set completeopt+=menuone
vim.opt.completeopt = {"menu", "menuone", "noselect"}

-- Don't show ins-completion-menu messages
-- vim.o.shortmess = nil
-- vim.opt.shortmess["c"] = true


cmp.setup({
  -- nvim-cmp by defaults disables autocomplete for prompt buffers
  -- enabled = function ()
  --   return vim.api.nvim_buf_get_option(0, "buftype") ~= "prompt"
  --     or require("cmp_dap").is_dap_buffer()
  -- end,
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
    end,
  },
  mapping = cmp.mapping.preset.insert( {
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
    { name = 'nvim_lua' },
    { name = 'path' },
    { name = 'orgmode' },
    -- { name = 'dap' },
    { name = 'buffer', options = {get_bufnrs = get_bufnrs} },
  }),
  experimental = {
    ghost_text = true,
  }
})

-- `/` cmdline setup.
cmp.setup.cmdline({'/', '?'}, {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = 'buffer' }
  }
})
-- `:` cmdline setup.
cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = 'path' }
  }, {
    { name = 'cmdline' }
  })
})
