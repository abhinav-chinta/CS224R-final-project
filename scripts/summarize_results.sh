#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"
export PYTHONPATH="${ROOT_DIR}/src:${PYTHONPATH:-}"

BASELINE_DIR="${BASELINE_DIR:-results/raw/tier1_local}"
HANDOFF_DIR="${HANDOFF_DIR:-results/raw/tier1_local}"
WARMSTART_DIR="${WARMSTART_DIR:-results/raw/offline_warmstarts}"

python -m rl_sequencing.analysis.summarize_baselines \
  --results-dir "$BASELINE_DIR" \
  --output-dir results/processed/baselines

python -m rl_sequencing.analysis.summarize_online_handoffs \
  --results-dir "$HANDOFF_DIR" \
  --output-dir results/processed/online_handoffs \
  --skip-checkpoint-gate

python -m rl_sequencing.analysis.summarize_offline_warmstarts \
  --results-dir "$WARMSTART_DIR" \
  --output-dir results/processed/offline_warmstarts \
  --notes-path results/processed/offline_warmstarts/results.md
