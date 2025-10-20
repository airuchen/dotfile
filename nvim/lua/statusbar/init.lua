local M = {}

local as_hilight_str = function(hilight)
  return "%#" .. hilight .. "#"
end

M.as_hilight_str = as_hilight_str

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
  for _, v in pairs(elems) do
    if v then
      table.insert(elems_filtered, v)
    end
  end
  return table.concat(elems_filtered, opts.sep_hl .. sep)
end

-- List of LSP elements, in order
local ds = vim.diagnostic.severity
local lsp_elems = {
  { t = "E", sev = ds.ERROR, hl = as_hilight_str("DiagnosticError") },
  { t = "W", sev = ds.WARN,  hl = as_hilight_str("DiagnosticWarn") },
  { t = "I", sev = ds.INFO,  hl = as_hilight_str("DiagnosticInfo") },
  { t = "H", sev = ds.HINT,  hl = as_hilight_str("DiagnosticHint") }
}
local lsp_ok = as_hilight_str("DiagnosticInfo") .. "✔"

-- Dynamic
local lsp_status = function(bufno, short, opts)
  if vim.tbl_isempty(vim.lsp.get_clients({ bufnr = bufno })) then
    -- No LSP available
    return nil
  end
  local counts = vim.diagnostic.count(bufno)
  local get_element_if = function(prefix, severity, hilight)
    local count = counts[severity]
    if not count or count == 0 then
      return nil
    end
    if short then
      return table.concat {
        hilight,
        count,
      }
    end
    return table.concat {
      hilight,
      prefix,
      opts.sep_hl,
      ":",
      hilight,
      count,
    }
  end

  local rendered = {}
  for _, v in pairs(lsp_elems) do
    local res = get_element_if(v.t, v.sev, v.hl)
    if res then
      table.insert(rendered, res)
    end
  end

  if vim.tbl_isempty(rendered) then
    -- No warnings, etc
    return lsp_ok
  end
  return value_sep(opts, rendered, ", ")
end

-- Cache for static parts
M._cache = {}

local ftstr = function(opts)
  if not M._cache.ftstr then
    M._cache.ftstr = opts.extras_hl .. "%Y%M%R"
  end
  return M._cache.ftstr
end

local macro_rec = function()
  local reg = vim.fn.reg_recording()
  if reg == "" then
    return nil
  end
  return table.concat { as_hilight_str("DiagnosticError"), "⏺ ", reg }
end

local file_percent = "%p%%"

-- TODO highlights
local line_stats = function(opts)
  if not M._cache.line_stats then
    local cur_col = opts.val_hl .. "%v"
    local cur_line = opts.val_hl .. "%l"
    local total_lines = opts.val_hl .. "%L"
    local perc = opts.extras_hl .. file_percent
    M._cache.line_stats = value_sep(opts, {
      value_sep(opts, { cur_col, cur_line }, " : "),
      value_sep(opts, { total_lines, box_it(opts, perc, "(", ")") }, " ")
    }, " / ")
  end
  return M._cache.line_stats
end

local short_line_stats = function(opts)
  if not M._cache.short_line_stats then
    M._cache.short_line_stats = box_it(opts, opts.extras_hl .. file_percent, "(", ")")
  end
  return M._cache.short_line_stats
end

local rhs_sep = "%= "

local buffers = function(bufno, opts)
  local curr_buff = opts.val_hl .. bufno
  local filter_loaded = function(buf)
    return vim.api.nvim_buf_is_loaded(buf) -- unloaded
      and vim.bo[buf].bufhidden ~= "hide"  -- hidden
      and vim.api.nvim_buf_get_name(buf) ~= ""  -- scratch buffers, created by treesitter-context for example
  end
  local num_bufs = vim.tbl_count(vim.tbl_filter(filter_loaded, vim.api.nvim_list_bufs()))
  if num_bufs == 1 then
    return curr_buff
  end
  return value_sep(opts, { curr_buff, opts.val_hl .. num_bufs }, " / ")
