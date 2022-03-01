local actions = require('telescope.actions')
local putils = require('telescope.previewers.utils')
local telescope = require('telescope')


-- This may not even be that needed anymore with timeout/filesize limit
local preview_opts = {
    -- 1) Do not show previewer for certain files
  filetype_hook = function(filepath, bufnr, opts)
    -- you could analogously check opts.ft for filetypes
    local excluded = vim.tbl_filter(function(ending)
      return filepath:match(ending)
    end, {
      ".*%.bag",
      ".*%.tgz",
      ".*%.tar.gz",
      })
    if not vim.tbl_isempty(excluded) then
      putils.set_preview_message(
        bufnr,
        opts.winid,
        string.format("I don't like %s files!", excluded[1]:sub(5, -1))
      )
      return false
    end
    return true
  end,
  -- 2) Truncate lines to preview window for too large files
  filesize_hook = function(filepath, bufnr, opts)
    local path = require("plenary.path"):new(filepath)
    -- opts exposes winid
    local height = vim.api.nvim_win_get_height(opts.winid)
    local lines = vim.split(path:head(height), "[\r]?\n")
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  end,
}

telescope.setup {
  defaults = {
    -- prompt_prefix = ">",
    file_sorter =  require'telescope.sorters'.get_fuzzy_file,
    preview = preview_opts,
    set_env = { ['COLORTERM'] = 'truecolor' }, -- default = nil,
    mappings = {
      n = {
        ["q"] = actions.close,
      },
      i = {
        ["<C-k>"] = actions.cycle_history_next,
        ["<C-j>"] = actions.cycle_history_prev,
      }
    },
  },
  extensions = {
    fzf = {
      fuzzy = true,                    -- false will only do exact matching
      override_generic_sorter = false, -- override the generic sorter
      override_file_sorter = true,     -- override the file sorter
      case_mode = "smart_case",        -- or "ignore_case" or "respect_case"
                                       -- the default case_mode is "smart_case"
    }
  }
}
-- To get fzf loaded and working with telescope, you need to call
-- load_extension, somewhere after setup function:
telescope.load_extension('fzf')
telescope.load_extension('ros')
