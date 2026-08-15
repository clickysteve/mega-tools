#!/bin/sh
# Sync the single-file tools (and the webplayer, if it's landed upstream) from
# genmddj's own user-tools/ into this repo. Run from the repo root:
#
#   ./sync-tools.sh
#
# It clones/pulls upstream into a scratch folder, copies the current set of
# files over, and reports what actually changed so you can review the diff
# before committing. It does NOT touch tools.json for you -- if genmddj adds
# a brand new tool, you'll see a new file appear under tools/ with no card
# for it yet; add one entry to tools.json by hand, same as always.

set -e

UPSTREAM="https://github.com/little-scale/genmddj.git"
SCRATCH="/tmp/genmddj-sync"

# single-file tools -- copied as-is into tools/
SINGLE_FILES="
als2genmddj.html
de-re-interleaver.html
genmddj-bank-editor.html
genmddj-font-patcher.html
genmddj-instrument-patcher.html
genmddj-kit-patcher.html
genmddj-palette-patcher.html
genmddj-savetool.html
genmddj-wave-editor.html
"

echo "Fetching latest genmddj..."
if [ -d "$SCRATCH/.git" ]; then
  git -C "$SCRATCH" fetch origin >/dev/null 2>&1
  git -C "$SCRATCH" checkout master >/dev/null 2>&1
  git -C "$SCRATCH" merge origin/master --ff-only >/dev/null 2>&1
else
  git clone --quiet "$UPSTREAM" "$SCRATCH"
fi

mkdir -p tools
CHANGED=""

for f in $SINGLE_FILES; do
  src="$SCRATCH/user-tools/$f"
  dst="tools/$f"
  if [ ! -f "$src" ]; then
    echo "  ! $f no longer exists upstream -- left the local copy alone, worth checking why"
    continue
  fi
  if [ ! -f "$dst" ] || ! cmp -s "$src" "$dst"; then
    cp "$src" "$dst"
    CHANGED="$CHANGED  $f\n"
  fi
done

# webplayer: only synced if it exists upstream (i.e. the PR has been merged).
# Until then this is a no-op and your local copy (from the fork) is untouched.
if [ -d "$SCRATCH/user-tools/webplayer" ]; then
  mkdir -p webplayer
  for f in "$SCRATCH"/user-tools/webplayer/*; do
    name=$(basename "$f")
    dst="webplayer/$name"
    if [ ! -f "$dst" ] || ! cmp -s "$f" "$dst"; then
      cp "$f" "$dst"
      CHANGED="$CHANGED  webplayer/$name\n"
    fi
  done
fi

# flag any upstream tool this repo doesn't have a tools.json entry for yet
echo ""
echo "Checking for tools not yet listed in tools.json..."
for f in $SINGLE_FILES; do
  if [ -f "$SCRATCH/user-tools/$f" ] && ! grep -q "\"tools/$f\"" tools.json 2>/dev/null; then
    echo "  ! tools/$f exists but has no tools.json entry"
  fi
done

echo ""
if [ -n "$CHANGED" ]; then
  echo "Updated:"
  printf "$CHANGED"
  echo ""
  echo "Review with: git diff"
  echo "Then commit and push as usual."
else
  echo "Nothing changed, already up to date."
fi
