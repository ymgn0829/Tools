#!/usr/bin/env bash
# 配信用の静的ファイルを public/ に集める。
# node_modules など配信不要のものをここで落としておかないと、
# wrangler が自分でインストールした node_modules ごとアップロードしようとして落ちる。
# 使い方: BASE_URL=https://example.com bash build/build.sh
set -euo pipefail

cd "$(dirname "$0")/.."
OUT="${OUT_DIR:-public}"
BASE_URL="${BASE_URL:-https://tools.ymgn0829.workers.dev}"
BASE_URL="${BASE_URL%/}"

rm -rf "$OUT"
mkdir -p "$OUT"

rsync -a ./ "$OUT/" \
  --exclude "/$OUT/" \
  --exclude '/.git/' \
  --exclude '/.github/' \
  --exclude '/build/' \
  --exclude '/node_modules/' \
  --exclude '/package.json' \
  --exclude '/package-lock.json' \
  --exclude '/wrangler.jsonc' \
  --exclude '/.gitignore' \
  --exclude '/README.md'

bash build/generate-sitemap.sh "$OUT" "$BASE_URL" "$OUT/sitemap.xml"

# IndexNow のキーファイル(Bing が所有確認のために取りにくる)
if [ -n "${INDEXNOW_KEY:-}" ]; then
  printf '%s' "$INDEXNOW_KEY" > "$OUT/$INDEXNOW_KEY.txt"
fi

echo "build complete: $OUT"
