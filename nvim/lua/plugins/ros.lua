return {
  {
    'taketwo/vim-ros',
    cond = function()
      return vim.fn.executable("ros2") == 1 or vim.fn.executable("rosrun") == 1
    end,
    config = function()
      vim.g.ros_make = 'current'
      vim.g.ros_build_system = 'catkin-tools'
      vim.g.ros_disable_warnings = 1
    end
  },

  {
    "bi0ha2ard/ros-builder.nvim",
    -- dir = "~/git/ros-builder.nvim/",
    dependencies = {
      'nvim-lua/plenary.nvim',
      -- to make sure the builder is there
      'skywind3000/asyncrun.vim',
    },
    config = function()
      local launcher = require('ros-builder.launchers').asyncrun_qf
      local colcon_opts = {
        cmake_args = { "-DCMAKE_CXX_FLAGS=-ggdb" },
        mixins = { "compile-commands", "ccache", "mold" },
        build = { "--symlink-install" },
      }
      require('ros-builder').setup({
        options = {
          launcher = launcher,
        },
        keys = {
          build = "<leader>b",
          test = "<leader>bt",
        },
        systems = {
          colcon_ninja = {
            opts = colcon_opts
          },
          colcon = {
            opts = colcon_opts
          },
          catkin = {
            opts = {
              build = { "-j12", "--no-notify" },
            },
          }
        }
      })
    end
  },
}
