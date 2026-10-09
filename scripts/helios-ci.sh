#!/usr/bin/env bash
set -euo pipefail

operation=$1

case "$operation" in
  destination)
    channel=main

    if [[ "$GITHUB_REF_NAME" != main ]]; then
      branch_hash=$(printf '%s' "$GITHUB_REF_NAME" | shasum -a 256 | cut -c1-16)
      channel="branch-$branch_hash"
    fi

    if [[ "$OPERATION" == rollback && "$channel" != main ]]; then
      echo 'Run rollback from main' >&2
      exit 1
    fi

    site_url="${HELIOS_URL%/}/"

    if [[ "$channel" != main ]]; then
      site_url="${site_url}previews/$channel/"
    fi

    {
      echo "HELIOS_KEY_FILE=$RUNNER_TEMP/helios-key"
      echo "HELIOS_KNOWN_HOSTS=$RUNNER_TEMP/helios-known-hosts"
      echo "CHANNEL=$channel"
      echo "RELEASE=$GITHUB_SHA-$GITHUB_RUN_ID-$GITHUB_RUN_ATTEMPT"
      echo "SITE_URL=$site_url"
    } >> "$GITHUB_ENV"
    ;;

  ssh)
    umask 077

    printf '%s\n' "$DEPLOY_KEY" > "$HELIOS_KEY_FILE"
    printf '%s\n' "$KNOWN_HOSTS" > "$HELIOS_KNOWN_HOSTS"
    ;;

  cleanup)
    rm -f "$RUNNER_TEMP/helios-key" "$RUNNER_TEMP/helios-known-hosts"
    ;;
esac
