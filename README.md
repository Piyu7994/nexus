# Nexus

A Claude Code plugin that bundles MCP servers for daily workflow tools. Currently supports **Jira** (via official Atlassian MCP) and **Figma** (via official Figma MCP).

## Prerequisites

- [Claude Code](https://claude.com/claude-code) installed
- Node.js v18+
- An Atlassian Cloud account (for Jira)
- A Figma account (for Figma)

## Installation

### Option 1: From GitHub (permanent)

```bash
# Register the marketplace
claude plugin marketplace add Piyu7994/nexus

# Install the plugin
claude plugin install nexus@nexus
```

### Option 2: Local development (session-only)

```bash
git clone https://github.com/Piyu7994/nexus.git nexus
claude --plugin-dir /path/to/nexus/plugin
```

## First-Time Setup

### Jira
1. Start Claude Code with the plugin loaded
2. Type `/nexus:jira`
3. A browser window will open for **Atlassian OAuth** — sign in and authorize access to your Jira instance
4. Once authorized, **restart your Claude Code session** for the connection to take effect

### Figma
1. Start Claude Code with the plugin loaded
2. Type `/nexus:figma whoami`
3. A browser window will open for **Figma OAuth** — sign in and authorize access
4. Once authorized, **restart your Claude Code session** for the connection to take effect

> **Tip:** If Figma responses get truncated, set `MAX_MCP_OUTPUT_TOKENS=50000` in your environment before starting Claude Code.

OAuth tokens are managed automatically by `mcp-remote`.

## Usage

### Jira

```
/nexus:jira <what you want to do>
```

### Jira Examples

| Command | What it does |
|---------|-------------|
| `/nexus:jira search open bugs in PROJ` | Search issues using JQL |
| `/nexus:jira create a story in PROJ` | Create a single Jira issue |
| `/nexus:jira update story points on PROJ-123 to 5` | Update issue fields |
| `/nexus:jira move PROJ-123 to In Progress` | Transition issue status |
| `/nexus:jira assign PROJ-123 to alice@company.com` | Assign a team member |
| `/nexus:jira break down feature from spec.md into PROJ-100` | Generate a full ticket hierarchy (stories, tasks, subtasks) under an epic from a feature spec |

### Feature Breakdown

The most powerful workflow — give it a feature spec and an epic key:

```
/nexus:jira break down feature from docs/feature-spec.md into PROJ-100
```

It will:
1. Read and analyze your spec
2. Propose a ticket hierarchy (Stories → Tasks → Sub-tasks)
3. Estimate story points (Fibonacci: 1, 2, 3, 5, 8, 13)
4. Let you review and adjust before creating anything
5. Create all tickets with correct parent-child links and assignees

### Figma

```
/nexus:figma <what you want to do>
```

### Figma Examples

| Command | What it does |
|---------|-------------|
| `/nexus:figma get design context for <url>` | Extract code-ready design context (React+Tailwind) |
| `/nexus:figma extract design tokens from <url>` | Get variables and styles (colors, spacing, typography) |
| `/nexus:figma take a screenshot of <url>` | Screenshot a Figma selection |
| `/nexus:figma search design system for button` | Search connected design libraries |
| `/nexus:figma create a new Figma file` | Create a blank Design or FigJam file |
| `/nexus:figma generate a flowchart from mermaid: ...` | Generate a FigJam diagram |
| `/nexus:figma set up Code Connect mappings` | Map Figma components to code components |

### Figma Rate Limits

Figma MCP has strict rate limits based on your plan:

| Plan / Seat | Limit |
|---|---|
| Starter or View/Collab seats | **6 calls/month** |
| Dev/Full on Professional | 15 calls/min, 200/day |
| Dev/Full on Organization | 20 calls/min, 200/day |
| Dev/Full on Enterprise | Unlimited/min, 600/day |

The plugin automatically detects your plan and warns before each call on low-tier plans.

---

## Supported Tools

### Jira

All 13 Jira tools from the official Atlassian MCP server:

- `createJiraIssue`, `editJiraIssue`, `getJiraIssue`
- `searchJiraIssuesUsingJql`
- `transitionJiraIssue`, `getTransitionsForJiraIssue`
- `addCommentToJiraIssue`, `addWorklogToJiraIssue`
- `getJiraProjectIssueTypesMetadata`, `getJiraIssueTypeMetaWithFields`
- `getVisibleJiraProjectsList`
- `lookupJiraAccountId`
- `getJiraIssueRemoteIssueLinks`

### Figma

All 16 tools from the official Figma MCP server:

- `get_design_context` — extract code-ready design context
- `get_variable_defs` — get design tokens (colors, spacing, typography)
- `get_metadata` — get layer tree structure (IDs, names, types, positions)
- `get_screenshot` — screenshot a selection
- `get_figjam` — convert FigJam board to XML
- `get_code_connect_map`, `add_code_connect_map`, `get_code_connect_suggestions`, `send_code_connect_mappings` — Code Connect management
- `search_design_system` — search connected design libraries
- `use_figma` — create/edit/delete pages, frames, components (remote only, beta)
- `generate_figma_design` — capture live UI as Figma layers (rate-limit-exempt)
- `generate_diagram` — generate FigJam diagrams from Mermaid syntax
- `create_new_file` — create a blank Figma/FigJam file
- `create_design_system_rules` — create agent-friendly design rules
- `whoami` — check authenticated user and plan (rate-limit-exempt)

## Adding a New Tool

The plugin is designed to be extensible:

1. Add the MCP server entry to `plugin/.mcp.json`
2. Add a command file at `plugin/commands/<tool>.md`
3. Optionally add a skill at `plugin/skills/<tool>-workflow/SKILL.md`

## License

MIT
