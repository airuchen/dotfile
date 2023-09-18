local M = {}

local as_hilight_str = function(hilight)
  return "%#" .. hilight .. "#"
end

M.as_hilight_str = as_hilight_str

-- TODO better values for these highlights
-- TODO whoami root stuff here?
-- User1          xxx ctermfg=8 ctermbg=0 guifg=#928374 guibg=#282828
-- User3          xxx ctermfg=14 ctermbg=0 guifg=#8ec07c guibg=#282828
-- percent, filetype, git (todo, not proper colour yet)
-- User2          xxx ctermfg=4 ctermbg=0 guifg=#458588 guibg=#282828


local ds = vim.diagnostic.severity

local box_it = function(opts, elem, left, right)
  left = left or "[ "
  right = right or " ]"
  return table.concat {
    opts.sep_hl,
    left,
    elem,
    opts.sep_hl,
    right
  }
end

local value_sep = function(opts, elems, sep)
  local elems_filtered = {}
  for k,v in pairs(elems) do
    if v then
      table.insert(elems_filtered, v)
    end
  end
  return table.concat(elems_filtered, opts.sep_hl .. sep)
end

local lsp_status = function(bufno, short, opts)
  if vim.tbl_isempty(vim.lsp.buf_get_clients(bufno)) then
    -- No LSP available
    return nil
  end
  local get_element_if = function(prefix, severity, hilight)
    local count = vim.tbl_count(vim.diagnostic.get(bufno, {severity = severity}))
    if count == 0 then
      return nil
    end
    if short then
      return table.concat {
        as_hilight_str(hilight),
        count,
      }
    end
    return table.concat {
      as_hilight_str(hilight),
      prefix,
      opts.sep_hl,
      ":",
      as_hilight_str(hilight),
      count,
    }
  end

  local elems = {
    { t = "E", sev = ds.ERROR, hl = "DiagnosticError"},
    { t = "W", sev = ds.WARN,  hl = "DiagnosticWarn"},
    { t = "I", sev = ds.INFO,  hl = "DiagnosticInfo"},
    { t = "H", sev = ds.HINT,  hl = "DiagnosticHint"}
  }
  local rendered = {}
  for k, v in pairs(elems) do
    res = get_element_if(v.t, v.sev, v.hl)
    if res then
      table.insert(rendered, res)
    end
  end

  if vim.tbl_isempty(rendered) then
    -- No warnings, etc
    return as_hilight_str("DiagnosticInfo") .. "✔"
  end
  return value_sep(opts, rendered, ", ")
end

local ftstr = function(opts)
  return opts.extras_hl .. "%Y%M%R"
end

file_percent = "%p%%"

-- TODO highlights
local line_stats = function(opts)
  local cur_col = opts.val_hl .. "%v"
  local cur_line = opts.val_hl .. "%l"
  local total_lines = opts.val_hl .. "%L"
  local perc = opts.extras_hl .. file_percent
  return value_sep(opts, {
      value_sep(opts, {cur_col, cur_line}, " : "),
      value_sep(opts, {total_lines, box_it(opts, perc, "(", ")") }, " ")
    }, " / ")
end

local short_line_stats = function(opts)
  return box_it(opts, opts.extras_hl .. file_percent, "(", ")")
end

local rhs_sep = "%= "

local buffers = function(bufno, opts)
  local curr_buff = opts.val_hl .. bufno
  local filter_loaded = function(buf)
    return vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].bufhidden ~= "hide"
  end
  local num_bufs = vim.tbl_count(vim.tbl_filter(filter_loaded, vim.api.nvim_list_bufs()))
  if num_bufs == 1 then
    return curr_buff
  end
  return value_sep(opts, {curr_buff, opts.val_hl .. num_bufs}, " / ")
end

local git_status = function(bufno, opts)
  local run_it = function()
    if vim.g.loaded_fugitive then
      local git_str = vim.call("fugitive#statusline")
      if git_str == "" then
        return nil
      end
      return table.concat {opts.extras_hl, string.match(git_str, "%[Git%((.+)%)%]")}
    end
    return nil
  end
  return vim.api.nvim_buf_call(bufno, run_it)
end

local file_info = function(bufno, opts)
  local ros_info = vim.b[bufno].ros_builder_package_name
  local run_it = function()
    if ros_info then
      local filename = vim.fn.expand('%:t')
      return table.concat { opts.val_hl, ros_info, opts.sep_hl, " | ", opts.val_hl, filename }
    end
    return table.concat { opts.val_hl, "%f"}
  end
  return vim.api.nvim_buf_call(bufno, run_it)
end

local not_nil = function(x)
  return x and x ~= ""
end

local line = function(bufno)
  local theme = M._opts.active
  local left_elems = value_sep(theme, vim.tbl_filter(not_nil, {
    buffers(bufno, theme),
    ftstr(theme),
    git_status(bufno, theme),
    file_info(bufno, theme),
  }), " | ")
  local right_elems = value_sep(theme, vim.tbl_filter(not_nil, {
    lsp_status(bufno, true, theme),
    line_stats(theme)
  }), " | ")
  return box_it(theme, table.concat(vim.tbl_flatten({left_elems, rhs_sep, right_elems})))
end

local title = function(bufno, active)
  local theme = M._opts.inactive_title
  if active then
    theme = M._opts.title
  end
  return table.concat({theme.bg, "%=", file_info(bufno, theme), theme.extras_hl, "%M%R%="})
end