end

local git_status = function(bufno, opts)
  -- Needs gitsigns to be running
  local git_status = vim.b[bufno].gitsigns_status_dict
  if not git_status then
    return nil
  end
  local parts = { opts.extras_hl, git_status.head }
  if not git_status.changed then
    -- unsaved new file
    table.insert(parts, ",+") -- like the file type modification status
  elseif git_status.changed > 0 or git_status.added > 0 or git_status.removed > 0 then
    -- changed
    table.insert(parts, ",*") -- like the file type modification status
  end
  return table.concat(parts)
end

local file_info = function(bufno, opts, skip_cache)
  local ros_info = vim.b[bufno].ros_builder_package_name
  if ros_info then
    -- foo_pkg | baz.cpp
    return table.concat { opts.val_hl, ros_info, opts.sep_hl, " | ", opts.val_hl, "%t" }
  end
  -- We call this from statusbar, where the color changes
  if skip_cache then
    return table.concat { opts.val_hl, "%f" }
  end
  if not M._cache.static_file_info then
    -- foo/bar/baz.cpp
    M._cache.static_file_info = table.concat { opts.val_hl, "%f" }
  end
  return M._cache.static_file_info
end

local not_nil = function(x)
  return x and x ~= ""
end

local line = function(bufno)
  local theme = M._opts.active
  local left_elems = value_sep(theme, vim.tbl_filter(not_nil, {
    buffers(bufno, theme),
    ftstr(theme),
    macro_rec(),
    git_status(bufno, theme),
    file_info(bufno, theme),
  }), " | ")
  local right_elems = value_sep(theme, vim.tbl_filter(not_nil, {
    lsp_status(bufno, true, theme),
    line_stats(theme)
  }), " | ")
  return vim.iter({ box_it(theme, left_elems), rhs_sep, box_it(theme, right_elems) }):flatten():join()
end

local title = function(bufno, active)
  local theme = M._opts.inactive_title
  if active then
    theme = M._opts.title
  end
  return table.concat({ theme.bg, "%=", file_info(bufno, theme, true), theme.extras_hl, "%M%R%=" })
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
  return box_it(theme, vim.iter({ left_elems, rhs_sep, right_elems }):flatten():join())

end

M._opts = {
  active         = {
    sep_hl    = as_hilight_str("MySBSep"),
    val_hl    = as_hilight_str("MySBVal"),
    extras_hl = as_hilight_str("MySBExtra")
  },
  inactive       = {
    sep_hl    = as_hilight_str("MySBSepInactive"),
    val_hl    = as_hilight_str("MySBValInactive"),
    extras_hl = as_hilight_str("MySBExtraInactive")
  },
  title          = {
    sep_hl    = as_hilight_str("MySBTitleSep"),
    val_hl    = as_hilight_str("MySBTitleVal"),
    extras_hl = as_hilight_str("MySBTitleExtra"),
    bg        = as_hilight_str("MySBTitleBG")
  },
  inactive_title = {
    sep_hl    = as_hilight_str("MySBTitleSepInactive"),
    val_hl    = as_hilight_str("MySBTitleValInactive"),
    extras_hl = as_hilight_str("MySBTitleExtraInactive"),
    bg        = as_hilight_str("MySBTitleInactiveBG")
  },
  _loaded        = false
}

M.active = function(buf)
  if vim.api.nvim_buf_is_valid(buf) then
    return line(buf)
  end
end

M.title = function()
  local buf = vim.api.nvim_get_current_buf()
  local win = vim.api.nvim_get_current_win()
  -- print(buf, win, tonumber(vim.g.actual_curwin), win == tonumber(vim.g.actual_curwin))
  if buf and vim.api.nvim_buf_is_valid(buf) then
    return title(buf, win == tonumber(vim.g.actual_curwin))
  end
  return ""
end

M.inactive = function(buf)
  return lineInactive(buf)
end

