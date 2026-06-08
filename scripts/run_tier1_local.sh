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
SEEDS=(${SEEDS:-0 1 2})
SWITCH_FRACTIONS=(${SWITCH_FRACTIONS:-0.25 0.5 0.75})
TOTAL_TIMESTEPS="${TOTAL_TIMESTEPS:-100000}"
EVAL_INTERVAL="${EVAL_INTERVAL:-5000}"
NUM_EVAL_EPISODES="${NUM_EVAL_EPISODES:-5}"
SAVE_DIR="${SAVE_DIR:-results/raw/tier1_local}"

for env_id in "${ENVS[@]}"; do
  for seed in "${SEEDS[@]}"; do
    python -m rl_sequencing.trainers.sac \
      --env-id "$env_id" \
      --seed "$seed" \
      --total-timesteps "$TOTAL_TIMESTEPS" \
      --eval-interval "$EVAL_INTERVAL" \
      --num-eval-episodes "$NUM_EVAL_EPISODES" \
      --save-dir "$SAVE_DIR" \
      --wandb-project "$WANDB_PROJECT" \
      --wandb-group "tier1_sac__${env_id}" \
      "$track_flag"

    python -m rl_sequencing.trainers.ppo \
      --env-id "$env_id" \
      --seed "$seed" \
      --total-timesteps "$TOTAL_TIMESTEPS" \
      --eval-interval "$EVAL_INTERVAL" \
      --num-eval-episodes "$NUM_EVAL_EPISODES" \
      --save-dir "$SAVE_DIR" \
      --wandb-project "$WANDB_PROJECT" \
      --wandb-group "tier1_ppo__${env_id}" \
      "$track_flag"

    for switch_fraction in "${SWITCH_FRACTIONS[@]}"; do
      python -m rl_sequencing.trainers.sac_to_ppo \
        --env-id "$env_id" \
        --seed "$seed" \
        --total-timesteps "$TOTAL_TIMESTEPS" \
        --switch-fraction "$switch_fraction" \
        --eval-interval "$EVAL_INTERVAL" \
        --num-eval-episodes "$NUM_EVAL_EPISODES" \
        --save-dir "$SAVE_DIR" \
        --wandb-project "$WANDB_PROJECT" \
        --wandb-group "tier1_sac_to_ppo__${env_id}" \
        "$track_flag"

      python -m rl_sequencing.trainers.ppo_to_sac \
        --env-id "$env_id" \
        --seed "$seed" \
        --total-timesteps "$TOTAL_TIMESTEPS" \
        --switch-fraction "$switch_fraction" \
        --eval-interval "$EVAL_INTERVAL" \
        --num-eval-episodes "$NUM_EVAL_EPISODES" \
        --save-dir "$SAVE_DIR" \
        --wandb-project "$WANDB_PROJECT" \
        --wandb-group "tier1_ppo_to_sac__${env_id}" \
        "$track_flag"
    done
  done
done