local lineInactive = function(bufno)
  local theme = M._opts.inactive
  local curr_buff = theme.val_hl .. bufno
  local left_elems = value_sep(theme, vim.tbl_filter(not_nil, {
    curr_buff,
    file_info(bufno, theme),
  }), " | ")
  local right_elems = value_sep(theme, vim.tbl_filter(not_nil, {
    short_line_stats(theme)
  }), " | ")
  return box_it(theme, table.concat(vim.tbl_flatten({left_elems, rhs_sep, right_elems})))
end

M._opts = {
  active = {
    sep_hl       = as_hilight_str("MySBSep"),
    val_hl       = as_hilight_str("MySBVal"),
    extras_hl    = as_hilight_str("MySBExtra")
  },
  inactive       = {
    sep_hl       = as_hilight_str("MySBSepInactive"),
    val_hl       = as_hilight_str("MySBValInactive"),
    extras_hl    = as_hilight_str("MySBExtraInactive")
  },
  title          = {
    sep_hl       = as_hilight_str("MySBTitleSep"),
    val_hl       = as_hilight_str("MySBTitleVal"),
    extras_hl    = as_hilight_str("MySBTitleExtra"),
    bg           = as_hilight_str("MySBTitleBG")
  },
  inactive_title = {
    sep_hl       = as_hilight_str("MySBTitleSepInactive"),
    val_hl       = as_hilight_str("MySBTitleValInactive"),
    extras_hl    = as_hilight_str("MySBTitleExtraInactive"),
    bg           = as_hilight_str("MySBTitleInactiveBG")
  },
  _loaded = false
}

M.active = function(buf)
  if vim.api.nvim_buf_is_valid(buf) then
    return line(buf)
  end
end

M.title = function()
  local buf = vim.api.nvim_get_current_buf()
  local win = vim.api.nvim_get_current_win()
  if buf and vim.api.nvim_buf_is_valid(buf) then
    return title(buf, win == tonumber(vim.g.actual_curwin))
  end
  return ""
end

M.inactive = function(buf)
  return lineInactive(buf)
end

local vimc = vim.api.nvim_command

local setup_colors = function()
  local active_bg = "#282828"
  local title_bg = "#1d2021"
  local inactive_title_bg = "#282828"
  local inactive_bg = active_bg
  local fg = "#8ec97c"
  local title_fg = "#d56d0e"
  local inactive_fg = "#689d6a"

  vimc("highlight default link MySBSep LineNr")
  vimc("highlight default link MySBVal  Include")
  vimc("highlight default link MySBExtra  Identifier")


  vimc("highlight default link MySBSepInactive LineNr")
  vimc("highlight default link MySBValInactive  Include")
  vimc("highlight default link MySBExtraInactive  Identifier")


  vimc("highlight default MySBTitleSep cterm               = none ctermbg = 0 ctermfg = 8 guibg  = " .. title_bg .. " guifg     = #7c6f64")
  vimc("highlight default MySBTitleVal   cterm             = none ctermbg = 0 ctermfg = 14 guibg = " .. title_bg .. " guifg     = " .. title_fg)
  vimc("highlight default MySBTitleExtra   cterm           = none ctermbg = 0 ctermfg = 4 guibg  = " .. title_bg .. " guifg     = #458588")
  vimc("highlight default MySBTitleBG   cterm         = none ctermbg = 0 ctermfg = 4 guibg  = " .. title_bg)
  -- vimc("highlight default link MySBTitleSep Comment")
  -- vimc("highlight default link MySBTitleVal CursorLine")
  -- vimc("highlight default link MySBTitleExtra Include")
  -- vimc("highlight default link MySBTitleBG CursorLineNr")

  vimc("highlight default link MySBTitleSepInactive Comment")
  vimc("highlight default link MySBTitleValInactive Identifier")
  vimc("highlight default link MySBTitleExtraInactive Include")
  vimc("highlight default link MySBTitleInactiveBG Identifier")
end

local one_time_setup = function()
  if M._opts._loaded then
    return
  end
  M._opts._loaded = true
  vim.o.laststatus = 3
  vim.o.winbar = [[%{%luaeval("require'core.sb'.title()")%}]]
  setup_colors()
  local g = vim.api.nvim_create_augroup("MySB", { clear = true })
  vim.api.nvim_create_autocmd({"ColorScheme"}, { callback = setup_colors, group = g, desc = "Statusbar reset colors" })
  vim.api.nvim_create_autocmd({"WinEnter", "BufWinEnter"}, { callback = function()
    local buf = tonumber(vim.fn.expand("<abuf>"))
    local bar = M.active(buf)
    vim.wo.statusline = bar
  end, group = g, desc = "Set active window statusbar" })
  -- vim.api.nvim_create_autocmd("WinLeave", { callback = function()
  --   local buf = tonumber(vim.fn.expand("<abuf>"))
  --   local win = vim.api.nvim_get_current_win()
  --   vim.schedule(function()
  --     -- Buffer might have gone away
  --     if vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_win_is_valid(win) then
  --       vim.wo[win].statusline = string.format("%%!luaeval('require\"sb\".inactive(%s)')", buf)
  --     end
  --   end)
  -- end, group = "MySB", desc = "Set inactive window statusbar" })
end

M.setup = function(opts)
  M._opts = vim.tbl_deep_extend("force", M._opts, opts or {})
  one_time_setup()
  -- Set initial status line
  vim.wo.statusline = line(1)
end

return M
