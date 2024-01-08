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

  -- hide values in .env files
  {
    'laytan/cloak.nvim',
    opts = {
      cloak_length = 10,
      patterns = {
        {
          -- Match any file starting with '.env'.
          -- This can be a table to match multiple file patterns.
          file_pattern = '*.env*',
          -- Match an equals sign and any character after it.
          -- This can also be a table of patterns to cloak,
          -- example: cloak_pattern = { ':.+', '-.+' } for yaml files.
          cloak_pattern = '=.+',
          -- A function, table or string to generate the replacement.
          -- The actual replacement will contain the 'cloak_character'
          -- where it doesn't cover the original text.
          -- If left emtpy the legacy behavior of keeping the first character is retained.
          replace = nil,
        },
      },
    }
  }
}
