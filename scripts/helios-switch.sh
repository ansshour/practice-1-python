#!/usr/bin/env bash
# Выполняется на Helios под блокировкой lockf.
set -euo pipefail

operation=$1
channel=$2
release=$3

deployment_directory="$HOME/.practice1"
site_link="$HOME/public_html"
previous_release_file="$deployment_directory/previous-$channel"
next_link="$deployment_directory/next-$channel"

if [[ "$channel" != main ]]; then
  site_link="$deployment_directory/previews/$channel"
fi

if [[ "$operation" == rollback ]]; then
  release_directory=$(cat "$previous_release_file")
else
  release_directory="$deployment_directory/releases/$release"
fi

test -f "$release_directory/index.html"
test -f "$release_directory/release.txt"

previous_release=''

if [[ -L "$site_link" ]]; then
  previous_release=$(readlink "$site_link")
fi

ln -s "$release_directory" "$next_link"

# Во FreeBSD -h заменяет саму ссылку, а не каталог за ней.
mv -fh "$next_link" "$site_link"
printf '%s\n' "$previous_release" > "$previous_release_file"

cat "$release_directory/release.txt"
