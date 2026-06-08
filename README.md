# CS224R Final Project: Algorithm Sequencing in Deep RL

This repo contains the experiment code for studying reinforcement-learning algorithms as training phases rather than fixed end-to-end choices.

The core question is whether schedules such as `PPO -> SAC`, `SAC -> PPO`, `BC -> SAC`, and `BC -> SAC -> PPO` improve sample efficiency, robustness, or final return under matched environment-step budgets.

## What Is Included

```text
src/rl_sequencing/
  trainers/      SAC, PPO, SAC->PPO, PPO->SAC online training
  offline/       BC, IQL, AWAC offline warm-start training
  handoffs/      schedule and transfer helpers
  data/          D4RL expert dataset loading and caching
  analysis/      result summarization and plotting utilities
  modal/         Modal launchers for larger sweeps
  tools/         checkpoint compatibility checks
scripts/         local run wrappers
tests/           lightweight regression tests
docs/            experiment and result-format notes
```

## Setup

Python 3.10+ is required. MuJoCo dependencies are installed through `gymnasium[mujoco]`.

```bash
python -m venv .venv
source .venv/bin/activate
pip install -e ".[dev]"
cp .env.example .env
```

If you use `uv`, this also works:

```bash
uv sync --extra dev
```

For W&B logging, set `WANDB_MODE=online` and `TRACK=true` in `.env`, or pass `--track` directly to a trainer.

## Quick Smoke Run

Run a tiny local sanity check:

```bash
./scripts/run_smoke.sh
```

This runs short SAC, PPO, `SAC -> PPO`, and `PPO -> SAC` jobs on `Hopper-v4` and writes JSONL metrics under `results/raw/smoke`.

## Core Local Commands

Single algorithm baselines:

```bash
python -m rl_sequencing.trainers.sac --env-id Hopper-v4 --seed 0 --total-timesteps 100000
python -m rl_sequencing.trainers.ppo --env-id Hopper-v4 --seed 0 --total-timesteps 100000
```

Online handoffs:

```bash
python -m rl_sequencing.trainers.sac_to_ppo --env-id Hopper-v4 --seed 0 --switch-fraction 0.5 --total-timesteps 100000
python -m rl_sequencing.trainers.ppo_to_sac --env-id Hopper-v4 --seed 0 --switch-fraction 0.5 --total-timesteps 100000
```

Offline warm starts:

```bash
python -m rl_sequencing.offline.bc --env-id Hopper-v4 --total-updates 50000
python -m rl_sequencing.offline.iql --env-id Hopper-v4 --total-updates 100000
python -m rl_sequencing.offline.awac --env-id Hopper-v4 --total-updates 100000
```

Local multi-GPU IQL transfer sweep helper:

```bash
python -m rl_sequencing.tools.run_iql_local --gpus 0,1 --results-dir results/raw/iql_transfer
python -m rl_sequencing.analysis.plot_iql_results \
  --results-dir results/raw/iql_transfer/tier2_iql \
  --summary-json results/processed/iql_transfer/summary.json
```

Use a saved offline policy to warm-start SAC:

```bash
python -m rl_sequencing.trainers.sac \
  --env-id Hopper-v4 \
  --seed 0 \
  --total-timesteps 500000 \
  --bc-policy-path results/raw/offline/bc/Hopper-v4/bc_policy.pt \
  --offline-policy-source bc \
  --bc-distill-steps 500
```

## Summaries

```bash
python -m rl_sequencing.analysis.summarize_baselines --results-dir results/raw/baselines
python -m rl_sequencing.analysis.summarize_online_handoffs --results-dir results/raw/online_handoffs --skip-checkpoint-gate
python -m rl_sequencing.analysis.summarize_offline_warmstarts --results-dir results/raw/offline_warmstarts
```

Metrics are stored as `metrics.jsonl` with explicit `algorithm`, `env`, `seed`, `env_steps`, `gradient_updates`, phase, switch, and transfer metadata.

## Modal

Modal launchers are under `src/rl_sequencing/modal`:

```bash
modal run src/rl_sequencing/modal/online_handoffs.py --mode smoke
modal run src/rl_sequencing/modal/ppo_to_sac.py
modal run src/rl_sequencing/modal/offline_warmstarts.py --mode core
```

Before running Modal, create the W&B secret once:

```bash
./scripts/create_wandb_modal_secret.sh
```

## Tests

```bash
pytest
python -m compileall src tests
```
