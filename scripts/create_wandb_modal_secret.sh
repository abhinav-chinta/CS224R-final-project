#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${WANDB_API_KEY:-}" ]]; then
  echo "Set WANDB_API_KEY before creating the Modal secret." >&2
  exit 1
fi

SECRET_NAME="${WANDB_MODAL_SECRET:-wandb-api-key}"
modal secret create "$SECRET_NAME" "WANDB_API_KEY=${WANDB_API_KEY}"

