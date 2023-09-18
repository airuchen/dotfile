-- Filetype settings
local ft_group = vim.api.nvim_create_augroup("ft_settings", { clear = true })


local add_ft_opt = function(ft, command)
    vim.api.nvim_create_autocmd("FileType", {
            pattern = ft,
            group = ft_group,
            command = command
        })
end


add_ft_opt("xml", "setlocal shiftwidth=2 expandtab softtabstop=2")
add_ft_opt("yaml", "setlocal shiftwidth=2 expandtab softtabstop=2")
add_ft_opt("CMakeLists.txt", "setlocal shiftwidth=2 expandtab softtabstop=2")
add_ft_opt("javascript", "setlocal shiftwidth=2 expandtab softtabstop=2")
add_ft_opt("html", "setlocal shiftwidth=2 expandtab softtabstop=2")
add_ft_opt("python", "setlocal shiftwidth=4 expandtab softtabstop=4")
-- Select foo::bar as 2 words, keep signcol open
add_ft_opt("cpp", "setlocal iskeyword-=: signcolumn=yes")

add_ft_opt({"markdown", "rst"}, "setlocal spell | nnoremap <buffer> <silent> <leader>bv :AsyncRun -close -mode=term -pos=right ~/go/bin/glow -p %<CR>")

-- spellcheck in comments
add_ft_opt({"org", "rst", "tex", "cpp", "python", "haskell", "xml", "lua"}, "setlocal spell")

add_ft_opt("plantuml", "nnoremap <buffer> <leader>bv :AsyncRun plantuml % && feh $(VIM_PATHNOEXT).png<CR>")

-- turn off the character limit in fugitive buffers
add_ft_opt({"fugitive", "NeogitStatus"}, "setlocal colorcolumn=0")
add_ft_opt({"NeogitCommitMessage", "gitcommit"}, "setlocal colorcolumn=73")

local function prequire(...)
  local status, lib = pcall(require, ...)
  if (status) then return lib end
  return nil
end
local lsputil = prequire("lspconfig.util")

local default_tox_py_env = "py311"

-- Set up tox bind
if lsputil then
  local pyproject_pattern = lsputil.root_pattern("pyproject.toml")
  local asyncrun_opts = {mode="term", focus=false, listed=false, cwd=cwd}

  local function bind_tox_test()
    local bufno = vim.api.nvim_get_current_buf()
    local fname = vim.api.nvim_buf_get_name(bufno)

    if not fname or not pyproject_pattern(fname) then
      return
    end

    local tox_command = "tox"
    local parts = vim.split(fname, "/")
    local desc = "Run tox commands"
    if vim.tbl_contains(parts, "test") or vim.tbl_contains(parts, "tests") then
      -- attempt to guess the tox env to run
      if vim.fn.has("python3") then
        default_tox_py_env = vim.api.nvim_eval("py3eval('f\"py{sys.version_info.major}{sys.version_info.minor}\"')") or default_tox_py_env
      end
      tox_command = "tox -e " .. default_tox_py_env .. " -- " .. fname
      desc = "Run pytest for current file"

      -- also add a bind for running all tests
      vim.keymap.set("n", "<leader>bT", function()
        vim.call("asyncrun#run", "", asyncrun_opts, "tox")
      end, { buffer = bufno, desc="Run tox tests" })
    end

    vim.keymap.set("n", "<leader>bt", function()
      vim.call("asyncrun#run", "", asyncrun_opts, tox_command)
    end, { buffer = bufno, desc=desc })

    vim.keymap.set("n", "<leader>bm", function()
      vim.call("asyncrun#run", "", asyncrun_opts, "tox -e mypy")
    end, { buffer = bufno, desc="Run mypy" })

    vim.keymap.set("n", "<leader>bd", function()
      vim.call("asyncrun#run", "", asyncrun_opts, "tox -e docs")
    end, { buffer = bufno, desc="Build docs" })
  end

  local function bind_tox_docs()
    local bufno = vim.api.nvim_get_current_buf()
    local fname = vim.api.nvim_buf_get_name(bufno)

    if not fname or not pyproject_pattern(fname) then
      return
    end

    vim.keymap.set("n", "<leader>b", function()
      vim.call("asyncrun#run", "", asyncrun_opts, "tox -e docs")
    end, { buffer = bufno, desc="Build docs" })
  end

  vim.api.nvim_create_autocmd({"FileType"}, {
    pattern = "python",
    callback = bind_tox_test,
    group = ft_group,
    desc = "Bind tox runner"
  })
  vim.api.nvim_create_autocmd({"FileType"}, {
    pattern = "rst",
    callback = bind_tox_docs,
    group = ft_group,
    desc = "Bind tox build docs"
  })
end

if lsputil then
  local cmake_pattern = lsputil.root_pattern("CMakeLists.txt")

  vim.api.nvim_create_autocmd({"FileType"}, {
    pattern = {"cpp", "cmake"},
    callback = function(opts) 
      if vim.fn.executable("ros2") == 1 or vim.fn.executable("rosrun") == 1 then
        return
      end
      local fname = vim.api.nvim_buf_get_name(opts.buf)
      local root = cmake_pattern(vim.fs.normalize(fname))
      if not root then
        return
      end
      local asyncrun_opts = {mode="term", focus=false, listed=false, cwd=root}
      vim.keymap.set("n", "<leader>b", function()
        vim.call("asyncrun#run", "", asyncrun_opts, "cmake --build build")
      end, { buffer = opts.buf, desc="cmake --build build" })
    end,
    group = ft_group,
    desc = "Bind CMake Build"
  })
end

local function setup_rust_binds()
  local function bind_cargo_fun(key, cmd, desc)
    vim.keymap.set("n", key, function()
      local asyncrun_opts = {mode="term", focus=false, listed=false, cwd=cwd}
      vim.call("asyncrun#run", "", asyncrun_opts, cmd)
    end, { buffer = bufno, desc=desc })
  end

  bind_cargo_fun("<leader>bt", "cargo test", "Run cargo test")
  bind_cargo_fun("<leader>br", "cargo run", "Run program")
end

vim.api.nvim_create_autocmd({"FileType"}, {
  pattern = "rust",
  callback = setup_rust_binds,
  group = ft_group,
  desc = "Bind rust runners"
})

vim.api.nvim_create_autocmd({"BufRead"}, {
  pattern = "*/install/*",
  callback = function(ev) vim.bo[ev.buf].readonly = true end,
  group = ft_group,
  desc = "Make files in ROS install spaces readonly"
})
