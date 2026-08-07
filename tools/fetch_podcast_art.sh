#!/usr/bin/env bash
# fetch_podcast_art.sh — refresh the Apple Podcasts demo's cover art.
#
# Looks up each show below on the public iTunes Search API, downloads its
# artwork into example/assets/podcast_images/<itunesId>.jpg, and writes
# example/assets/podcast_images/MANIFEST.tsv with the exact id / title /
# author iTunes returned for each — paste that back so the demo's
# title/author/itunesId fields can be updated to match precisely.
#
# Requires: curl, python3 (stdlib only, no extra packages).
#
# Usage:
#   ./tools/fetch_podcast_art.sh
#
# Run from anywhere; paths below are resolved relative to the repo root.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="$REPO_ROOT/example/assets/podcast_images"
MANIFEST="$OUT_DIR/MANIFEST.tsv"

mkdir -p "$OUT_DIR"
: > "$MANIFEST"
printf 'search_term\titunes_id\tcollection_name\tartist_name\timage_file\n' >> "$MANIFEST"

# One search term per show — picked to be unambiguous enough that the first
# iTunes search hit is the right show. Edit this list to swap shows in/out.
SHOWS=(
  "This American Life"
  "Radiolab"
  "The Tim Ferriss Show"
  "Pod Save America"
  "The Joe Rogan Experience"
  "Call Her Daddy"
  "Office Ladies"
  "WTF with Marc Maron"
  "Science Vs"
  "Criminal podcast Vox"
  "Revisionist History Malcolm Gladwell"
  "The Indicator from Planet Money"
  "You're Wrong About"
  "Up First NPR"
  "Fresh Air NPR"
  "How I Built This Guy Raz"
  "Song Exploder"
  "Modern Love New York Times"
)

echo "Fetching artwork for ${#SHOWS[@]} shows into $OUT_DIR ..."
echo

fail=0
for term in "${SHOWS[@]}"; do
  echo "-> $term"

  result_json=$(curl -sS -m 20 -G "https://itunes.apple.com/search" \
    --data-urlencode "term=$term" \
    --data-urlencode "entity=podcast" \
    --data-urlencode "limit=1") || {
    echo "   curl failed for: $term" >&2
    fail=1
    continue
  }

  # Extract id / title / author / artwork URL from the first result.
  #
  # NOTE: this intentionally uses `python3 -c` rather than a heredoc — bash
  # 3.2 (still macOS's default /bin/bash) has a parser bug where a heredoc
  # nested inside a `<(...)` process substitution can fail with
  # "bad substitution: no closing `)' in <(" even though the syntax is
  # valid. Passing the script via -c sidesteps it.
  #
  # IFS is scoped to tab-only for this read: show titles/authors contain
  # spaces, and the default IFS (space+tab) would otherwise split each word
  # of "This American Life" into its own field instead of keeping the
  # tab-delimited columns intact.
  IFS=$'\t' read -r itunes_id collection_name artist_name artwork_url < <(
    python3 -c '
import json, sys

data = json.loads(sys.argv[1])
results = data.get("results") or []
if not results:
    print("", "", "", "")
    sys.exit(0)

r = results[0]
track_id = r.get("collectionId") or r.get("trackId") or ""
name = r.get("collectionName") or r.get("trackName") or ""
artist = r.get("artistName") or ""
artwork = r.get("artworkUrl600") or ""
if not artwork:
    artwork = r.get("artworkUrl100", "")
    # Upsize the default 100x100 thumbnail to a larger crop if that is all we got.
    artwork = artwork.replace("100x100bb", "600x600bb")

# Tab-separated, single line — caller reads it back with `read`.
print(track_id, name.replace("\t", " "), artist.replace("\t", " "), artwork, sep="\t")
' "$result_json"
  )

  if [[ -z "$itunes_id" || -z "$artwork_url" ]]; then
    echo "   no result for: $term" >&2
    fail=1
    continue
  fi

  image_path="$OUT_DIR/$itunes_id.jpg"
  if curl -sSL -m 30 "$artwork_url" -o "$image_path"; then
    echo "   saved $itunes_id.jpg  ($collection_name — $artist_name)"
    printf '%s\t%s\t%s\t%s\t%s\n' \
      "$term" "$itunes_id" "$collection_name" "$artist_name" "$itunes_id.jpg" >> "$MANIFEST"
  else
    echo "   download failed for: $term ($artwork_url)" >&2
    fail=1
  fi
done

echo
echo "Manifest written to $MANIFEST"
if [[ "$fail" -ne 0 ]]; then
  echo "One or more shows failed — see warnings above. Re-run or adjust SHOWS and retry." >&2
  exit 1
fi
echo "Done. Share MANIFEST.tsv back so apple_podcasts_demo.dart can be updated to match."
