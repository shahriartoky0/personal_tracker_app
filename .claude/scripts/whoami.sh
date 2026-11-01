#!/usr/bin/env bash
set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
CLAUDE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
LOCAL_FILE="$CLAUDE_DIR/identity.local"

slugify() {
  printf '%s' "$1" | tr '[:upper:]' '[:lower:]' \
    | sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//'
}

DEV_SLUG=""; DEV_NAME=""; DEV_EMAIL=""; IDENTITY_SOURCE="none"

if [ -f "$LOCAL_FILE" ]; then
  . "$LOCAL_FILE" 2>/dev/null || true
  IDENTITY_SOURCE="file"
fi

[ -z "${DEV_EMAIL:-}" ] && DEV_EMAIL="$(git config user.email 2>/dev/null || true)"
[ -z "${DEV_NAME:-}" ]  && DEV_NAME="$(git config user.name 2>/dev/null || true)"
if [ -z "${DEV_SLUG:-}" ] && [ -n "${DEV_EMAIL:-}" ]; then
  DEV_SLUG="$(slugify "${DEV_EMAIL%@*}")"
fi
if [ "$IDENTITY_SOURCE" = "none" ] && [ -n "${DEV_EMAIL:-}${DEV_NAME:-}" ]; then
  IDENTITY_SOURCE="git"
fi

printf 'DEV_SLUG=%q\n'        "${DEV_SLUG:-}"
printf 'DEV_NAME=%q\n'        "${DEV_NAME:-}"
printf 'DEV_EMAIL=%q\n'       "${DEV_EMAIL:-}"
printf 'IDENTITY_SOURCE=%q\n' "${IDENTITY_SOURCE}"
