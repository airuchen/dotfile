#!/bin/bash

get_windows() {
    swaymsg -t get_tree | jq -r '
        .. | 
        objects | 
        select(.type == "con" and (.nodes | length) == 0 and .name != null and (.app_id != null or .window_properties.class != null)) |
        {
            id: .id,
            app_id: (.app_id // .window_properties.class // "unknown"),
            name: .name,
            workspace: (.workspace // "unknown"),
            focused: .focused,
            urgent: .urgent
        } |
        select(.app_id != "__i3_scratch") |
        "\(.id)|\(.app_id)|\(.name)|\(.workspace)|\(.focused)|\(.urgent)"
    ' 2>/dev/null
}

format_for_wofi() {
    while IFS='|' read -r id app_id name workspace focused urgent; do
        [ -z "$id" ] || [ -z "$app_id" ] || [ -z "$name" ] && continue
        
        case "${app_id,,}" in
            "kitty"|"alacritty"|"foot") icon="⚡" ;;
            "brave-browser"|"brave"|"firefox"|"chromium") icon="🌐" ;;
            "nautilus"|"thunar"|"pcmanfm") icon="📁" ;;
            "code"|"nvim"|"vim") icon="💻" ;;
            "discord"|"slack") icon="💬" ;;
            "spotify"|"rhythmbox") icon="🎵" ;;
            "libreoffice"*|"writer"|"calc") icon="📄" ;;
            "gimp"|"inkscape") icon="🎨" ;;
            "pavucontrol") icon="🔊" ;;
            "blueman"*) icon="📶" ;;
            "logseq") icon="📝" ;;
            *) icon="🪟" ;;
        esac
        
        [ ${#name} -gt 50 ] && name="${name:0:47}..."
        
        if [ "$focused" = "true" ]; then
            indicator="● "
        elif [ "$urgent" = "true" ]; then
            indicator="🔴 "
        else
            indicator=""
        fi
        
        printf "%s%s %s (WS %s) - %s|%s\n" "$indicator" "$icon" "$app_id" "$workspace" "$name" "$id"
    done
}

main() {
    for cmd in wofi swaymsg jq; do
        command -v "$cmd" >/dev/null 2>&1 || { echo "Error: $cmd is not installed" >&2; exit 1; }
    done
    
    window_list=$(get_windows | format_for_wofi | sort)
    [ -z "$window_list" ] && { echo "No windows found" >&2; exit 1; }
    
    selected=$(echo "$window_list" | wofi \
        --dmenu \
        --prompt "Switch to Window" \
        --width 60% \
        --height 50% \
        --cache-file /dev/null \
        --matching fuzzy \
        --insensitive)
    
    if [ -n "$selected" ]; then
        window_id=$(echo "$selected" | cut -d'|' -f2)
        [ -n "$window_id" ] && [ "$window_id" -gt 0 ] 2>/dev/null && swaymsg "[con_id=$window_id]" focus 2>/dev/null
    fi
}

main "$@"
