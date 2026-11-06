#!/usr/bin/env bash
# Every skills/*/SKILL.md opens with YAML frontmatter whose `name` equals its
# directory and whose `description` is non-empty.
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
fail=0
count=0
for d in "$root"/skills/*/; do
  dir=$(basename "$d")
  f="$d/SKILL.md"
  count=$((count + 1))
  if [ ! -f "$f" ]; then echo "$dir: missing SKILL.md"; fail=1; continue; fi
  if [ "$(head -n 1 "$f")" != "---" ] || [ "$(awk '/^---$/{n++} END{print n+0}' "$f")" -lt 2 ]; then
    echo "$dir: SKILL.md has no YAML frontmatter"; fail=1; continue
  fi
  fm=$(awk '/^---$/{n++;next} n==1{print} n>=2{exit}' "$f")
  name=$(printf '%s\n' "$fm" | sed -n 's/^name:[[:space:]]*//p' | head -n 1 | sed -e 's/[[:space:]]*$//' -e "s/^[\"']//" -e "s/[\"']$//")
  # description: inline value, or a block/folded scalar with indented lines after it
  desc=$(printf '%s\n' "$fm" | awk '
    /^description:/ { v=$0; sub(/^description:[[:space:]]*/, "", v); if (v !~ /^[|>][-+]?$/ && v != "") { print v; exit } blk=1; next }
    blk && /^[[:space:]]+[^[:space:]]/ { print; exit }
    blk && /^[^[:space:]]/ { exit }')
  [ "$name" = "$dir" ] || { echo "$dir: frontmatter name '$name' does not match directory"; fail=1; }
  case "$(printf '%s' "$desc" | tr -d "[:space:]\"'")" in
    "") echo "$dir: empty description"; fail=1 ;;
  esac
done
[ "$count" -gt 0 ] || { echo "no skills/*/ directories found"; exit 1; }
[ "$fail" -eq 0 ] && echo "skills OK ($count skills)"
exit "$fail"
