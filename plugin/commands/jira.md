---
description: Work with Jira — setup, create issues, break down features into ticket hierarchies, update story points, search, transition status, assign team members
allowed-tools: [
  "mcp__plugin_mcp-hub_atlassian__createJiraIssue",
  "mcp__plugin_mcp-hub_atlassian__editJiraIssue",
  "mcp__plugin_mcp-hub_atlassian__getJiraIssue",
  "mcp__plugin_mcp-hub_atlassian__searchJiraIssuesUsingJql",
  "mcp__plugin_mcp-hub_atlassian__transitionJiraIssue",
  "mcp__plugin_mcp-hub_atlassian__addCommentToJiraIssue",
  "mcp__plugin_mcp-hub_atlassian__addWorklogToJiraIssue",
  "mcp__plugin_mcp-hub_atlassian__getTransitionsForJiraIssue",
  "mcp__plugin_mcp-hub_atlassian__getJiraIssueTypeMetaWithFields",
  "mcp__plugin_mcp-hub_atlassian__getJiraProjectIssueTypesMetadata",
  "mcp__plugin_mcp-hub_atlassian__getVisibleJiraProjectsList",
  "mcp__plugin_mcp-hub_atlassian__lookupJiraAccountId",
  "mcp__plugin_mcp-hub_atlassian__getJiraIssueRemoteIssueLinks",
  "Bash",
  "Read",
  "Write",
  "Edit",
  "Glob",
  "Grep"
]
argument-hint: [what you want to do, e.g. "create a bug ticket", "break down feature from spec.md into EPIC-123", "update story points on PROJ-123"]
---

# Jira — MCP Hub

The user wants to work with Jira. Their request: $ARGUMENTS

---

## Step 1: Check if user provided arguments

If `$ARGUMENTS` is empty (user just typed `/mcp-hub:jira` with nothing else):

**Do NOT make any MCP calls.** Simply ask the user:

```
What would you like to do? Please provide one of:

- A **Project key** (e.g., XYZ) + what you want to do
- A **Ticket ID** (e.g., XYZ-123) + what you want to do

Examples:
  /mcp-hub:jira search open bugs in XYZ
  /mcp-hub:jira create a story in XYZ
  /mcp-hub:jira update story points on XYZ-123 to 5
  /mcp-hub:jira break down feature from spec.md into XYZ-100
  /mcp-hub:jira assign XYZ-123 to user@company.com
```

**STOP here.** Wait for the user to respond with their request.

---

## Step 2: MCP Connection Check (only when user has provided a request)

The user has provided arguments. Before executing, verify the Atlassian MCP is connected.

**Try a lightweight MCP call** — call `getJiraIssue` or `searchJiraIssuesUsingJql` based on what the user asked. If ANY MCP call fails with a connection error or "tool not found":

1. Run the environment check: `bash ${CLAUDE_PLUGIN_ROOT}/scripts/check-mcp-status.sh`
2. Inform the user:
   ```
   The Atlassian MCP server is not connected yet.

   This plugin bundles the config automatically. To complete setup:
   1. Restart Claude Code with this plugin loaded
   2. A browser window will open for Atlassian OAuth — authorize access to your Jira instance
   3. Run `/mcp-hub:jira` again after authorizing

   Requirements: Node.js v18+
   ```
3. **STOP here.** Do not proceed with any Jira operations.

If the call succeeds, continue to Step 3.

---

## Step 3: Handle the Request

Extract the project key or ticket ID from the user's request. Do NOT call `getVisibleJiraProjectsList` or any broad discovery API. Only make targeted calls relevant to what the user asked.

Route to the appropriate workflow below.

---

### Workflow A: Basic Issue Operations

#### Creating a Single Issue
1. Get project issue types: `getJiraProjectIssueTypesMetadata`
2. Get field metadata for the chosen type: `getJiraIssueTypeMetaWithFields`
3. Ask the user to confirm: summary, type, priority, assignee (if not already provided)
4. Create the issue: `createJiraIssue`
5. Confirm with the issue key and link

#### Updating Story Points / Fields
1. Get current issue: `getJiraIssue`
2. Show current values
3. Edit the issue: `editJiraIssue` with the updated fields
4. Confirm the change

#### Searching Issues
1. Build a JQL query from the user's natural language request
2. Search: `searchJiraIssuesUsingJql` with `maxResults: 10`
3. Present results as a table:

| Key | Summary | Status | Assignee | Points |
|-----|---------|--------|----------|--------|

#### Transitioning Status
1. Get available transitions: `getTransitionsForJiraIssue`
2. Present options if ambiguous
3. Ask for confirmation
4. Execute: `transitionJiraIssue`
5. Confirm the new status

#### Adding Comments
1. Use `addCommentToJiraIssue`
2. Confirm

#### Logging Work
1. Use `addWorklogToJiraIssue`
2. Confirm with time logged

---

### Workflow B: Feature Breakdown (Spec → Ticket Hierarchy)

This is the advanced workflow. The user provides a feature spec, task sheet, or description, and we generate a full ticket hierarchy under an existing epic.

