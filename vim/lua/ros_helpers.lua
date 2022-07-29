local lsputil = require('lspconfig.util')
local Path = require('plenary.path')
local scan = require("plenary.scandir")
local ros_pattern = lsputil.root_pattern("package.xml")

local function pkg_name(name)
  local abs_path = Path:new(name):absolute()
  local n = ros_pattern(abs_path)
  if not n then
    return nil
  end
  local parts = vim.split(n, Path.path.sep)
  return n, parts[#parts]
end

local function setup_test(bufno)
  if not vim.env.ROS_WORKSPACE then
    return
  end
  if not vim.bo.filetype == "cpp" then
    return
  end
  local pkg_name = vim.b[bufno].ros_package_name
  if not pkg_name then
    return
  end
  local is_ros2 = vim.fn.executable("ros2") == 1
  local fname_parts = vim.split(vim.api.nvim_buf_get_name(bufno), Path.path.sep)
  local file = fname_parts[#fname_parts]
  local test_name = vim.split(file, ".cpp")[1]
  vim.b[bufno].ros_test_name = test_name

  local find_test = function(entry)
    return string.find(entry, test_name .. "$")
  end
  if is_ros2 then
    local build_dir = table.concat{
        vim.env.ROS_WORKSPACE,
        "/build/",
        pkg_name,
      }
      vim.b[bufno].ros_build_dir = build_dir
      local test_exe = scan.scan_dir(build_dir, {search_pattern = find_test})[1] or table.concat{build_dir, "/", test_name}
      vim.b[bufno].ros_test_executable = test_exe
  else
    local build_dir = table.concat{
        vim.env.ROS_WORKSPACE,
        "/devel/.private/",
        pkg_name,
      }
      vim.b[bufno].ros_build_dir = build_dir
      vim.b[bufno].ros_test_executable = table.concat{build_dir, "/lib/", pkg_name, "/", test_name}
  end
end

local function set_buf_vars()
  local bufno = vim.api.nvim_get_current_buf()
  if vim.b[bufno].ros_package_name then
    return
  end
  local fname = vim.uri_to_fname(vim.uri_from_bufnr(bufno))
  if not fname then
    return
  end
  local p, pkg = pkg_name(fname)
  if not pkg then
    return
  end
  vim.b[bufno].ros_package_name = pkg
  -- vim.b[bufno].ros_package_path = p -- makes vim-ros go crazy
  setup_test(bufno)
end

local setup = function()
  vim.api.nvim_create_augroup("Ros_helpers", { clear = true })
  vim.api.nvim_create_autocmd({"BufNewFile", "BufRead"}, {
      callback = set_buf_vars,
      group = "Ros_helpers",
      desc = "Sets up ros package"
  })
end

return {
    pkg_name = pkg_name,
    set_buf_vars = set_buf_vars,
    setup = setup,
}

