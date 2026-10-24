#!/usr/bin/env bash
# Waybar module: mouse sensitivity, scroll speed and battery

STATE="$HOME/.local/state/hypr-mouse.lua"

sens=0.0
scroll=0.3
mode=sens
if [[ -f "$STATE" ]]; then
    sens=$(grep -oP 'sensitivity = \K[-0-9.]+' "$STATE" || echo 0.0)
    scroll=$(grep -oP 'scroll_factor = \K[-0-9.]+' "$STATE" || echo 0.3)
    mode=$(grep -oP 'mode = "\K[a-z]+' "$STATE" || echo sens)
fi

# calc "expression" min max -> result clamped to range, one decimal
calc() { awk "BEGIN { v = $1; if (v < $2) v = $2; if (v > $3) v = $3; printf \"%.1f\", v }"; }

save_state() {
    mkdir -p "$(dirname "$STATE")"
    printf 'return {\n    sensitivity = %s,\n    scroll_factor = %s,\n    mode = "%s",\n}\n' \
        "$sens" "$scroll" "$mode" > "$STATE"
}

refresh_bar() { pkill -RTMIN+8 waybar; }

apply() {
    save_state
    hyprctl reload > /dev/null
    refresh_bar
}

case "$1" in
    up)
        if [[ "$mode" == "sens" ]]; then sens=$(calc "$sens + 0.1" -1 1)
        else scroll=$(calc "$scroll + 0.1" 0.1 2); fi
        apply ;;
    down)
        if [[ "$mode" == "sens" ]]; then sens=$(calc "$sens - 0.1" -1 1)
        else scroll=$(calc "$scroll - 0.1" 0.1 2); fi
        apply ;;
    toggle)
        [[ "$mode" == "sens" ]] && mode=scroll || mode=sens
        save_state
        refresh_bar ;;
    reset)
        sens=0.0; scroll=0.3
        apply ;;
    menu)
        choice=$(printf "Preset: Default\nPreset: Precise\nPreset: Fast\nReconnect mouse" \
            | fuzzel --dmenu --prompt "Mouse: " --lines 4 --width 25)
        case "$choice" in
            "Preset: Default") sens=0.0;  scroll=0.3; apply ;;
            "Preset: Precise") sens=-0.3; scroll=0.2; apply ;;
            "Preset: Fast")    sens=0.4;  scroll=0.5; apply ;;
            "Reconnect mouse") sudo systemctl restart logid ;;
        esac
        ;;
    *)

        hl() { printf "<span color='#7aa2f7'><b>%s</b></span>" "$1"; }
        if [[ "$mode" == "sens" ]]; then
            s_txt=$(hl "$sens"); r_txt="$scroll"; active="sensitivity"
        else
            s_txt="$sens"; r_txt=$(hl "$scroll"); active="scroll factor"
        fi

        icon=$'\uf245'
        tooltip="MX Master 3S\\nSensitivity: $sens\\nScroll factor: $scroll"
        tooltip="$tooltip\\n\\nScroll: adjust $active\\nRight click: switch target\\nClick: presets\\nMiddle click: reset"
        printf '{"text": "%s %s · %s", "tooltip": "%s"}\n' "$icon" "$s_txt" "$r_txt" "$tooltip"
        ;;
esac
