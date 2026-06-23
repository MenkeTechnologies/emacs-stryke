#!/usr/bin/env bash
# Regenerate stryke-stdlib.el from the stryke binary's own reflection tables, so
# the font-lock keywords carry the COMPLETE language surface (all ~10,450
# builtins) and never drift. Run after a stryke upgrade.
#
#   ./scripts/gen-stdlib.sh             # uses `stryke` on $PATH and `emacs`
#   STRYKE=/path/to/stryke EMACS=/path/to/emacs ./scripts/gen-stdlib.sh
#
# Sources of truth (the binary, not a hand-maintained list):
#   builtins : stryke -E 'p join "\n", sort keys %b'
#   parallel : stryke -E 'p join "\n", sort @{$c{parallel}}'
#
# The big alternations are precomputed with Emacs' own `regexp-opt` (a trie) so
# loading the package stays instant. All regexp work happens inside Emacs
# (scripts/gen-stdlib.el) — the shell only passes file paths + metadata.
set -euo pipefail

stryke="${STRYKE:-stryke}"
emacs_bin="${EMACS:-emacs}"
here="$(cd "$(dirname "$0")/.." && pwd)"
out="$here/stryke-stdlib.el"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

"$stryke" 'p join "\n", sort keys %b'         | sort -u > "$tmp/b.txt"
"$stryke" 'p join "\n", sort @{$c{parallel}}' | sort -u > "$tmp/par.txt"
ver="$("$stryke" --version 2>/dev/null | grep -oE 'v?[0-9]+\.[0-9]+\.[0-9]+' | head -1)"

comm -12 "$tmp/par.txt" "$tmp/b.txt" > "$tmp/par_in_b.txt"
printf 'true\nfalse\nundef\nnull\n' | sort -u > "$tmp/consts.txt"
comm -23 "$tmp/b.txt" "$tmp/par_in_b.txt" | comm -23 - "$tmp/consts.txt" > "$tmp/plain.txt"
nb="$(wc -l < "$tmp/b.txt" | tr -d ' ')"

"$emacs_bin" --batch -l "$here/scripts/gen-stdlib.el" \
  --eval "(stryke-gen \"$tmp/plain.txt\" \"$tmp/par_in_b.txt\" \"$out\" \"${ver:-unknown}\" \"$nb\")"

echo "wrote $out ($(wc -c < "$out" | tr -d ' ') bytes, $nb builtins, stryke ${ver:-unknown})"
