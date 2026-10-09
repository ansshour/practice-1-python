#!/usr/bin/env bash
set -euo pipefail

site_url=$1
expected_release=$2
response_directory=$(mktemp -d)

trap 'rm -rf "$response_directory"' EXIT

check_site() {
  local status

  status=$(curl --silent --show-error --location --max-time 20 \
    --header 'Cache-Control: no-cache' \
    --output "$response_directory/release" --write-out '%{http_code}' \
    "${site_url}release.txt?check=$(date +%s)") || return 1

  [[ "$status" == 200 ]] || return 1
  [[ "$(cat "$response_directory/release")" == "$expected_release" ]] || return 1

  status=$(curl --silent --show-error --location --max-time 20 \
    --output "$response_directory/page" --write-out '%{http_code}' \
    "${site_url}example/") || return 1

  [[ "$status" == 200 ]] || return 1
  grep -Fq 'practice-1-site-ready' "$response_directory/page"
}

for attempt in {1..6}; do
  if check_site; then
    echo "Healthcheck passed: $site_url release=$expected_release"
    exit 0
  fi

  echo "Attempt $attempt: unexpected release, HTTP status or page marker" >&2

  if [[ "$attempt" -lt 6 ]]; then
    sleep 3
  fi
done

exit 1
