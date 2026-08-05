# User-global notes

## Skill-creator eval-loop gotchas

Hard-won mechanics for running skill-creator's test/benchmark loop (apply whenever running skill evals, in any project):

- **Directory layout the aggregator requires**: `<workspace>/iteration-N/eval-<id>-<name>/<config>/run-<n>/{outputs/, grading.json, timing.json}`. Without the `run-<n>` level, `aggregate_benchmark` silently reports 0%/empty rather than erroring.
- **Leave `timing` out of grading.json**: if grading.json has a `timing` key, it shadows the sibling `timing.json` and token counts are silently dropped from the benchmark. Keep wall-clock + tokens in `run-<n>/timing.json` only. Grading `expectations` must use exactly the fields `text`/`passed`/`evidence`.
- **Capture timing from task notifications immediately**: `total_tokens`/`duration_ms` arrive only in each subagent's completion notification — write `timing.json` as each one lands; there is no second chance.
- **Clean baselines need the skill absent**: skills installed in `~/.claude/skills/` are visible to every subagent, so "without-skill" baseline runs get contaminated (they may even invoke the skill). Move the skill out of the skills dir while baselines run, or run baselines before installing.
- **Eval agents vs. the live repo**: agents told to exercise a skill will happily write real files into the working repo. Give every eval agent an outputs-directory contract, have it write a `repo-files-created.txt` manifest, forbid VCS writes, and give twin (with/without) runs distinct target filenames or they'll overwrite each other.
- **The review viewer doesn't log its port**: it binds a random localhost port and prints nothing under `nohup`. Find it with `ss -tlnp | grep python`.
