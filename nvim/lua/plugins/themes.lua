-- Themes to install
local theme = "gruvbox"

return {
  -- main color scheme should not be lazy
  {
    'folke/tokyonight.nvim',
    lazy = (theme ~= "tokyonight"),
    priority = 1000,
    config = function()
      require("tokyonight").setup({
        style = "night",
        light_style = "day",
        day_brightness = 0.5
      })
      vim.cmd.colorscheme("tokyonight")
    end
  },
  {
    'ellisonleao/gruvbox.nvim',
    lazy = (theme ~= "gruvbox"),
    priority = 1000,
    config = function()
      require("gruvbox").setup({})
      vim.cmd.colorscheme("gruvbox")
    end
  },
  {
    "rebelot/kanagawa.nvim",
    lazy = (theme ~= "kanagawa"),
    priority = 1000,
    config = function()
      require("kanagawa").setup({})
      vim.cmd.colorscheme("kanagawa")
    end
  },
  {
    "craftzdog/solarized-osaka.nvim",
    lazy = (theme ~= "solarized-osaka"),
    priority = 1000,
    config = function()
      require("solarized-osaka").setup({})
      vim.cmd.colorscheme("kanagawa")
    end
  }
}
