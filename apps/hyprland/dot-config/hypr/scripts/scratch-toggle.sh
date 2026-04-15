#!/bin/sh

# Dependency Check
command -v jq >/dev/null 2>&1 || { echo >&2 "Error: 'jq' is required."; exit 1; }
command -v hyprctl >/dev/null 2>&1 || { echo >&2 "Error: 'hyprctl' is required."; exit 1; }

# Default values
TARGET_APP_ID=""
TARGET_TITLE=""
TARGET_CLASS=""
CMD=""

# Help Function
show_help() {
    cat << EOF
Usage: $(basename "$0") [MATCH OPTIONS] -- [COMMAND]

Matches a Hyprland window using REGEX and toggles its state (Focus <-> Special Workspace).
If the window does not exist, it executes the provided COMMAND.

Match Options (Supports Regex):
  -a, --app-id <regex> Match by Wayland App ID (initialClass)
  -t, --title <regex>  Match by Window Title
  -c, --class <regex>  Match by Window Class
  -h, --help           Show this help message

Examples:
  $(basename "$0") --app-id '^chrome-example\.com' -- chromium --app="https://example.com/"
  $(basename "$0") --title 'btop' -- foot -e btop
EOF
}

# Argument Parsing
while [ $# -gt 0 ]; do
    case "$1" in
        -h|--help) show_help; exit 0 ;;
        -a|--app-id) TARGET_APP_ID="$2"; shift 2 ;;
        -t|--title) TARGET_TITLE="$2"; shift 2 ;;
        -c|--class) TARGET_CLASS="$2"; shift 2 ;;
        --) shift; CMD="$*"; break ;;
        -*) echo "Error: Unknown option $1" >&2; show_help; exit 1 ;;
        *)
           if [ -z "$CMD" ]; then CMD="$*"; break; fi
           ;;
    esac
done

# Validation
if [ -z "$TARGET_APP_ID" ] && [ -z "$TARGET_TITLE" ] && [ -z "$TARGET_CLASS" ]; then
    echo "Error: You must provide at least one matching criteria." >&2
    exit 1
fi

if [ -z "$CMD" ]; then
    echo "Error: No command provided to execute." >&2
    exit 1
fi

# Derive a named special workspace so each scratchpad is isolated
# Strip regex/special chars so the workspace name is clean
SCRATCH_NAME="scratch_$(printf '%s' "${TARGET_APP_ID:-${TARGET_TITLE:-$TARGET_CLASS}}" | tr -dc 'a-zA-Z0-9_-')"

# Query Hyprland clients
window_info=$(hyprctl clients -j | jq \
    --arg app_id "$TARGET_APP_ID" \
    --arg title "$TARGET_TITLE" \
    --arg class "$TARGET_CLASS" \
    '
    .[] |
    select(
        ($app_id == "" or (.initialClass != null and (.initialClass | test($app_id)))) and
        ($title == "" or (.title != null and (.title | test($title)))) and
        ($class == "" or (.class != null and (.class | test($class))))
    ) |
    {address, "focused": .focusHistoryID == 0, workspace: .workspace}
    ' | jq -s '.[0] // empty')

# 1. No such window found -> launch new
if [ -z "$window_info" ]; then
    nohup $CMD >/dev/null 2>&1 &
    exit 0
fi

# Extract values
address=$(echo "$window_info" | jq -r '.address // empty')
focused=$(echo "$window_info" | jq -r '.focused // false')
workspace_name=$(echo "$window_info" | jq -r '.workspace.name // ""')

if [ -z "$address" ]; then echo "Error: Failed to get address."; exit 1; fi

# 2. Toggle Logic
if [ "$focused" = "true" ]; then
    # Focused -> hide to named special workspace
    hyprctl dispatch movetoworkspacesilent "special:$SCRATCH_NAME,address:$address"
elif echo "$workspace_name" | grep -q "^special"; then
    # In special workspace -> bring to current workspace and focus
    hyprctl --batch "dispatch movetoworkspace e+0,address:$address ; dispatch focuswindow address:$address"
else
    # On another workspace -> bring to current and focus
    hyprctl --batch "dispatch movetoworkspace e+0,address:$address ; dispatch focuswindow address:$address"
fi
