---
name: "Jira Sync"
description: "Synchronize squad pipeline progress with Jira for project tracking"
type: integration
version: "1.0.0"
category: project-management
agents: [project-manager, tech-lead]
---

# Jira Sync — Project Tracking Integration

Syncs ForgeSquad pipeline execution with Jira for status tracking and reporting.

## When to Use

- **Status updates**: Automatically update Jira tickets as pipeline steps complete
- **Sprint tracking**: Sync sprint backlog between ForgeSquad and Jira
- **Metrics collection**: Pull velocity, lead time, and cycle time from Jira
- **Report generation**: Generate PM reports with Jira data

## Integration Pattern

1. **Map pipeline steps to Jira statuses**: Each phase maps to Jira workflow states
2. **Update on checkpoint**: At each checkpoint, sync status to Jira
3. **Pull metrics**: Read Jira metrics for PM reports
4. **Create tickets**: Generate Jira stories from BA requirements output

## Status Mapping

| ForgeSquad Phase | Jira Status |
|-----------------|-------------|
| requirements | To Do / Backlog |
| architecture | In Design |
| planning | Ready for Dev |
| implementation | In Progress |
| quality | In Testing |
| review | In Review |
| documentation | In Documentation |
| deployment | Deploying |
| sustaining | Done |