#### Input Required
- A feature spec/task sheet (file path, pasted text, or verbal description)
- An existing epic key to create tickets under (e.g., PROJ-100)
- Optionally: team members to assign to

If any of these are missing, ask for them.

#### Step B1: Read & Analyze the Feature Spec

If a file path is provided, read it with the Read tool. Parse the feature into:
- **What is the feature?** — high-level summary
- **What are the major workstreams?** — these become **Stories**
- **What are the discrete deliverables within each workstream?** — these become **Tasks** under each Story
- **Are there any tasks complex enough to need sub-steps?** — these become **Sub-tasks** (ONLY when warranted)

#### Step B2: Get Project Metadata

1. `getJiraProjectIssueTypesMetadata` — confirm Story, Task, Sub-task types exist
2. `getJiraIssueTypeMetaWithFields` — get required/available fields for each type
3. `getJiraIssue` on the epic key — verify the epic exists, get its details

#### Step B3: Get Team Members

1. Use `lookupJiraAccountId` to resolve team member names/emails to account IDs
2. If the user hasn't specified team members, ask:
   ```
   Who should I assign these tickets to?
   Provide names or emails, or I can look up members from the project.
   ```
3. Build a name → accountId mapping for assignment

#### Step B4: Present the Proposed Hierarchy

**ALWAYS present the full breakdown for user review before creating anything.**

Format:
```
## Feature Breakdown: [Feature Name]
Epic: PROJ-100 — [Epic Summary]

### Story 1: [Workstream Name]
  Story Points: X | Assignee: [Name]
  ├── Task 1.1: [Deliverable]
  │   Story Points: X | Assignee: [Name]
  │   ├── Sub-task 1.1.1: [Sub-step] (only if complex)
  │   └── Sub-task 1.1.2: [Sub-step]
  └── Task 1.2: [Deliverable]
      Story Points: X | Assignee: [Name]

### Story 2: [Workstream Name]
  Story Points: X | Assignee: [Name]
  └── Task 2.1: [Deliverable]
      Story Points: X | Assignee: [Name]

Total: X stories, Y tasks, Z sub-tasks
```

**Hierarchy rules:**
- **Story**: A major workstream or user-facing capability. Contains multiple tasks.
- **Task**: A discrete, independently deliverable piece of work. Typically 1-5 story points.
- **Sub-task**: ONLY when a Task is complex enough (>3 story points) that sub-steps aid clarity. Most tasks should NOT have sub-tasks.

**Story point estimation:**
- Consider complexity, effort, and uncertainty
- Use Fibonacci: 1, 2, 3, 5, 8, 13
- A Story's points = sum of its Tasks' points (unless project convention differs)
- Sub-tasks subdivide the parent Task's point budget, they don't add to it

Let the user:
- Adjust the hierarchy (promote/demote items)
- Change story points
- Reassign team members
- Add/remove items
- Decide which tasks warrant sub-tasks

#### Step B5: Create Tickets (only after user confirms)

Create in order — parent first, then children — to get issue keys for linking:

1. **Create Stories** under the epic:
   - `createJiraIssue` with type=Story, parent=EPIC-KEY
   - Set: summary, description, story points, assignee, due date (if provided)
   - Store the returned issue key

2. **Create Tasks** under each Story:
   - `createJiraIssue` with type=Task, parent=STORY-KEY
   - Set: summary, description, story points, assignee, due date
   - Store the returned issue key

3. **Create Sub-tasks** (only where decided) under each Task:
   - `createJiraIssue` with type=Sub-task, parent=TASK-KEY
   - Set: summary, description, assignee

4. Show progress as you go. If any creation fails, report it and continue with the rest.

5. After all tickets are created, present a summary:
   ```
   ## Created Tickets

   Story: PROJ-101 — [Summary] (5 pts, @Alice)
     Task: PROJ-102 — [Summary] (3 pts, @Bob)
       Sub-task: PROJ-103 — [Summary] (@Bob)
       Sub-task: PROJ-104 — [Summary] (@Bob)
     Task: PROJ-105 — [Summary] (2 pts, @Alice)

   Story: PROJ-106 — [Summary] (3 pts, @Charlie)
     Task: PROJ-107 — [Summary] (3 pts, @Charlie)

   Total created: 2 stories, 3 tasks, 2 sub-tasks
   ```

---

### Workflow C: Team Assignment

When the user wants to assign or reassign tickets:

1. Get the ticket(s) — by key or JQL search
2. Look up team members: `lookupJiraAccountId` with name or email
3. Present the mapping for confirmation
4. `editJiraIssue` to set the assignee
5. Confirm

---

## Response Style

- Always confirm create/transition actions before executing
- Include Jira issue keys and links in all responses
- For searches, format results as a table (Key | Summary | Status | Assignee | Points)
- Use `maxResults: 10` and `limit: 10` for all searches
- When creating multiple tickets, show progress as you go
- If any ticket creation fails mid-batch, report the error and continue with remaining tickets
