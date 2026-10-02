#!/bin/bash
# Claude Code statusline. Reads JSON on stdin (schema: model, workspace, cost,
# context_window, rate_limits, session_id, session_name).
input=$(cat)
export LC_ALL=C

RESET='\033[0m'
DIM='\033[2m'
BLUE='\033[1;34m'
YELLOW='\033[1;33m'
GREEN='\033[32m'
RED='\033[1;31m'
CYAN='\033[36m'
MAGENTA='\033[35m'

model=$(jq -r '.model.display_name // "?"' <<<"$input")
cwd=$(jq -r '.workspace.current_dir // .cwd // "."' <<<"$input")
folder=$(basename "$cwd")

cost=$(jq -r '.cost.total_cost_usd // 0' <<<"$input")
cost_fmt=$(printf '$%.4f' "$cost")

dur_ms=$(jq -r '.cost.total_duration_ms // 0' <<<"$input")
dur_s=$((dur_ms / 1000))
timer_fmt="$((dur_s / 60))m $((dur_s % 60))s"

ctx_used=$(jq -r '.context_window.used_percentage // 0' <<<"$input")
ctx_left=$(jq -r '.context_window.remaining_percentage // (100 - '"$ctx_used"')' <<<"$input")
ctx_tokens=$(jq -r '.context_window.total_input_tokens // 0' <<<"$input")
ctx_size=$(jq -r '.context_window.context_window_size // 0' <<<"$input")
fmt_k() { awk -v n="$1" 'BEGIN{printf "%dk", int(n/1000)}'; }
ctx_tokens_k=$(fmt_k "$ctx_tokens")
ctx_size_k=$(fmt_k "$ctx_size")

bar_width=10
filled=$(( ctx_used * bar_width / 100 ))
[ "$filled" -gt "$bar_width" ] && filled=$bar_width
empty=$((bar_width - filled))
if [ "$ctx_used" -ge 80 ]; then bar_color=$RED
elif [ "$ctx_used" -ge 50 ]; then bar_color=$YELLOW
else bar_color=$GREEN
fi
bar=""
for ((i = 0; i < filled; i++)); do bar+="█"; done
for ((i = 0; i < empty; i++)); do bar+="·"; done

five_used=$(jq -r '.rate_limits.five_hour.used_percentage // empty' <<<"$input")
five_resets=$(jq -r '.rate_limits.five_hour.resets_at // empty' <<<"$input")
seven_used=$(jq -r '.rate_limits.seven_day.used_percentage // empty' <<<"$input")
seven_resets=$(jq -r '.rate_limits.seven_day.resets_at // empty' <<<"$input")

if [ -n "$five_used" ]; then
  five_left=$((100 - five_used))
  five_time=$(date -r "$five_resets" +%H:%M 2>/dev/null)
  line3_5h="${CYAN}⏳ 5h ${five_left}% left →${five_time}${RESET}"
else
  line3_5h="${CYAN}⏳ 5h --${RESET}"
fi

if [ -n "$seven_used" ]; then
  seven_left=$((100 - seven_used))
  seven_time=$(LC_TIME=C date -r "$seven_resets" "+%a %H:%M" 2>/dev/null)
  line3_7d="${MAGENTA}📅 7d: ${seven_left}% left →${seven_time}${RESET}"
else
  line3_7d="${MAGENTA}📅 7d: --${RESET}"
fi

git_seg=""
if git -C "$cwd" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  branch=$(git -C "$cwd" branch --show-current 2>/dev/null)
  dirty=""
  [ -n "$(git -C "$cwd" status --porcelain 2>/dev/null)" ] && dirty="*"
  git_seg=" ${DIM}|${RESET} ${GREEN}🌿 ${branch}${dirty}${RESET}"
fi

caveman_badge_script="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/plugins/marketplaces/caveman/src/hooks/caveman-statusline.sh"
badge=""
[ -f "$caveman_badge_script" ] && badge=$(bash "$caveman_badge_script" 2>/dev/null)
tag_seg=""
[ -n "$badge" ] && tag_seg=" ${DIM}|${RESET} ${badge}"

line1="${BLUE}[${model}]${RESET} ${DIM}|${RESET} ${YELLOW}📂 ${folder}${RESET}${git_seg}${tag_seg}"
line2="${bar_color}${bar}${RESET} ${ctx_used}% (${ctx_tokens_k}/${ctx_size_k}, ${ctx_left}% left) ${DIM}|${RESET} ${GREEN}${cost_fmt}${RESET} ${DIM}|${RESET} 🍅 ${timer_fmt}"
line3="${line3_5h} ${DIM}|${RESET} ${line3_7d}"

printf '%b\n%b\n%b\n' "$line1" "$line2" "$line3"
