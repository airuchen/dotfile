-- DAP debug adapter protocol configuration

local setup_dap = function()
  local dap = require('dap')

  -- https://github.com/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation

  -- run lldb comands with ` in the REPL
  dap.adapters.lldb = {
    type = 'executable',
    command = '/usr/bin/lldb-vscode', -- adjust as needed, must be absolute path
    name = 'lldb'
  }


  dap.configurations.cpp = {
    {
      name = 'Launch',
      type = 'lldb',
      request = 'launch',
      program = function()
        return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
      end,
      cwd = '${workspaceFolder}',
      stopOnEntry = false,
      args = {},

      -- 💀
      -- if you change `runInTerminal` to true, you might need to change the yama/ptrace_scope setting:
      --
      --    echo 0 | sudo tee /proc/sys/kernel/yama/ptrace_scope
      --
      -- Otherwise you might get the following error:
      --
      --    Error on launch: Failed to attach to the target process
      --
      -- But you should be aware of the implications:
      -- https://www.kernel.org/doc/html/latest/admin-guide/LSM/Yama.html
      -- runInTerminal = false,
    },
    {
      name = 'Launch ROS test',
      type = 'lldb',
      request = 'launch',
      program = function()
        local bufno = vim.api.nvim_get_current_buf()
        return vim.b[bufno].ros_helpers_test_executable or ""
      end,
      cwd = '${workspaceFolder}',
      stopOnEntry = false,
      args = {},
    },
    {
      -- If you get an "Operation not permitted" error using this, try disabling YAMA:
      --  echo 0 | sudo tee /proc/sys/kernel/yama/ptrace_scope
      name = "Attach to process",
      type = 'lldb',  -- Adjust this to match your adapter name (`dap.adapters.<name>`)
      request = 'attach',
      pid = require('dap.utils').pick_process,
      args = {},
    },
  }

  -- If you want to use this for Rust and C, add something like this:
  dap.configurations.c = dap.configurations.cpp
  dap.configurations.rust = dap.configurations.cpp


  -- Virtual text showing values of stuff
  require("nvim-dap-virtual-text").setup()

  local dapui = require("dapui")
  dapui.setup()

  dap.listeners.after.event_initialized["dapui_config"] = function()
    dapui.open()
  end
  dap.listeners.before.event_terminated["dapui_config"] = function()
    dapui.close()
  end
  dap.listeners.before.event_exited["dapui_config"] = function()
    dapui.close()
  end


  local telescope = require('telescope')
  telescope.load_extension('dap')

  vim.keymap.set("n", "<leader>lc", dap.continue, { silent = true, desc="DAP  Continue" })
  vim.keymap.set("n", "<leader>lC", dap.run_to_cursor, { silent = true, desc="DAP  Run to cursor" })
  vim.keymap.set("n", "<leader>ld", function() dap.disconnect(); dap.close() end, { silent = true, desc="DAP disconnect" })
  vim.keymap.set("n", "<leader>lk", function() dap.terminate(); dap.close() end, { silent = true, desc="DAP terminate" })
  vim.keymap.set("n", "<leader>lb", dap.toggle_breakpoint, { silent = true, desc="DAP toggle breakpoint" })
  vim.keymap.set("n", "<leader>lB", function() dap.set_breakpoint(vim.fn.input("Breakpoint condition: ")) end, { silent = true, desc="DAP set breakpoint with condition" })
  vim.keymap.set("n", "<leader>lE", dap.set_exception_breakpoints, { silent = true, desc="DAP set exception breakpoint" })
  vim.keymap.set("n", "<leader>lt", dapui.toggle, { silent = true, desc="DAP toggle UI" })
  vim.keymap.set("n", "<leader>ls", dap.step_over, { silent = true, desc="DAP  step over" })
  vim.keymap.set("n", "<F8>",       dap.step_over, { silent = true, desc="DAP  step over" })
  vim.keymap.set("n", "<leader>li", dap.step_into, { silent = true, desc="DAP  step into" })
  vim.keymap.set("n", "<F7>",       dap.step_into, { silent = true, desc="DAP  step into" })
  vim.keymap.set("n", "<leader>lo", dap.step_out, { silent = true, desc="DAP  step out" })
  vim.keymap.set("n", "<F6>",       dap.step_out, { silent = true, desc="DAP  step out" })
  vim.keymap.set("n", "<leader>lp", dap.pause, { silent = true, desc="DAP  pause" })
  vim.keymap.set("n", "<F5>",       dap.pause, { silent = true, desc="DAP  pause" })
  -- Evaluate highlighted text as expression in float
  vim.keymap.set("v", "<leader>h", dapui.eval, { silent = true, desc="DAP hover" })
  vim.keymap.set("v", "<leader>lr", dap.restart, { silent = true, desc="DAP restart" })
end

return {
  {
    'mfussenegger/nvim-dap',
    lazy = true,
    dependencies = {
      'theHamsta/nvim-dap-virtual-text',
      'nvim-neotest/nvim-nio', -- dependency of dap-ui
      'rcarriga/nvim-dap-ui',
      'nvim-telescope/telescope-dap.nvim'
      -- Plug 'rcarriga/cmp-dap'
    },
    config = setup_dap
  },
}
