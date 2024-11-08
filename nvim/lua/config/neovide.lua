-- GUI
if vim.fn.has("gui_running") == 1 then
  -- guifont=DejaVu_Sans_Mono:h9:cANSI -- windows
  vim.o.guifont = "DejaVu Sans Mono:h11"
  -- o.guifont = "FiraCode Nerd Font:Retina:h11"
  -- TODO: Not needed?
  -- o.guioptions = ""
end

-- Neovide settings
if vim.g.neovide then
  vim.g.neovide_fullscreen = false
  vim.g.neovide_remember_window_position = false
  vim.g.neovide_remember_window_size = false
  vim.g.neovide_scroll_animation_length = 0
  vim.g.neovide_cursor_animation_length = 0.0
  vim.g.neovide_cursor_trail_size = 0.1
  vim.g.neovide_cursor_vfx_mode = "railgun"
  vim.g.neovide_cursor_vfx_particle_lifetime = 0.5
  vim.g.neovide_hide_mouse_when_typing = true
end
