#!/usr/bin/env bash
# Claude Code custom status line.
#
#   <cwd>  <model>:<effort>  ctx:[bar] %  total:[bar] %  kv:<cached>  in:<tok>  out:<tok>  tok:<tok>
#
# Segments hide themselves when their data is unavailable (effort, the rate-limit
# bar, and kv all disappear when Claude Code doesn't report them).

# The status line runs in a bare shell without your interactive PATH, so make
# jq/awk findable across the common install locations.
export PATH="/opt/homebrew/bin:/usr/local/bin:/home/linuxbrew/.linuxbrew/bin:/usr/bin:/bin:$PATH"

input=$(cat)
cwd=$(echo "$input" | jq -r '.cwd')

display_name=$(echo "$input" | jq -r '.model.display_name // "Claude"')
effort=$(echo "$input" | jq -r '.effort.level // empty')

used_pct=$(echo "$input" | jq -r 'if .context_window.used_percentage == null then 0 else (.context_window.used_percentage + 0.5 | floor) end')
rl_pct=$(echo "$input" | jq -r 'if .rate_limits.five_hour.used_percentage == null then "" else (.rate_limits.five_hour.used_percentage + 0.5 | floor | tostring) end')

# Human-readable token counts (1.1M / 24.3k / 980). Uses awk so there is no bc dependency.
fmt_tokens() {
    awk -v n="${1:-0}" 'BEGIN{
        if (n+0 >= 1000000)   printf "%.1fM", n/1000000;
        else if (n+0 >= 1000) printf "%.1fk", n/1000;
        else                  printf "%d", n;
    }'
}

# 10-block progress bar for a 0-100 percentage: ████░░░░░░
make_bar() {
    local pct=${1:-0} width=10 filled empty bar="" i
    filled=$(( pct * width / 100 ))
    [ "$filled" -gt "$width" ] && filled=$width
    [ "$filled" -lt 0 ] && filled=0
    empty=$(( width - filled ))
    i=0; while [ $i -lt $filled ]; do bar="${bar}█"; i=$(( i + 1 )); done
    i=0; while [ $i -lt $empty ];  do bar="${bar}░"; i=$(( i + 1 )); done
    printf '%s' "$bar"
}

total_in=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
total_out=$(echo "$input" | jq -r '.context_window.total_output_tokens // 0')
cache_read=$(echo "$input" | jq -r '.context_window.current_usage.cache_read_input_tokens // 0')

# Working directory: bold blue
printf '\033[01;34m%s\033[00m' "$cwd"

# Model name: bright cyan
printf '  \033[96m%s\033[0m' "$display_name"

# Effort: grey (omit if unset)
if [ -n "$effort" ]; then
    printf '\033[0;37m:%s\033[0m' "$effort"
fi

# Context usage: bright yellow bar; 5-hour rate-limit usage: bright orange bar (omit if unavailable)
printf '  \033[93mctx:[%s] %s%%\033[0m' "$(make_bar "$used_pct")" "$used_pct"
if [ -n "$rl_pct" ]; then
    printf '  \033[38;5;214mtotal:[%s] %s%%\033[0m' "$(make_bar "$rl_pct")" "$rl_pct"
fi

# KV cache read this turn: bright magenta (omit if zero)
if [ "$cache_read" -gt 0 ] 2>/dev/null; then
    printf '  \033[95mkv:%s\033[0m' "$(fmt_tokens "$cache_read")"
fi

# in: bright green  out: bright red  tok: bright white (in + out + cache reads)
printf '  \033[92min:%s\033[0m' "$(fmt_tokens "$total_in")"
printf '  \033[91mout:%s\033[0m' "$(fmt_tokens "$total_out")"
total_all=$(( ${total_in:-0} + ${total_out:-0} + ${cache_read:-0} ))
printf '  \033[97mtok:%s\033[0m' "$(fmt_tokens "$total_all")"
