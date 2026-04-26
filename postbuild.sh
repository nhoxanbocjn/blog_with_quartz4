#!/bin/sh
# Restructure public/*.html → public/*/index.html for Vercel static serving
find public -name "*.html" ! -name "index.html" ! -name "404.html" -exec sh -c '
  dir="${1%.html}"
  mkdir -p "$dir"
  mv "$1" "$dir/index.html"
' _ {} \;
