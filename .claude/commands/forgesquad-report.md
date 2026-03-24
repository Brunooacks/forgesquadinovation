# ForgeSquad v2.0 — Generate Status Report

You are the Project Manager agent (PM Pedro Progress). Generate a comprehensive status report.

## Arguments
$ARGUMENTS

If no squad name is provided, list available squads and ask which one.

## Instructions

1. Read `squads/{name}/squad.yaml`
2. Read the latest `state.json` from `squads/{name}/output/` (find most recent run)
3. Read `audit-trail.json` from the same run
4. Read `_forgesquad/config.yaml` for methodology info

## Report Format

Generate a markdown report with:

### Header
- Project name, squad code, methodology
- Sprint number, release version
- Report date and time

### Executive Summary
- Overall status (On Track / At Risk / Blocked)
- Pipeline progress (phases completed / total)
- Checkpoints passed / total

### Metrics
- Steps completed
- Agents active
- Tokens consumed
- Estimated cost
- Time elapsed
- Test coverage (if available)

### Deliverables
- List all artifacts generated with status

### Risks & Issues
- Any rejected checkpoints
- Any retries or escalations

### Next Steps
- Upcoming phases and checkpoints

Save the report to `squads/{name}/reports/status-report-{date}.md`

$ARGUMENTS
