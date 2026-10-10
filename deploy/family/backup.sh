#!/usr/bin/env bash
set -euo pipefail
umask 077
root="${KITCHENOWL_ROOT:?Set KITCHENOWL_ROOT to the runtime directory}"
compose="$root/repo/deploy/family/compose.yaml"
mkdir -p "$root/backups" "$root/state"
exec 9>"$root/state/backup.lock"
flock -n 9 || { echo "Backup already running" >&2; exit 1; }
if [[ -z "$(docker compose --env-file "$root/config/deployment.env" -f "$compose" ps --status running -q app)" ]]; then
  echo "KitchenOwl must be running before backup" >&2; exit 1
fi
stamp=$(date -u +%Y%m%dT%H%M%SZ)
archive="$root/backups/kitchenowl-$stamp.tar.gz"
[[ ! -e "$archive" && ! -e "$archive.partial" ]] || exit 1
stopped=0
resume() {
  if [[ "$stopped" == 1 ]]; then
    docker compose --env-file "$root/config/deployment.env" -f "$compose" start app >&2
  fi
}
trap resume EXIT
stopped=1
docker compose --env-file "$root/config/deployment.env" -f "$compose" stop app >&2
tar -czf "$archive.partial" -C "$root" data config repo/deploy/family/compose.yaml
mv "$archive.partial" "$archive"
docker compose --env-file "$root/config/deployment.env" -f "$compose" start app >&2
stopped=0
sha256sum "$archive" > "$archive.sha256"
echo "$archive"
