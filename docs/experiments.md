# Experiment Guide

All comparisons should be budget-matched by online environment steps. Offline pretraining updates and dataset size are logged separately and should not be counted as online interaction.

## Tier 1

Run these for `Hopper-v4`, `Walker2d-v4`, `HalfCheetah-v4`, and `Ant-v4` when time allows:

- `SAC`
- `PPO`
- `PPO -> SAC` at switch fractions `0.25`, `0.50`, `0.75`
- `SAC -> PPO` at switch fractions `0.25`, `0.50`, `0.75`
- `BC`
- `BC -> SAC`
- `BC -> PPO`
- `BC -> SAC -> PPO`

Use at least 3 seeds for pilots and 5 seeds for final comparisons.

## Optional Tier 2

- `IQL`
- `AWAC`
- `IQL -> SAC`
- `AWAC -> SAC`
- `IQL -> SAC -> PPO`
- `AWAC -> SAC -> PPO`
- Adaptive `PPO -> SAC` with `--switch-trigger no-improve`

## Naming

Run directories are created with method, environment, seed, budget, switch settings, and timestamp. Avoid manually renaming or overwriting runs.

Example:

```text
sac_to_ppo__Hopper-v4__seed_0__frac_0.50__policy_distill_from_sac__value_self-warmup_from_none__switch_250000__1770000000
```

## Metrics To Report

- Final evaluation return
- Evaluation-return AUC over environment steps
- Across-seed standard deviation or standard error
- Worst-seed final return
- Collapse count
- Average rank across environments
- Handoff transient immediately after switch

The project claim should be phase-based: sequencing is useful when one phase creates an initialization, state distribution, or representation that improves the next phase under the remaining budget.

