-- Themes to install
--
return {
  -- main color scheme should not be lazy
  {
    'folke/tokyonight.nvim',
    lazy = false,
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
  { 'ellisonleao/gruvbox.nvim',       lazy = true, config = true },
  { "rebelot/kanagawa.nvim",          lazy = true, config = true },
  { "craftzdog/solarized-osaka.nvim", lazy = true, config = true }
}
