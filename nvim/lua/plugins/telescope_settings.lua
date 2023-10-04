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
    if opts.ft == "javascript" or opts.ft == "json" then
      local ok, stats = pcall(vim.loop.fs_stat, filepath)
      if ok and stats and stats.size then
        local lc = vim.api.nvim_buf_line_count(bufnr)
        if (stats.size / lc) > 300 then
          putils.set_preview_message(bufnr, opts.winid, "<probably minified>")
          return false
        end
      end
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

local themes = require('telescope.themes')
local builtins = require('telescope.builtin')
local ros_pickers = require('telescope').extensions.ros

telescope.setup {
  defaults = {
    -- prompt_prefix = ">",
    file_sorter =  require'telescope.sorters'.get_fuzzy_file,
    preview = preview_opts,
    path_display = { "truncate", },
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
    },
    ["ui-select"] = {
      themes.get_cursor({})
    }
  }
}
-- To get fzf loaded and working with telescope, you need to call
-- load_extension, somewhere after setup function:
telescope.load_extension('fzf')
telescope.load_extension('ros')
telescope.load_extension('lsp_handlers')
telescope.load_extension('heading')
telescope.load_extension('ui-select')
telescope.load_extension('dap')
telescope.load_extension('orgmode')

local heading = require('telescope').extensions.heading
local ros_builder = require('ros-builder')

----------
-- Keybinds
----------
local function nm(key, rhs, desc)
  local opts = {silent = true, remap = false, desc = desc}
  vim.keymap.set('n', key, rhs, opts)
end

-- LSP references
nm("<leader>r", builtins.lsp_references, "LSP references")

-- Code actions
nm("<leader>f", vim.lsp.buf.code_action, "LSP code actions")

-- Spell suggest
nm("<leader>s", function() builtins.spell_suggest(themes.get_cursor({})) end, "Spell suggest")

-- ROS packages
nm("<leader>dr", function() ros_pickers.packages{cwd=ros_builder.detect_workspace() or "."} end, "ROS packages")

-- package files (or just .)
nm("<leader>ds", ros_pickers.files, "ROS files")

-- Grep things
nm("<leader>dg", ros_pickers.grep_string, "Grep word under cursor")
nm("<leader>g", ros_pickers.live_grep, "Live grep in package")

-- LSP Errors
nm("<leader>E", function() vim.diagnostic.setloclist({open=false}); builtins.loclist{} end, "LSP Errors to loclist")
nm("<leader>e", builtins.diagnostics, "LSP diagnostics")

-- Buffers
-- nm("<leader>db", builtins.buffers, "Buffers")
nm("<leader><space>", builtins.buffers, "Buffers")

-- Git files
nm("<leader>df", builtins.git_files, "Git files")

-- Lines
nm("<leader>dl", builtins.current_buffer_fuzzy_find, "Fuzzy find in current buffer")

-- Resume last picker
nm("<leader><leader><space>", builtins.resume, "Resume Telescope")

-- Pick pickers
nm("<leader>t", builtins.builtin, "Telescope")

-- Headers
nm("<leader>H", heading.heading, "Jump to headings")

-- Orgmode headings
nm("<leader>do", telescope.extensions.orgmode.search_headings, "Search Org Headings")
