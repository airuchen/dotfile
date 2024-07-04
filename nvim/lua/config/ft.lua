-- Filetype settings

-- Register uml/puml as plantuml.
-- This triggers after/plugin/plantuml.lua
vim.filetype.add({
  extension = {
    uml = "plantuml",
    puml = "plantuml"
  }
})

local ft_group = vim.api.nvim_create_augroup("ft_settings", { clear = true })


local add_ft_opt = function(ft, command)
  vim.api.nvim_create_autocmd("FileType", {
    pattern = ft,
    group = ft_group,
    command = command
  })
end


-- Helper to set indent
local set_indent = function(fts, indent)
  vim.api.nvim_create_autocmd('FileType', {
    pattern = fts,
    group = ft_group,
    callback = function()
      vim.opt.shiftwidth = indent
      vim.opt.expandtab = true
      vim.opt.softtabstop = indent
    end
  })
end

set_indent({ "xml", "yaml", "CMakeLists.txt", "javascript", "html" }, 2)
set_indent({ "python" }, 4)

-- Select foo::bar as 2 words
add_ft_opt({ "cpp", "rust" }, "setlocal iskeyword-=:")

add_ft_opt({ "rust" }, "setlocal colorcolumn=100")

-- spellcheck in comments
add_ft_opt({ "org", "rst", "tex", "cpp", "python", "haskell", "xml", "lua", "plantuml" }, "setlocal spell")
add_ft_opt({"xacro"}, "setlocal filetype=xml")

-- turn off the character limit in fugitive buffers
add_ft_opt({ "fugitive", "NeogitStatus" }, "setlocal colorcolumn=0 | setlocal number | setlocal relativenumber")
add_ft_opt({ "NeogitCommitMessage", "gitcommit" }, "setlocal colorcolumn=73 | setlocal number | setlocal relativenumber")

local default_tox_py_env = "py311"

-- Set up tox bind
local function bind_tox_test(opts)
  local fname = vim.api.nvim_buf_get_name(opts.buf)
  local proj_root = vim.fs.root(opts.buf, {"pyproject.toml", "tox.ini"})

  if not proj_root then
    return
  end

  local asyncrun_opts = { focus = false, listed = false, cwd = proj_root }

  local tox_command = "tox"
  local parts = vim.split(fname, "/")
  local desc = "Run tox commands"
  if vim.tbl_contains(parts, "test") or vim.tbl_contains(parts, "tests") then
    -- attempt to guess the tox env to run
    if vim.fn.has("python3") then
      default_tox_py_env = vim.api.nvim_eval("py3eval('f\"py{sys.version_info.major}{sys.version_info.minor}\"')") or
          default_tox_py_env
    end
    tox_command = "tox -e " .. default_tox_py_env .. " -- " .. fname
    desc = "Run pytest for current file"

    -- also add a bind for running all tests
    vim.keymap.set("n", "<leader>bT", function()
      vim.call("asyncrun#run", "", asyncrun_opts, "tox")
    end, { buffer = opts.buf, desc = "Run tox tests" })
  end

  vim.keymap.set("n", "<leader>bt", function()
    vim.call("asyncrun#run", "", asyncrun_opts, tox_command)
  end, { buffer = opts.buf, desc = desc })

  vim.keymap.set("n", "<leader>bm", function()
    vim.call("asyncrun#run", "", asyncrun_opts, "tox -e mypy")
  end, { buffer = opts.buf, desc = "Run mypy" })

  vim.keymap.set("n", "<leader>bd", function()
    vim.call("asyncrun#run", "", asyncrun_opts, "tox -e docs")
  end, { buffer = opts.buf, desc = "Build docs" })
end

local function bind_tox_docs(opts)
  local fname = vim.api.nvim_buf_get_name(opts.buf)
  local proj_root = pyproject_pattern(vim.fs.normalize(fname))

  if not proj_root then
    return
  end
  local asyncrun_opts = { focus = false, listed = false, cwd = proj_root }

  vim.keymap.set("n", "<leader>b", function()
    vim.call("asyncrun#run", "", asyncrun_opts, "tox -e docs")
  end, { buffer = opts.buf, desc = "Build docs" })
end

vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = "python",
  callback = bind_tox_test,
  group = ft_group,
  desc = "Bind tox runner"
})

vim.api.nvim_create_autocmd({ "BufRead" }, {
  pattern = "pyproject.toml",
  callback = bind_tox_test,
  group = ft_group,
  desc = "Bind tox runner"
})

vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = "rst",
  callback = bind_tox_docs,
  group = ft_group,
  desc = "Bind tox build docs"
})

local bind_cpp_build = function(opts)
  if vim.fn.executable("ros2") == 1 or vim.fn.executable("rosrun") == 1 then
    return
  end
  local root = vim.fs.root(opts.buf, {"CMakeLists.txt"})
  local build_cmd = "clang++ -std=c++20 -ggdb -Wall -Wextra -pedantic -o $(VIM_FILENOEXT) $(VIM_FILEPATH)"
  local cwd = "$(VIM_FILEDIR)"
  if root then
    cwd = root
    build_cmd = "cmake --build build"
    test_cmd = build_cmd .. " && ctest --test-dir build --output-on-failure"

    vim.keymap.set("n", "<leader>bt", function()
      vim.call("asyncrun#run", "", asyncrun_opts, test_cmd)
    end, { buffer = opts.buf, desc = "Run ctest" })
  end
  local asyncrun_opts = { focus = false, listed = false, cwd = cwd }

  vim.keymap.set("n", "<leader>b", function()
    vim.call("asyncrun#run", "", asyncrun_opts, build_cmd)
  end, { buffer = opts.buf, desc = "cmake --build build" })
end

vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = { "cpp", "cmake" },
  callback = bind_cpp_build,
  group = ft_group,
  desc = "Bind CMake Build"
})

local function set_install_space_ro(ev)
  if string.find(ev.file, "/install/") then
    vim.bo[ev.buf].readonly = true
  end
end

vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = { "python", "cpp" },
  callback = set_install_space_ro,
  group = ft_group,
  desc = "Mark ros install-space files readonly"
})

vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = { "qf" },
  callback = function()
    vim.wo[0].wrap = false
    vim.wo[0].colorcolumn = '0'
  end,
  group = ft_group,
  desc = "No wrap, no line limit in qflist"
})
