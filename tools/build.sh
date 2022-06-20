#!/usr/bin/env bash

set -e
PKGROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && echo "$PWD")

get_npm_token() {
  if [[ -z $NPM_TOKEN ]]; then
    if ! type bitwarden-fields >/dev/null 2>&1; then
      fatal "build.sh: NPM_TOKEN required, but unable to retrieve. The bitwarden-fields command does not exist."
    fi
    eval "$(bitwarden-fields --cache-for=$((60 * 60 * 8)) "NPM - Ansible" NPM_TOKEN || echo return 1)"
  fi
  printf -- "%s\n" "$NPM_TOKEN"
}

main() {
  docker build --build-arg "NPM_TOKEN=$(get_npm_token)" --file "$PKGROOT/tools/Dockerfile.build" -t build-git-release:latest .
  docker run --rm \
    -e USER_ID="$(id -u)" -e GROUP_ID="$(id -g)" \
    -v "$PKGROOT/dist:/artifacts/dist:rw" \
    build-git-release:latest
}

main "$@"
