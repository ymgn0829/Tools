#!/bin/bash

BASE_URL="${1:-https://tools.ymgn0829.workers.dev}"
OUTPUT="${2:-sitemap.xml}"

# サイトマップのヘッダー
cat > "$OUTPUT" <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
EOF

# すべての .html ファイルを再帰的に見つけて、lastmod とともに追加
find . -name "index.html" -o -name "*.html" | sort | while read file; do
  # ./index.html → /
  path="${file#./}"
  if [[ "$path" == "index.html" ]]; then
    url="$BASE_URL/"
  else
    # ./foo/index.html → /foo/
    # ./bar.html → /bar.html
    path="${path%/index.html}"
    if [[ "$path" == "" ]]; then
      url="$BASE_URL/"
    else
      url="$BASE_URL/$path/"
    fi
  fi

  # lastmod を取得（ファイルの更新日）
  lastmod=$(stat -f %Sm -t %Y-%m-%d "$file" 2>/dev/null || date -d @$(stat -c %Y "$file" 2>/dev/null || echo 0) +%Y-%m-%d 2>/dev/null || date +%Y-%m-%d)

  cat >> "$OUTPUT" <<EOF
  <url>
    <loc>$url</loc>
    <lastmod>$lastmod</lastmod>
  </url>
EOF
done

# フッター
cat >> "$OUTPUT" <<'EOF'
</urlset>
EOF

echo "Sitemap generated: $OUTPUT"
