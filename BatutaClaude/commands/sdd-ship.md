# /sdd-ship

Prepare a verified change for production launch using the shipping-and-launch skill.

## When to use

After sdd-verify passes (Pyramid L1-L3 green) and the change is ready for production deployment. This is the final phase of the SDD pipeline.

## What it does

1. Invokes the `shipping-and-launch` skill
2. Runs the pre-launch checklist (code quality, security, performance, infra, docs)
3. Plans the rollout strategy (feature flags, staged percentages, decision thresholds)
4. Documents the rollback plan (trigger conditions, steps, estimated time)
5. Defines post-launch verification steps (first-hour checklist)

## Skip when

- Internal tooling or dev-only changes
- Documentation-only changes
- Changes that don't reach end users
- Exploratory work or prototypes

## Usage

```
/sdd-ship [change-name]
```

If `change-name` is provided, reads the sdd-verify report from `openspec/changes/{name}/` to confirm the Pyramid passed before proceeding.
