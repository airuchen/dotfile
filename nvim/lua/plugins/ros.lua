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
    dependencies = {
      -- to make sure the builder is there
      'skywind3000/asyncrun.vim',
    },
    opts = {
      options = {
        launcher = function(cmd, cwd)
          local asyncrun_opts = { cwd = cwd }
          vim.call("asyncrun#run", "", asyncrun_opts, cmd)
        end
      },
      keys = {
        build = "<leader>b",
        test = "<leader>bt",
      },
      systems = {
        colcon = {
          opts = {
            cmake_args = { "-DCMAKE_CXX_FLAGS=-ggdb" },
            mixins = { "compile-commands", "ccache" },
            build = { "--symlink-install" },
          },
        },
        catkin = {
          opts = {
            build = { "-j12", "--no-notify" },
          },
        }
      }
    }
  },
}
