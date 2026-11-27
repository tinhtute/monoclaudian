#!/usr/bin/env bash
# Offline fallback: draw an apply_ops ops file in the tldraw offline desktop app through its local HTTP API.
# Usage:
#   tl.sh draw <file.tldraw> <ops.json>       create the file if missing, replace the ops' ids, run them
#   tl.sh png  <file.tldraw> <out.png> [maxpx]  export the page as PNG (default max side 2000px)
#   tl.sh exec <file.tldraw> <code.js>        run arbitrary editor code
#   tl.sh search <code.js>                    query the Editor API spec
set -euo pipefail
DIR=$(cd "$(dirname "$0")" && pwd)
F="$HOME/Library/Application Support/tldraw/server.json"
[ -f "$F" ] || { echo "error: tldraw offline is not running (no $F); open the tldraw app first" >&2; exit 1; }
PORT=$(jq -r .port "$F"); TOKEN=$(jq -r .token "$F"); B="http://localhost:$PORT"
post() { curl -sf "$B$1" -X POST -H 'content-type: application/json' -H "Authorization: Bearer $TOKEN" -d "$2"; }
abs() { (cd "$(dirname "$1")" && printf '%s/%s' "$(pwd -P)" "$(basename "$1")"); }
docid() { printf 'tldr:file:%s' "$(printf %s "$(abs "$1")" | base64 | tr -d '=\n')"; }
ready() { post "/api/doc/$(docid "$1")/exec" '{"code":"return 1"}' >/dev/null 2>&1; }
ensure() {
  if [ ! -f "$1" ]; then
    local name; name=$(basename "$1" .tldraw)
    post /api/docs/create "$(jq -n --arg n "$name" --arg d "$(cd "$(dirname "$1")" && pwd -P)" '{name:$n,directory:$d}')" >/dev/null
    return 0
  fi
  ready "$1" && return 0
  open "$1"   # an existing file must be open in the app before the API can reach it
  for _ in $(seq 1 40); do sleep 0.25; ready "$1" && return 0; done
  echo "error: $1 did not open in tldraw" >&2; exit 1
}
run() { post "/api/doc/$(docid "$1")/exec" "$(jq -Rs '{code:.}' < "$2")"; }
case "${1:-}" in
  draw)
    ensure "$2"
    { printf 'const OPS = '; jq -c '.ops' "$3"; printf ';\n'; cat "$DIR/ops-offline.js"; } | jq -Rs '{code:.}' \
      | curl -sf "$B/api/doc/$(docid "$2")/exec" -X POST -H 'content-type: application/json' -H "Authorization: Bearer $TOKEN" -d @- \
      | jq -ce '{success, error, n: .result.n, applied: .result.applied, lints: [.result.lints.new[]?.message]} | ., (.success == true)' ;;
  png)
    ensure "$2"
    run "$2" "$DIR/export-png.js" | jq -er .result | base64 -d > "$3"
    sips -Z "${4:-2000}" "$3" >/dev/null && echo "wrote $3" ;;
  exec) run "$2" "$3" ;;
  search) post /api/search "$(jq -Rs '{code:.}' < "$2")" ;;
  *) sed -n '2,7p' "$0"; exit 2 ;;
esac