local setup_colors = function()
  local active_bg = "#282828"
  local title_bg = "#1d2021"
  local inactive_title_bg = "#282828"
  local inactive_bg = active_bg
  local fg = "#8ec97c"
  local title_fg = "#d56d0e"
  local inactive_fg = "#689d6a"

  vim.api.nvim_set_hl(0, "MySBSep", { link = "LineNr" })
  vim.api.nvim_set_hl(0, "MySBVal", { link = "Include" })
  vim.api.nvim_set_hl(0, "MySBExtra", { link = "Identifier" })


  vim.api.nvim_set_hl(0, "MySBSepInactive", { link = "LineNr" })
  vim.api.nvim_set_hl(0, "MySBValInactive", { link = "Include" })
  vim.api.nvim_set_hl(0, "MySBExtraInactive", { link = "Identifier" })


  vim.api.nvim_set_hl(0, "MySBTitleSep", { ctermbg = 0, ctermfg = 8, bg = title_bg, fg = "#7c6f64" })
  vim.api.nvim_set_hl(0, "MySBTitleVal", { ctermbg = 0, ctermfg = 14, bg = title_bg, fg = title_fg })
  vim.api.nvim_set_hl(0, "MySBTitleExtra", { ctermbg = 0, ctermfg = 4, bg = title_bg, fg = "#458588" })
  vim.api.nvim_set_hl(0, "Winbar", { ctermbg = 0, ctermfg = 4, bg = title_bg })
  vim.api.nvim_set_hl(0, "WinbarNC", { ctermbg = 0, ctermfg = 4, bg = title_bg })
  -- vim.api.nvim_set_hl(0, "MySBTitleSep", {link ="Comment"})
  -- vim.api.nvim_set_hl(0, "MySBTitleVal", {link ="CursorLine"})
  -- vim.api.nvim_set_hl(0, "MySBTitleExtra", {link ="Include"})
  -- vim.api.nvim_set_hl(0, "MySBTitleBG", {link ="CursorLineNr"})

  vim.api.nvim_set_hl(0, "MySBTitleSepInactive", { link = "Comment" })
  vim.api.nvim_set_hl(0, "MySBTitleValInactive", { link = "Identifier" })
  vim.api.nvim_set_hl(0, "MySBTitleExtraInactive", { link = "Include" })
  vim.api.nvim_set_hl(0, "MySBTitleInactiveBG", { link = "Identifier" })
  vim.api.nvim_set_hl(0, "Statusline", {}) -- clear statusbar highlight
  vim.api.nvim_set_hl(0, "StatuslineNC", {}) -- clear statusbar highlight
end

local update_bar = function()
  local curwin = vim.api.nvim_get_current_win()
  local buf = vim.api.nvim_win_get_buf(curwin)
  local bar = M.active(buf)
  vim.wo.statusline = bar
end

local one_time_setup = function()
  if M._opts._loaded then
    return
  end
  M._opts._loaded = true
  vim.o.laststatus = 3          -- Use global status line
  vim.o.winbar = [[%{%luaeval("require'statusbar'.title()")%}]]
  vim.opt.shortmess:append("q") -- Don't show "recording @" message
  setup_colors()
  local g = vim.api.nvim_create_augroup("MySB", { clear = true })
  vim.api.nvim_create_autocmd({ "ColorScheme" }, { callback = setup_colors, group = g, desc = "Statusbar reset colors" })
  vim.api.nvim_create_autocmd({ "WinEnter", "BufWinEnter", "LspAttach" }, {
    callback = function()
      update_bar()
    end,
    group = g,
    desc = "Set active window statusbar"
  })
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
  local timer = vim.uv.new_timer()
  timer:start(500, 500, vim.schedule_wrap(function()
    update_bar()
  end))
end

M.setup = function(opts)
  M._opts = vim.tbl_deep_extend("force", M._opts, opts or {})
  one_time_setup()
  -- Set initial status line
  vim.wo.statusline = line(1)
end

return M
