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

ENV_ID="${ENV_ID:-Hopper-v4}"
SEED="${SEED:-0}"
TOTAL_TIMESTEPS="${TOTAL_TIMESTEPS:-10000}"
EVAL_INTERVAL="${EVAL_INTERVAL:-5000}"
NUM_EVAL_EPISODES="${NUM_EVAL_EPISODES:-2}"
SAVE_DIR="${SAVE_DIR:-results/raw/smoke}"

python -m rl_sequencing.trainers.sac \
  --env-id "$ENV_ID" \
  --seed "$SEED" \
  --total-timesteps "$TOTAL_TIMESTEPS" \
  --eval-interval "$EVAL_INTERVAL" \
  --num-eval-episodes "$NUM_EVAL_EPISODES" \
  --save-dir "$SAVE_DIR" \
  --wandb-project "$WANDB_PROJECT" \
  --wandb-group smoke_sac \
  "$track_flag"

python -m rl_sequencing.trainers.ppo \
  --env-id "$ENV_ID" \
  --seed "$SEED" \
  --total-timesteps "$TOTAL_TIMESTEPS" \
  --eval-interval "$EVAL_INTERVAL" \
  --num-eval-episodes "$NUM_EVAL_EPISODES" \
  --save-dir "$SAVE_DIR" \
  --wandb-project "$WANDB_PROJECT" \
  --wandb-group smoke_ppo \
  "$track_flag"

python -m rl_sequencing.trainers.sac_to_ppo \
  --env-id "$ENV_ID" \
  --seed "$SEED" \
  --total-timesteps "$TOTAL_TIMESTEPS" \
  --switch-fraction 0.5 \
  --sac-learning-starts 1000 \
  --eval-interval "$EVAL_INTERVAL" \
  --num-eval-episodes "$NUM_EVAL_EPISODES" \
  --save-dir "$SAVE_DIR" \
  --wandb-project "$WANDB_PROJECT" \
  --wandb-group smoke_sac_to_ppo \
  "$track_flag"

python -m rl_sequencing.trainers.ppo_to_sac \
  --env-id "$ENV_ID" \
  --seed "$SEED" \
  --total-timesteps "$TOTAL_TIMESTEPS" \
  --switch-fraction 0.5 \
  --eval-interval "$EVAL_INTERVAL" \
  --num-eval-episodes "$NUM_EVAL_EPISODES" \
  --save-dir "$SAVE_DIR" \
  --wandb-project "$WANDB_PROJECT" \
  --wandb-group smoke_ppo_to_sac \
  "$track_flag"
