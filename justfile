default:
  @just --list

login-ghcr:
  docker login ghcr.io -u felipesere -p $(op read op://Homelab/"Github PAT Push Registry"/password)

# Next integer tag: one past the highest numeric tag currently in ghcr.io.
next-tag:
  #!/usr/bin/env bash
  set -euo pipefail
  TOKEN=$(op read op://Homelab/"Github PAT Push Registry"/password)
  MAX=$(curl -sf -H "Authorization: Bearer $TOKEN" -H "Accept: application/vnd.github+json" \
    "https://api.github.com/user/packages/container/sol/versions?per_page=100" \
    | jq -r '.[].metadata.container.tags[]' \
    | grep -E '^[0-9]+$' \
    | sort -n | tail -1) || true
  echo $((${MAX:-0} + 1))

publish: login-ghcr
  #!/usr/bin/env bash
  set -euo pipefail
  NEXT=$(just next-tag)
  echo "Publishing ghcr.io/felipesere/sol:${NEXT} and :latest"
  docker build . -t ghcr.io/felipesere/sol:${NEXT} -t ghcr.io/felipesere/sol:latest
  docker push ghcr.io/felipesere/sol:${NEXT}
  docker push ghcr.io/felipesere/sol:latest
