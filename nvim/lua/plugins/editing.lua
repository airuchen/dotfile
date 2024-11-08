return {
  -- Surround things
  'tpope/vim-surround',

  -- Align stuff
  { 'godlygeek/tabular',          lazy = true, cmd = "Tabularize" },

  -- toggle with <leader>tm
  { 'dhruvasagar/vim-table-mode', ft = {"rst", "markdown", "org"}},

  -- Add text objects for separated lists, function arguments
  'wellle/targets.vim',

  -- Toggle comments (use gcc)
  -- TODO: gc is native in nvim 0.10.0
  { 'numToStr/Comment.nvim',    opts = {} },

  -- Make . work with commands that support it
  'tpope/vim-repeat',

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
