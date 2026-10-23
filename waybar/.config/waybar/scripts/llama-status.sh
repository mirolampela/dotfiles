#!/usr/bin/env bash
# Waybar module for llama-server (systemd user service)

SERVICE="llama-server"
URL="http://127.0.0.1:8080"

json() {
    # $1 = text, $2 = tooltip, $3 = class
    printf '{"text": "%s", "tooltip": "%s", "class": "%s"}\n' "$1" "$2" "$3"
}

# Hide module on machines without the service (e.g. laptop)
if ! systemctl --user cat "$SERVICE" &>/dev/null; then
    echo '{"text": ""}'
    exit 0
fi

if ! systemctl --user is-active --quiet "$SERVICE"; then
    json "LLM off" "llama-server: stopped\nLeft click: start" "stopped"
    exit 0
fi

code=$(curl -s -o /dev/null -w '%{http_code}' --max-time 1 "$URL/health")
if [[ "$code" != "200" ]]; then
    json "LLM ..." "llama-server: loading model...\nLeft click: stop" "loading"
    exit 0
fi

read -r used total < <(nvidia-smi --query-gpu=memory.used,memory.total \
    --format=csv,noheader,nounits | tr -d ',')

metrics=$(curl -s --max-time 1 "$URL/metrics")
tps=$(awk '/^llamacpp:predicted_tokens_seconds /{printf "%.0f", $2}' <<< "$metrics")
busy=$(awk '/^llamacpp:requests_processing /{print int($2)}' <<< "$metrics")
model=$(curl -s --max-time 1 "$URL/v1/models" | jq -r '.data[0].id // "unknown"')
model=$(basename "$model" .gguf)

tps=${tps:--}
class="running"
[[ "${busy:-0}" -gt 0 ]] && class="busy"

tooltip="Model: $model\nVRAM: ${used} / ${total} MiB\nAvg speed: ${tps} t/s\nActive requests: ${busy:-0}\n\nLeft click: stop\nRight click: open chat"

json "LLM ${tps} t/s" "$tooltip" "$class"
