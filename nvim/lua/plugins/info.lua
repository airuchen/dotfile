return {
  -- Unicode stuff like autocomplete with C-X C-Z
  'chrisbra/unicode.vim',

  -- Use ga to show character info, like :poop:, unicode codepoint
  'tpope/vim-characterize',

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
