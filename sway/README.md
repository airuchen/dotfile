# Sway Window Manager Configuration

A modern, feature-rich Sway configuration with Waybar status bar, optimized for multi-monitor setups and productivity.

## 🌟 Features

- **Multi-monitor support** with monitor-specific workspaces
- **Waybar status bar** with system information and controls
- **Workspace management** - only shows active workspaces per monitor
- **Volume and brightness controls** - both GUI and keyboard shortcuts
- **Clipboard manager** with history (`cliphist`)
- **Screenshot functionality** - full screen and region selection
- **WiFi and Bluetooth menus** via wofi
- **Notification system** with mako
- **Modern aesthetics** with Catppuccin-inspired colors

## 📦 Dependencies

### Core Components
```bash
# Window manager and essentials
sudo apt install sway waybar wofi kitty mako

# Clipboard management
sudo apt install wl-clipboard cliphist

# Screenshot tools
sudo apt install grim slurp

# System controls
sudo apt install brightnessctl playerctl pulseaudio-utils

# File management
sudo apt install nautilus

# Audio control GUI (optional)
sudo apt install pavucontrol
```

### Fonts
```bash
# Install JetBrainsMono Nerd Font
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/JetBrainsMono.zip
unzip JetBrainsMono.zip -d ~/.local/share/fonts/
fc-cache -fv
```

### WiFi/Bluetooth Menu Dependencies
```bash
# For wofi WiFi menu
sudo apt install network-manager

# For wofi Bluetooth menu  
sudo apt install bluez bluez-utils

# Clone the wofi menu scripts
mkdir -p ~/.local/bin
git clone https://github.com/zbayoff/wofi-wifi-menu ~/.local/bin/wofi-wifi-menu
git clone https://github.com/nickclyde/wofi-bluetooth ~/.local/bin/wofi-bluetooth
```

## 🚀 Installation

### 1. Deploy Configuration Files
```bash
# Create sway config directory
mkdir -p ~/.config/sway ~/.config/waybar

# Link configuration files
ln -sf $(pwd)/sway_config ~/.config/sway/config
ln -sf $(pwd)/waybar/config ~/.config/waybar/config
ln -sf $(pwd)/waybar/style.css ~/.config/waybar/style.css
```

### 2. Set Up Wallpaper
```bash
# Place your wallpaper image
mkdir -p ~/Pictures
# Copy your wallpaper to ~/Pictures/BackgroundTeams_NODE.jpg
# Or update the path in sway_config
```

### 3. Configure Monitor Layout
Edit the monitor configuration in `sway_config` to match your setup:
```bash
# Example multi-monitor setup
output eDP-1 pos 3840 0    # Laptop screen
output DP-1 pos 0 0        # External monitor 1  
output DP-2 pos 0 0        # External monitor 2
output HDMI-A-1 pos 0 0    # HDMI monitor
```

## ⌨️ Key Bindings

### Window Management
- `Mod+Return` - Open terminal (kitty)
- `Mod+d` - Application launcher (wofi)
- `Mod+q` - Close window
- `Mod+f` - Fullscreen
- `Mod+Space` - Toggle floating mode
- `Mod+Shift+Space` - Swap focus tiling/floating

### Workspaces
- `Mod+1-0` - Switch to workspace 1-10
- `Mod+Shift+1-0` - Move container to workspace 1-10

### System Controls
- `Mod+Shift+c` - Reload configuration
- `Mod+Shift+e` - Exit sway
- `Mod+Shift+z` - Lock screen
- `Print` - Full screenshot
- `Mod+Print` - Region screenshot

### Media Controls
- `XF86AudioMute` - Toggle mute
- `XF86AudioLowerVolume/RaiseVolume` - Volume control
- `XF86MonBrightnessDown/Up` - Brightness control
- `XF86AudioPlay/Pause/Prev/Next` - Media controls

### Custom Menus
- `Mod+Ctrl+w` - WiFi menu
- `Mod+Ctrl+b` - Bluetooth menu
- `Mod+v` - Clipboard history
- `Mod+e` - File manager

## 🖥️ Monitor/Workspace Layout

Workspaces are assigned to specific monitors:
- **DP-2**: Workspaces 1 (primary monitor)
- **Other monitors**: Workspaces 2-10 distributed as needed

Waybar shows only relevant workspaces per monitor with high-contrast highlighting for the current workspace.

## 🎨 Waybar Modules

- **Workspaces** - Shows active workspaces (current monitor only)
- **Network** - WiFi connection status
- **Volume** - Audio level with controls
- **Brightness** - Screen brightness with controls  
- **Battery** - Battery status and percentage
- **Clock** - Date and time display

## 🔧 Customization

### Waybar Styling
Edit `waybar/style.css` to customize:
- Font size (currently 20px)
- Colors (Catppuccin-inspired theme)
- Module spacing and appearance

### Sway Configuration
Edit `sway_config` to modify:
- Key bindings
- Monitor layouts
- Startup applications
- Window rules

## 🛠️ Troubleshooting

### Waybar Not Starting
```bash
# Check if waybar is running in Wayland session
echo $WAYLAND_DISPLAY

# Restart waybar
pkill waybar && waybar &
```

### Clipboard Manager Issues
```bash
# Check if clipboard watchers are running
ps aux | grep "wl-paste.*cliphist"

# Restart clipboard manager
pkill -f "wl-paste.*cliphist"
# Sway will restart them automatically
```

### WiFi/Bluetooth Menus Not Working
```bash
# Ensure scripts are executable
chmod +x ~/.local/bin/wofi-wifi-menu/wofi-wifi-menu.sh
chmod +x ~/.local/bin/wofi-bluetooth/wofi-bluetooth

# Check if NetworkManager is running
systemctl status NetworkManager
```

## 📝 Notes

- Configuration is optimized for productivity with minimal visual clutter
- Workspaces auto-hide when empty for clean appearance
- High contrast current workspace indicator for easy identification
- All essential system controls accessible via waybar clicks/scrolls
- Notifications handled by mako with system integration

## 🔄 Updates

To update your configuration:
```bash
git pull
sway reload  # Apply changes
```
