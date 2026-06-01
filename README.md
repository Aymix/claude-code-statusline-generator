# Claude Code Status Line

A colorful status line for [Claude Code](https://claude.com/claude-code). It shows your working directory, model, two usage progress bars (context window and 5-hour rate limit), and a token breakdown — all in one line under your prompt.

## What it looks like

```
~/work/my-project  Claude Sonnet:medium  ctx:[█░░░░░░░░░] 12%  total:[███░░░░░░░] 34%  kv:1.1M  in:24.3k  out:8.7k  tok:33.0k
```

| Segment | Color | Meaning |
|---------|-------|---------|
| `~/work/my-project` | bold blue | Current working directory |
| `Claude Sonnet` | cyan | Model name |
| `:medium` | grey | Effort level (only shown when set) |
| `ctx:[bar] 12%` | yellow | Context window used — how full this conversation's memory is |
| `total:[bar] 34%` | orange | 5-hour rate-limit (subscription) usage — hidden when unavailable |
| `kv:1.1M` | magenta | Tokens read from cache this turn — hidden when zero |
| `in:24.3k` | green | Cumulative input tokens this session |
| `out:8.7k` | red | Cumulative output tokens this session |
| `tok:33.0k` | white | Total tokens (in + out + cache reads) |

Both percentages render as 10-block bars (`█` filled, `░` empty).

## Web generator

Don't want to hand-edit the script? Use the visual builder — toggle segments, pick colors and labels, reorder, and watch a live preview. Then **copy a ready-to-paste prompt** for Claude Code or **download a Markdown spec**.

**Live:** https://aymix.github.io/claude-code-statusline-generator/

Or open `index.html` from this repo directly in your browser (it's a single file, no build step).

## Install

### Option A — installer

```bash
git clone https://github.com/Aymix/claude-code-statusline-generator.git
cd claude-code-statusline-generator
./install.sh
```

The installer copies the script to `~/.claude/statusline-command.sh` and registers it in `~/.claude/settings.json` (it leaves any other settings untouched).

### Option B — manual

1. Copy `statusline-command.sh` to `~/.claude/statusline-command.sh` and make it executable:

   ```bash
   cp statusline-command.sh ~/.claude/statusline-command.sh
   chmod +x ~/.claude/statusline-command.sh
   ```

2. Add this to `~/.claude/settings.json` (create the file if it doesn't exist):

   ```json
   {
     "statusLine": {
       "type": "command",
       "command": "bash ~/.claude/statusline-command.sh"
     }
   }
   ```

3. Restart Claude Code, or ask it to "reload the status line".

## Requirements

- `jq`
- `awk` (preinstalled on macOS and Linux)
- `bash`
- A terminal with 256-color support (any modern terminal)

## Customize

**Colors** — change the ANSI code in the relevant `printf` line:

| Code | Color |
|------|-------|
| `\033[91m` | bright red |
| `\033[92m` | bright green |
| `\033[93m` | bright yellow |
| `\033[94m` | bright blue |
| `\033[95m` | bright magenta |
| `\033[96m` | bright cyan |
| `\033[97m` | bright white |
| `\033[38;5;214m` | orange |
| `\033[0;37m` | grey |

**Bar width** — change `width=10` inside `make_bar`.

**Labels** — the `ctx:`, `total:`, `kv:`, `in:`, `out:`, `tok:` text lives in the `printf` lines; edit it to taste.

## Notes

- `total:` (the orange bar) is the rolling **5-hour** rate-limit window, not a weekly or monthly plan total — that's the only longer-term figure Claude Code hands the status line.
- `tok:` adds the current turn's cache reads (`kv:`) on top of cumulative `in` + `out`. Cache reads are a per-turn figure, so this number moves around turn to turn rather than only growing.
- `kv:`, `in:`, `out:`, `tok:`, and the rate-limit bar only show real values if your Claude Code build sends those fields. Anything it doesn't send is hidden or shown as `0`.

## License

MIT
