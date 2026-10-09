#!/usr/bin/env bash
set -euo pipefail

operation=$1
channel=$2
release=${3:-}

server="$HELIOS_USER@$HELIOS_HOST"
ssh_options=(
  -i "$HELIOS_KEY_FILE"
  -p "$HELIOS_PORT"
  -o BatchMode=yes
  -o IdentitiesOnly=yes
  -o StrictHostKeyChecking=yes
  -o "UserKnownHostsFile=$HELIOS_KNOWN_HOSTS"
  -o ConnectTimeout=20
)

remote() {
  local command
  printf -v command '%q ' "$@"

  ssh "${ssh_options[@]}" "$server" "$command"
}

activate_release() {
  {
    printf 'set -- %q %q %q\n' "$operation" "$channel" "$release"
    cat scripts/helios-switch.sh
  } | ssh "${ssh_options[@]}" "$server" \
    'lockf -k .practice1/deploy.lock bash -s'
}

if [[ "$operation" != rollback ]]; then
  release_directory=".practice1/releases/$release"
  printf '%s\n' "$release" > dist/release.txt

  remote mkdir "$release_directory"

  printf -v transport '%q ' ssh "${ssh_options[@]}"

  rsync \
    --recursive --links --times --compress \
    --chmod=Du=rwx,Dgo=rx,Fu=rw,Fgo=r \
    --rsh="$transport" \
    dist/ "$server:$release_directory/"

  if [[ "$operation" == interrupt ]]; then
    echo 'Controlled interruption: uploaded release was not activated' >&2
    exit 42
  fi

  if [[ "$channel" == main ]]; then
    remote ln -s ../../previews "$release_directory/previews"
  fi
fi

release=$(activate_release)
site_url="${HELIOS_URL%/}/"

if [[ "$channel" != main ]]; then
  site_url="${site_url}previews/$channel/"
fi

bash scripts/healthcheck.sh "$site_url" "$release"
