#!/usr/bin/env bash
# SessionStart hook for x-agent-plugin plugin

set -euo pipefail

# Determine plugin root directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
PLUGIN_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Read using-x-agent-plugin content
using_xagent_plugin_content=$(cat "${PLUGIN_ROOT}/skills/using-x-agent-plugin/SKILL.md" 2>&1 || echo "Error reading using-x-agent-plugin skill")

# Escape outputs for JSON using pure bash
escape_for_json() {
    local input="$1"
    local output=""
    local i char
    for (( i=0; i<${#input}; i++ )); do
        char="${input:$i:1}"
        case "$char" in
            $'\\') output+='\\' ;;
            '"') output+='\"' ;;
            $'\n') output+='\n' ;;
            $'\r') output+='\r' ;;
            $'\t') output+='\t' ;;
            *) output+="$char" ;;
        esac
    done
    printf '%s' "$output"
}

using_xagent_plugin_escaped=$(escape_for_json "$using_xagent_plugin_content")

# Output context injection as JSON
cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "<EXTREMELY_IMPORTANT>\nYou have x-agent-plugin.\n\n**Below is the full content of your 'x-agent-plugin:using-x-agent-plugin' skill - your introduction to using skills. For all other skills, use the 'Skill' tool:**\n\n${using_xagent_plugin_escaped}\n</EXTREMELY_IMPORTANT>"
  }
}
EOF

exit 0
