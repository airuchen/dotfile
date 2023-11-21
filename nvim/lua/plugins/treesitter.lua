local config_treesitter = function()
  require('orgmode').setup_ts_grammar()

  local tsconf = require('nvim-treesitter.configs')

  -- Make it so we don't turn this on for huge files
  local ts_disable_func = function(lang, bufnr)
    local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(bufnr))
    if ok and stats and stats.size then
      local lc = vim.api.nvim_buf_line_count(bufnr)
      return (stats.size / lc) > 300
    end
    return false
  end

  tsconf.setup {
    -- one of "all", "language", or a list of languages
    ensure_installed = {
      "bash",
      "bibtex",
      "c",
      "cmake",
      "cpp",
      "css",
      "diff",
      "dockerfile",
      "doxygen",
      "git_rebase",
      "gitattributes",
      "gitcommit",
      "gitignore",
      "haskell",
      "html",
      "javascript",
      "json",
      "latex",
      "lua",
      "make",
      "markdown",
      "markdown_inline",
      "org",
      "python",
      "regex",
      "requirements",
      "rst",
      "rust",
      "toml",
      "typescript",
      "xml",
      "yaml",
    },
    highlight = {
      enable = true,
      disable = ts_disable_func,
      additional_vim_regex_highlighting = { 'org' },
    },
    -- in visual mode, select by tree
    incremental_selection = {
      enable = true,
      disable = ts_disable_func,
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
        disable = ts_disable_func,
        -- Automatically jump forward to textobj, similar to targets.vim
        lookahead = true,
        keymaps = {
          -- You can use the capture groups defined in textobjects.scm
          ["af"] = { query = "@function.outer", desc = "Select around function" },
          ["if"] = { query = "@function.inner", desc = "Select inner part of function" },
          ["aa"] = { query = "@parameter.outer", desc = "Select around parameter" },
          ["ia"] = { query = "@parameter.inner", desc = "Select inner part of parameter" },
          ["ac"] = { query = "@class.outer", desc = "Select a class" },
          ["ic"] = { query = "@class.inner", desc = "Select inner part of class" },
        },
      },
      move = {
        enable = true,
        disable = ts_disable_func,
        set_jumps = true, -- whether to set jumps in the jumplist
        goto_next_start = {
          ["]m"] = { query = "@function.outer", desc = "Go to next function" },
          ["]a"] = { query = "@parameter.inner", desc = "Go to next parameter" },
          ["]]"] = { query = "@class.outer", desc = "Go to next class" },
          ["<space>]"] = { query = "@function.outer", desc = "Go to next function" },
          ["<space>p"] = { query = "@parameter.inner", desc = "Go to next parameter" },
        },
        goto_next_end = {
          ["]M"] = { query = "@function.outer", desc = "Go to end of function" },
          ["]A"] = { query = "@parameter.inner", desc = "Go to end of parameter" },
          ["]["] = { query = "@class.outer", desc = "Go to end of class" },
        },
        goto_previous_start = {
          ["[m"] = { query = "@function.outer", desc = "Go to previous function" },
          ["[a"] = { query = "@parameter.inner", desc = "Go to previous parameter" },
          ["[["] = { query = "@class.outer", desc = "Go to previous class" },
          ["<space>["] = { query = "@function.outer", desc = "Go to previous function" },
          ["<space>b"] = { query = "@parameter.inner", desc = "Go to previous parameter" },
        },
        goto_previous_end = {
          ["[M"] = { query = "@function.outer", desc = "Go to previous function end" },
          ["[A"] = { query = "@parameter.inner", desc = "Go to previous parameter end" },
          ["[]"] = { query = "@class.outer", desc = "Go to previous class end" },
        },
      },
      lsp_interop = {
        enable = true,
        disable = ts_disable_func,
        peek_definition_code = {
          ["<space>df"] = { query = "@function.outer", desc = "Go to next class" },
          ["<space>dc"] = { query = "@class.outer", desc = "Go to next class" },
        },
      },
    },
  }

  --[[ -- Too flaky
  -- Repeatable treesitter textobject moves
  local ts_repeat_move = require "nvim-treesitter.textobjects.repeatable_move"

  -- Repeat movement with ; and ,
  -- ensure ; goes forward and , goes backward regardless of the last direction
  vim.keymap.set({ "n", "x", "o" }, ";", ts_repeat_move.repeat_last_move_next)
  vim.keymap.set({ "n", "x", "o" }, ",", ts_repeat_move.repeat_last_move_previous)

  -- Optionally, make builtin f, F, t, T also repeatable with ; and ,
  vim.keymap.set({ "n", "x", "o" }, "f", ts_repeat_move.builtin_f)
  vim.keymap.set({ "n", "x", "o" }, "F", ts_repeat_move.builtin_F)
  vim.keymap.set({ "n", "x", "o" }, "t", ts_repeat_move.builtin_t)
  vim.keymap.set({ "n", "x", "o" }, "T", ts_repeat_move.builtin_T)
  ]]
end

return {
  -- Main treesitter plugin
  {
    'nvim-treesitter/nvim-treesitter',
    lazy = true,
    dependencies = {
      -- Show current context (TSContextEnable)
      'nvim-treesitter/nvim-treesitter-context',
      -- Add treesitter based text objects
      'nvim-treesitter/nvim-treesitter-textobjects',
      -- Dependency here because we need to set up the orgmode grammar
      'nvim-orgmode/orgmode'
    },
    config = config_treesitter,
    build = function()
	    config_treesitter()
	    pcall(require('nvim-treesitter.install').update({with_sync = true}))
    end,
  }
}
