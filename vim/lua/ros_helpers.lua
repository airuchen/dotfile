local lsputil = require('lspconfig.util')
local Path = require('plenary.path')

local function pkg_name(name)
  local abs_path = Path:new(name):absolute()
  local ros_pattern = lsputil.root_pattern("package.xml")
  local n = ros_pattern(abs_path)
  if not n then
    return nil
  end
  local parts = vim.split(n, Path.path.sep)
  return parts[#parts]
end

local function set_buf_vars()
  local bufno = vim.api.nvim_get_current_buf()
  local fname = vim.uri_to_fname(vim.uri_from_bufnr(bufno))
  if vim.b[bufno].ros_package_name then
    return
  end
  if not fname then
    return
  end
  local pkg = pkg_name(fname)
  if not pkg then
    return
  end
  vim.b[bufno].ros_package_name = pkg
end

local setup = function()
  vim.cmd([[
    augroup Ros_helpers
      autocmd!
      autocmd BufNewFile,BufRead * lua require'ros_helpers'.set_buf_vars()
    augroup END
  ]])
end

return {
    pkg_name = pkg_name,
    set_buf_vars = set_buf_vars,
    setup = setup,
}

