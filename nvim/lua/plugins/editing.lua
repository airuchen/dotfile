return {
  -- Surround things
  'tpope/vim-surround',

  -- Align stuff
  { 'godlygeek/tabular',          lazy = true,                      cmd = "Tabularize" },

  -- toggle with <leader>tm
  { 'dhruvasagar/vim-table-mode', ft = { "rst", "markdown", "org" } },

  -- Add text objects for separated lists, function arguments
  'wellle/targets.vim',

  -- Toggle comments (use gcc)
  -- TODO: gc is native in nvim 0.10.0
  { 'numToStr/Comment.nvim',    opts = {} },

  -- Highlight TODO, FIXME, NOTE, etc. in comments
  {
    'folke/todo-comments.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      signs = false, -- don't show signs in gutter
      highlight = {
        multiline = false,
        before = "",
        keyword = "wide", -- highlight keyword and text after
        after = "",
      },
      colors = {
        error = { "#fb4934" },   -- gruvbox red
        warning = { "#fe8019" }, -- gruvbox orange
        info = { "#83a598" },    -- gruvbox blue
        hint = { "#8ec07c" },    -- gruvbox aqua
        default = { "#fabd2f" }, -- gruvbox yellow
      },
      keywords = {
        FIX = { icon = " ", color = "error", alt = { "FIXME", "BUG", "FIXIT", "ISSUE" } },
        TODO = { icon = " ", color = "default" },
        HACK = { icon = " ", color = "warning" },
        WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
        PERF = { icon = " ", color = "hint", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
        NOTE = { icon = " ", color = "info", alt = { "INFO" } },
      },
    },
  },

  -- Make . work with commands that support it
  'tpope/vim-repeat',

  --MarkdownPreview
  {
    -- Install markdown preview, use npx if available.
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = function(plugin)
      if vim.fn.executable "npx" then
        vim.cmd("!cd " .. plugin.dir .. " && cd app && npx --yes yarn install")
      else
        vim.cmd [[Lazy load markdown-preview.nvim]]
        vim.fn["mkdp#util#install"]()
      end
    end,
    init = function()
      if vim.fn.executable "npx" then vim.g.mkdp_filetypes = { "markdown" } end
    end,
  },

  -- Undo tree
  {
    'mbbill/undotree',
    keys = {
      {
        "<leader>ut",
        function()
          vim.cmd.UndotreeToggle(); vim.cmd.UndotreeFocus()
        end,
        desc = "Toggle Undotree"
      },
      { "<leader>uf", vim.cmd.UndotreeFocus, desc = "Focus Undotree" },
    }
  },

  -- Vim Be Good movement training
  { 'ThePrimeagen/vim-be-good', lazy = true, cmd = "VimBeGood" },
}
