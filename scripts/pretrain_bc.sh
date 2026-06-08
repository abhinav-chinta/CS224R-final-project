#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

if [[ -f ".env" ]]; then
  set -a
  # shellcheck disable=SC1091
  source ".env"
  set +a
fi

export WANDB_PROJECT="${WANDB_PROJECT:-rl-translational-dynamics}"
export WANDB_MODE="${WANDB_MODE:-offline}"
export PYTHONPATH="${ROOT_DIR}/src:${PYTHONPATH:-}"

TRACK="${TRACK:-false}"
track_flag="--no-track"
if [[ "$TRACK" == "true" ]]; then
  track_flag="--track"
fi

ENVS=(${ENVS:-Hopper-v4 Walker2d-v4})
BC_UPDATES="${BC_UPDATES:-50000}"
EVAL_INTERVAL="${EVAL_INTERVAL:-5000}"
NUM_EVAL_EPISODES="${NUM_EVAL_EPISODES:-5}"
SAVE_DIR="${SAVE_DIR:-results/raw/offline/bc}"

for env_id in "${ENVS[@]}"; do
  python -m rl_sequencing.offline.bc \
    --env-id "$env_id" \
    --total-updates "$BC_UPDATES" \
    --eval-interval "$EVAL_INTERVAL" \
    --num-eval-episodes "$NUM_EVAL_EPISODES" \
    --save-dir "$SAVE_DIR" \
    --wandb-project "$WANDB_PROJECT" \
    --wandb-group "bc_pretrain__${env_id}" \
    "$track_flag"
done
