require('orgmode').setup_ts_grammar()

local tsconf = require('nvim-treesitter.configs')

tsconf.setup {
  ensure_installed = { "org", "c", "python", "lua", "yaml", "html", "cpp", "bash", "regex", "css", "javascript", "rst", "latex", "bibtex", "dockerfile", "rust", "haskell" },     -- one of "all", "language", or a list of languages
  highlight = {
    enable = true,
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
    select = {
      enable = true,

      -- Automatically jump forward to textobj, similar to targets.vim
      lookahead = true,

      keymaps = {
        -- You can use the capture groups defined in textobjects.scm
        ["af"] = { query = "@function.outer", desc = "Select around function" },
        ["if"] = { query = "@function.inner", desc = "Select inner part of function" },
        ["aa"] = { query = "@parameter.outer", desc = "Select around parameter" },
        ["ia"] = { query = "@parameter.inner", desc = "Select inner part of parameter" },
      },
    },
    move = {
      enable = true,
      set_jumps = true, -- whether to set jumps in the jumplist
      goto_next_start = {
        ["]m"] = { query = "@function.outer", desc = "Go to next function" },
        ["]]"] = { query = "@class.outer", desc = "Go to next class" },
        ["<space>]"] = { query = "@function.outer", desc = "Go to next function" },
        ["<space>p"] = { query = "@parameter.inner", desc = "Go to next parameter" },
      },
      goto_next_end = {
        ["]M"] = { query = "@function.outer", desc = "Go to end of function" },
        ["]["] = { query = "@class.outer", desc = "Go to end of class" },
      },
      goto_previous_start = {
        ["[m"] = { query = "@function.outer", desc = "Go to previous function" },
        ["[["] = { query = "@class.outer", desc = "Go to previous class" },
        ["<space>["] = { query = "@function.outer", desc = "Go to previous function" },
        ["<space>b"] = { query = "@parameter.inner", desc = "Go to previous parameter" },
      },
      goto_previous_end = {
        ["[M"] = { query = "@function.outer", desc = "Go to previous function end" },
        ["[]"] = { query = "@class.outer", desc = "Go to previous class end" },
      },
    },
    lsp_interop = {
      enable = true,
      peek_definition_code = {
        ["<space>df"] = { query = "@function.outer", desc = "Go to next class" },
        ["<space>dc"] = { query = "@class.outer", desc = "Go to next class" },
      },
    },
  },
}

-- Repeatable treesitter textobject moves
local ts_repeat_move = require "nvim-treesitter.textobjects.repeatable_move"

-- Repeat movement with ; and ,
-- ensure ; goes forward and , goes backward regardless of the last direction
-- vim.keymap.set({ "n", "x", "o" }, ";", ts_repeat_move.repeat_last_move_next)
-- vim.keymap.set({ "n", "x", "o" }, ",", ts_repeat_move.repeat_last_move_previous)

-- vim way: ; goes to the direction you were moving.
vim.keymap.set({ "n", "x", "o" }, "<space>;", ts_repeat_move.repeat_last_move)
vim.keymap.set({ "n", "x", "o" }, "<space>,", ts_repeat_move.repeat_last_move_opposite)

-- Optionally, make builtin f, F, t, T also repeatable with ; and ,
-- vim.keymap.set({ "n", "x", "o" }, "f", ts_repeat_move.builtin_f)
-- vim.keymap.set({ "n", "x", "o" }, "F", ts_repeat_move.builtin_F)
-- vim.keymap.set({ "n", "x", "o" }, "t", ts_repeat_move.builtin_t)
-- vim.keymap.set({ "n", "x", "o" }, "T", ts_repeat_move.builtin_T)
