# Nexus Plugin

## What This Is
A Claude Code plugin that bundles MCP servers for daily workflow tools.
Currently supports: Jira (via official Atlassian MCP) and Figma (via official Figma MCP).

## Architecture
- `.mcp.json` — MCP server definitions (one entry per tool)
- `commands/` — Slash commands (one per tool, handles its own setup)
- `skills/` — Skills for tool-specific workflows
- `scripts/` — Helper scripts for environment validation

## Adding a New Tool
1. Add server entry to `.mcp.json`
2. Add command file in `commands/<tool>.md`
3. Optionally add a skill in `skills/<tool>-workflow/SKILL.md`
