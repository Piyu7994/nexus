# Figma MCP Integration — Implementation Plan

## Overview
Add Figma as the second MCP server in the Nexus plugin, following the same `mcp-remote` bridge pattern used for Jira/Atlassian. The integration must be rate-limit-aware to protect users on low-tier Figma plans (Starter: 6 calls/month).

## Current State Analysis
- Plugin has one MCP server: `atlassian` in `plugin/.mcp.json:1-6`
- One command: `plugin/commands/jira.md` (266 lines, 3 workflows)
- One skill: `plugin/skills/jira-workflow/SKILL.md`
- Plugin manifest at `plugin/.claude-plugin/plugin.json:1-10` — keywords only mention Jira
- Adding a new tool is documented in `plugin/CLAUDE.md:14-16`: 3-file pattern

## Desired End State
- `/nexus:figma` command available with all 16 Figma MCP tools
- Auto-trigger skill activates on Figma-related keywords
- Rate-limit-aware: checks plan via `whoami` before heavy operations, batches calls efficiently, warns users on low-tier plans
- OAuth setup flow mirrors Jira's pattern
- README updated with Figma section

## What We're NOT Doing
- Desktop server support (local Figma app at `127.0.0.1:3845`)
- Custom high-level workflows (like Jira's feature breakdown) — keep it general-purpose for now
- Rate limit tracking/counting logic — just warn and minimize calls
- `MAX_MCP_OUTPUT_TOKENS` auto-configuration — document it, don't enforce it

## Implementation Approach
Follow the established 3-file pattern exactly. The command file is the most critical piece — it needs built-in rate-limit awareness that the Jira command doesn't have.

---

## Phase 1: MCP Server + Command File

### Overview
Add the Figma server declaration and the `/nexus:figma` slash command.

### Changes Required

#### 1. Server Declaration
**File**: `plugin/.mcp.json`
**Changes**: Add `figma` server entry alongside `atlassian`

```json
{
  "atlassian": {
    "command": "npx",
    "args": ["-y", "mcp-remote@latest", "https://mcp.atlassian.com/v1/mcp"]
  },
  "figma": {
    "command": "npx",
    "args": ["-y", "mcp-remote@latest", "https://mcp.figma.com/mcp"]
  }
}
```

#### 2. Slash Command
**File**: `plugin/commands/figma.md` (new)
**Changes**: Full command file with frontmatter + behavioral spec

Key design decisions for rate-limit awareness:
- **Step 1**: No-args usage menu (no MCP calls)
- **Step 2**: Connection check using `whoami` (rate-limit-exempt) — also extracts plan info
- **Step 3**: Based on plan info from `whoami`:
  - If Starter/View/Collab seat → warn about 6 calls/month limit, ask user to confirm before ANY tool call, suggest they upgrade
  - If Professional/Org/Enterprise → proceed normally with standard rate awareness
- **Tool call minimization strategies**:
  - Use `get_metadata` before `get_design_context` to narrow scope (avoids wasting a call on a too-large selection)
  - Never make speculative/exploratory calls — always confirm intent first
  - Batch related information gathering where possible
  - Prefer `get_metadata` (lightweight) over `get_design_context` (heavy) when full design context isn't needed

Frontmatter `allowed-tools` list (all 16 Figma tools + built-ins):
```yaml
allowed-tools: [
  "mcp__plugin_nexus_figma__get_design_context",
  "mcp__plugin_nexus_figma__get_variable_defs",
  "mcp__plugin_nexus_figma__get_metadata",
  "mcp__plugin_nexus_figma__get_screenshot",
  "mcp__plugin_nexus_figma__get_figjam",
  "mcp__plugin_nexus_figma__get_code_connect_map",
  "mcp__plugin_nexus_figma__add_code_connect_map",
  "mcp__plugin_nexus_figma__get_code_connect_suggestions",
  "mcp__plugin_nexus_figma__send_code_connect_mappings",
  "mcp__plugin_nexus_figma__search_design_system",
  "mcp__plugin_nexus_figma__use_figma",
  "mcp__plugin_nexus_figma__generate_figma_design",
  "mcp__plugin_nexus_figma__generate_diagram",
  "mcp__plugin_nexus_figma__create_new_file",
  "mcp__plugin_nexus_figma__create_design_system_rules",
  "mcp__plugin_nexus_figma__whoami",
  "Bash",
  "Read",
  "Write",
  "Edit",
  "Glob",
  "Grep"
]
```

Command body structure:
- Step 1: No-args → usage menu
- Step 2: Connection check via `whoami` (exempt from rate limits) → extract plan/seat info
- Step 3: Rate-limit gate — warn if low-tier, confirm before proceeding
- Step 4: Route to workflows:
  - **Workflow A**: Design inspection (get_metadata, get_design_context, get_screenshot, get_variable_defs)
  - **Workflow B**: Code Connect (get_code_connect_map, add_code_connect_map, get_code_connect_suggestions, send_code_connect_mappings)
  - **Workflow C**: Design system search (search_design_system, create_design_system_rules)
  - **Workflow D**: Create/edit designs (use_figma, generate_figma_design, create_new_file)
  - **Workflow E**: FigJam diagrams (get_figjam, generate_diagram)

### Success Criteria

#### Automated Verification:
- [ ] Plugin loads with both servers: `claude --plugin-dir plugin/ --help` doesn't error
- [ ] `.mcp.json` is valid JSON

#### Manual Verification:
- [ ] `/nexus:figma` with no args shows usage menu
- [ ] `/nexus:figma whoami` triggers OAuth flow on first use
- [ ] After auth, `whoami` returns plan info
- [ ] On Starter plan, warning is shown before any rated tool call

**Implementation Note**: After completing this phase, test the OAuth flow and `whoami` response to confirm plan detection works before proceeding.

---

## Phase 2: Auto-Trigger Skill

### Overview
Add the skill file so Figma-related conversation auto-triggers `/nexus:figma`.

### Changes Required

#### 1. Skill File
**File**: `plugin/skills/figma-workflow/SKILL.md` (new)
**Changes**: Skill with trigger phrases for Figma-related keywords

```markdown
---
name: figma
description: Auto-triggers when the user mentions Figma-related tasks like inspecting designs, extracting design tokens, getting screenshots, searching design systems, creating or editing Figma files, generating diagrams, or working with Code Connect. Trigger phrases include "figma", "design", "design tokens", "design system", "component", "frame", "layer", "screenshot", "code connect", "figjam", "diagram", "mockup", "prototype", "variant", "figma file", and Figma URL patterns.
---

# Figma Workflow Skill

This skill activates when the user mentions Figma-related work in conversation.

## When This Applies
- User mentions inspecting or extracting from a Figma design
- User mentions design tokens, variables, or styles
- User wants a screenshot of a Figma selection
- User mentions Code Connect or component mapping
- User wants to search a design system/library
- User wants to create or edit a Figma file
- User mentions FigJam or diagram generation
- User shares a Figma URL

## What To Do
Invoke `/nexus:figma` with the user's request.
```

### Success Criteria

#### Manual Verification:
- [ ] Saying "get the design tokens from Figma" triggers the skill
- [ ] Skill correctly delegates to `/nexus:figma`

---

## Phase 3: Plugin Metadata + README Updates

### Overview
Update manifests and documentation to reflect Figma support.

### Changes Required

#### 1. Plugin Manifest
**File**: `plugin/.claude-plugin/plugin.json`
**Changes**: Add `figma` to keywords

#### 2. Marketplace Manifest
**File**: `.claude-plugin/marketplace.json`
**Changes**: Update description to mention Figma

#### 3. Plugin CLAUDE.md
**File**: `plugin/CLAUDE.md`
**Changes**: Update "Currently supports" line to include Figma

#### 4. README
**File**: `README.md`
**Changes**:
- Add Figma to the intro
- Add Figma setup section (OAuth flow, `MAX_MCP_OUTPUT_TOKENS` note)
- Add `/nexus:figma` usage examples
- Add rate limit warning/table
- List all 16 Figma tools

### Success Criteria

#### Automated Verification:
- [ ] All JSON files are valid
- [ ] No broken markdown links

#### Manual Verification:
- [ ] README accurately describes both Jira and Figma capabilities
- [ ] Rate limit information is prominent and clear

---

## Testing Strategy

### Manual Testing Steps:
1. Load plugin: `claude --plugin-dir /path/to/nexus/plugin`
2. Run `/nexus:figma` — should show usage menu (0 MCP calls)
3. Run `/nexus:figma whoami` — should trigger OAuth if first time, then return plan info
4. Run `/nexus:figma get the metadata for [figma-url]` — should work after auth
5. Verify rate-limit warning appears for low-tier plans
6. Verify `/nexus:jira` still works (regression check)

## Rate Limit Protection Strategy

The core mechanism:
1. `whoami` is called first (rate-limit-exempt) to detect the user's plan
2. Based on plan, set behavior:
   - **Starter / View / Collab**: Warn that they have 6 calls/month. Before EVERY rated tool call, show: "This will use 1 of your ~6 monthly Figma MCP calls. Proceed?" Only continue with explicit confirmation.
   - **Professional**: Normal usage with gentle reminder about 200/day limit
   - **Organization / Enterprise**: No warnings needed
3. Tool call minimization:
   - Always ask what specifically the user needs before making calls
   - Use `get_metadata` (lightweight) to scope before `get_design_context` (heavy)
   - Never make speculative or "let me check" calls — always confirm intent
   - Combine related questions into single tool calls where possible

## Performance Considerations
- `mcp-remote` adds a small latency overhead for the stdio-to-HTTP bridge
- Figma responses can be large (design context) — recommend `MAX_MCP_OUTPUT_TOKENS=50000`

## References
- Research findings: `specs/research/figma-mcp/findings.md`
- Figma MCP docs: https://developers.figma.com/docs/figma-mcp-server/
- Figma tools reference: https://developers.figma.com/docs/figma-mcp-server/tools-and-prompts/
- Rate limits: https://developers.figma.com/docs/figma-mcp-server/plans-access-and-permissions/
- Existing pattern: `plugin/commands/jira.md`
