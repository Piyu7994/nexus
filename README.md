# Nexus

A Claude Code plugin that bundles MCP servers for daily workflow tools. Currently supports **Jira** via the official Atlassian MCP server.

## Prerequisites

- [Claude Code](https://claude.com/claude-code) installed
- Node.js v18+
- An Atlassian Cloud account (Jira)

## Installation

### Option 1: From GitHub (permanent)

```bash
# Register the marketplace
claude plugin marketplace add <your-github-username>/nexus

# Install the plugin
claude plugin install nexus@nexus
```

### Option 2: Local development (session-only)

```bash
git clone <repo-url> nexus
claude --plugin-dir /path/to/nexus/plugin
```

## First-Time Setup

1. Start Claude Code with the plugin loaded
2. Type `/nexus:jira`
3. A browser window will open for **Atlassian OAuth** — sign in and authorize access to your Jira instance
4. Once authorized, the command will confirm the connection is ready

That's it. OAuth tokens are managed automatically by `mcp-remote`.

## Usage

```
/nexus:jira <what you want to do>
```

### Examples

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

## Supported Tools

All 13 Jira tools from the official Atlassian MCP server:

- `createJiraIssue`, `editJiraIssue`, `getJiraIssue`
- `searchJiraIssuesUsingJql`
- `transitionJiraIssue`, `getTransitionsForJiraIssue`
- `addCommentToJiraIssue`, `addWorklogToJiraIssue`
- `getJiraProjectIssueTypesMetadata`, `getJiraIssueTypeMetaWithFields`
- `getVisibleJiraProjectsList`
- `lookupJiraAccountId`
- `getJiraIssueRemoteIssueLinks`

## Adding a New Tool

The plugin is designed to be extensible:

1. Add the MCP server entry to `plugin/.mcp.json`
2. Add a command file at `plugin/commands/<tool>.md`
3. Optionally add a skill at `plugin/skills/<tool>-workflow/SKILL.md`

## License

MIT
