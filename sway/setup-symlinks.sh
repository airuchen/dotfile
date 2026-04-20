#!/bin/bash

# Setup script for symlinking dotfiles
# Run from the sway dotfiles directory

set -e  # Exit on any error

DOTFILES_DIR="$(pwd)"
CONFIG_DIR="$HOME/.config"

echo "🔗 Setting up symbolic links for dotfiles..."
echo "📁 Dotfiles directory: $DOTFILES_DIR"
echo "📁 Config directory: $CONFIG_DIR"
echo ""

# Function to create symlink with backup
create_symlink() {
    local source="$1"
    local target="$2"
    local name="$3"

    echo "📋 Setting up $name..."

    # Create parent directory if it doesn't exist
    mkdir -p "$(dirname "$target")"

    # Handle existing files/directories
    if [[ -e "$target" ]] || [[ -L "$target" ]]; then
        if [[ -L "$target" ]]; then
            echo "   🔗 Removing existing symlink: $target"
            rm "$target"
        else
            echo "   📦 Backing up existing: $target → ${target}.backup"
            mv "$target" "${target}.backup"
        fi
    fi

    # Create the symlink
    ln -s "$source" "$target"
    echo "   ✅ Created symlink: $target → $source"
    echo ""
}

# Waybar configuration
create_symlink \
    "$DOTFILES_DIR/waybar" \
    "$CONFIG_DIR/waybar" \
    "Waybar"

# Wofi configuration  
create_symlink \
    "$DOTFILES_DIR/wofi" \
    "$CONFIG_DIR/wofi" \
    "Wofi"

# Sway configuration
create_symlink \
    "$DOTFILES_DIR/sway_config" \
    "$CONFIG_DIR/sway/config" \
    "Sway"

# SwayNC configuration
create_symlink \
    "$DOTFILES_DIR/swaync" \
    "$CONFIG_DIR/swaync" \
    "SwayNC"

# Satty configuration
create_symlink \
    "$DOTFILES_DIR/satty" \
    "$CONFIG_DIR/satty" \
    "Satty"

echo "🎉 All symbolic links created successfully!"
echo ""
echo "📋 Summary:"
echo "   waybar/     → ~/.config/waybar/"
echo "   wofi/       → ~/.config/wofi/"
echo "   sway_config → ~/.config/sway/config"
echo "   swaync/     → ~/.config/swaync/"
echo "   satty/      → ~/.config/satty/"
echo ""
echo "💡 To reload configurations:"
echo "   • Waybar: killall waybar && waybar &"
echo "   • Sway: sway reload (or Mod+Shift+C)"
echo "   • SwayNC: killall swaync && swaync &"
echo "   • Wofi: No reload needed" 
