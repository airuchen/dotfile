return {
  -- Surround things
  'tpope/vim-surround',

  -- bunch of [ ] mappings
  -- yo<x> toggles option x, yos is spellchecking
  -- =p pastes below with autoindent
  'tpope/vim-unimpaired',

  -- Align stuff
  {'godlygeek/tabular', lazy = true, cmd = "Tabularize"},

  -- toggle with <leader>tm
  {'dhruvasagar/vim-table-mode', lazy = true },

  -- Add text objects for separated lists, function arguments
  'wellle/targets.vim',

  -- Toggle comments (use gcc)
  {'numToStr/Comment.nvim', opts = {}},

  -- Make . work with commands that support it
  'tpope/vim-repeat',

  -- Undo tree
  {'mbbill/undotree', lazy = true, cmd = {'UndotreeToggle', 'UndotreeFocus'}},

  -- Vim Be Good movement training
  {'ThePrimeagen/vim-be-good', lazy = true, cmd = "VimBeGood"},
}
