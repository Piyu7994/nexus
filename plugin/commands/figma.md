---
description: Work with Figma — inspect designs, extract design tokens, get screenshots, search design systems, create/edit files, generate diagrams, manage Code Connect mappings
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
argument-hint: [what you want to do, e.g. "get design context for <figma-url>", "extract design tokens", "search design system for button component"]
---

# Figma — Nexus

The user wants to work with Figma. Their request: $ARGUMENTS

---

## Step 1: Check if user provided arguments

If `$ARGUMENTS` is empty (user just typed `/nexus:figma` with nothing else):

**Do NOT make any MCP calls.** Simply ask the user:

```
What would you like to do? Please provide one of:

- A **Figma file/frame URL** + what you want to do
- A **design system query** (e.g., search for a component)
- A **create/edit request** (e.g., create a new file, generate a diagram)

Examples:
  /nexus:figma get design context for https://figma.com/design/...
  /nexus:figma extract design tokens from https://figma.com/design/...
  /nexus:figma search design system for button component
  /nexus:figma take a screenshot of https://figma.com/design/...
  /nexus:figma create a new Figma file
  /nexus:figma generate a flowchart diagram from this mermaid: ...
  /nexus:figma set up Code Connect mappings
```

**STOP here.** Wait for the user to respond with their request.

---

## Step 2: MCP Connection & Plan Check

The user has provided arguments. Before executing, verify the Figma MCP is connected and check the user's plan.

**Call `whoami`** — this tool is rate-limit-exempt and serves two purposes:
1. Verifies the MCP connection is active
2. Returns the user's plan and seat type for rate-limit awareness

If the `whoami` call fails with a connection error or "tool not found":

1. Run the environment check: `bash ${CLAUDE_PLUGIN_ROOT}/scripts/check-mcp-status.sh`
2. Inform the user:
   ```
   The Figma MCP server is not connected yet.

   This plugin bundles the config automatically. To complete setup:
   1. Restart Claude Code with this plugin loaded
   2. A browser window will open for Figma OAuth — authorize access
   3. Run `/nexus:figma` again after authorizing

   Requirements: Node.js v18+

   Tip: If Figma responses get truncated, set MAX_MCP_OUTPUT_TOKENS=50000 in your environment.
   ```
3. **STOP here.** Do not proceed with any Figma operations.

If the call succeeds, **store the plan/seat info** and continue to Step 3.

---

## Step 3: Rate-Limit Gate

Based on the plan info from `whoami`, determine the user's rate limit tier:

### Tier 1: Starter plan or View/Collab seats (any paid plan)
**Limit: 6 tool calls per MONTH**

Display this warning ONCE at the start:
```
⚠️ Your Figma plan allows only 6 MCP tool calls per month.
Each operation below (except whoami) counts against this limit.
I'll confirm before every call so you stay in control.
```

**For EVERY subsequent rated tool call:**
- Tell the user exactly which tool you're about to call and why
- Ask: "This will use 1 of your limited monthly Figma MCP calls. Proceed? (yes/no)"
- Only call the tool if the user explicitly confirms
- If the user declines, suggest alternatives (e.g., "You could inspect the design manually in Figma and paste the details here instead")

### Tier 2: Dev/Full seat on Professional plan
**Limit: 15 calls/min, 200 calls/day**

Display a brief note:
```
Your plan allows 200 Figma MCP calls/day. Proceeding normally.
```
Proceed without per-call confirmation, but still minimize unnecessary calls.

### Tier 3: Dev/Full seat on Organization or Enterprise plan
**Limit: 20 calls/min, 200-600 calls/day**

No warnings needed. Proceed normally.

**Rate-limit-exempt tools** (never count against limits): `add_code_connect_map`, `generate_figma_design`, `whoami`

---

## Step 4: Handle the Request

Route to the appropriate workflow below. In ALL workflows:
- **Never make speculative calls** — always confirm what the user needs first
- **Use `get_metadata` before `get_design_context`** when dealing with large designs (get_metadata is lighter and helps scope the request)
- **Ask the user to narrow scope** if a design/frame appears to be very large

---

### Workflow A: Design Inspection

For requests about inspecting, extracting, or understanding a design.

#### Getting Design Context (detailed code-ready output)
1. If the target might be a large frame/page, first call `get_metadata` to see the layer tree
2. Ask the user to confirm which specific layer(s) they want context for
3. Call `get_design_context` on the specific selection
4. Present the output (React+Tailwind by default)

#### Getting Design Tokens / Variables
1. Call `get_variable_defs` for the selection
2. Present tokens organized by category (colors, spacing, typography)

#### Getting a Screenshot
1. Call `get_screenshot` for the selection
2. Display the result

#### Getting Layer Metadata
1. Call `get_metadata` for the selection
2. Present the XML layer tree with key info (names, types, positions, sizes)

**Tip**: If the user wants both metadata and design context, get metadata first to scope, then get context for specific layers — this saves calls vs. getting context for an entire page.

---

### Workflow B: Code Connect

For managing mappings between Figma components and code components.

#### Viewing Existing Mappings
1. Call `get_code_connect_map`
2. Present the node → component mappings

#### Adding a Mapping
1. Call `add_code_connect_map` with the node ID and component path
2. Confirm the mapping was added
3. Note: `add_code_connect_map` is rate-limit-exempt

#### Getting Suggestions
1. Call `get_code_connect_suggestions` to detect potential mappings
2. Present suggestions for user review
3. If user approves, call `send_code_connect_mappings` to confirm

---

### Workflow C: Design System Search

For searching connected design libraries.

1. Call `search_design_system` with the user's query
2. Present results: components, variables, and styles found
3. If the user wants to create design system rules for their codebase, call `create_design_system_rules`

---

### Workflow D: Create / Edit Designs

For creating new files or editing existing designs.

#### Creating a New File
1. Ask: Figma Design file or FigJam file?
2. Call `create_new_file` with the appropriate type
3. Return the file URL

#### Editing Designs (use_figma)
1. Confirm exactly what the user wants to create/edit/delete
2. Call `use_figma` with the specific operation
3. Confirm the result
4. Note: This is a beta feature and may become paid in the future

#### Generating Design from Live UI
1. Call `generate_figma_design` to capture and send to Figma
2. Note: `generate_figma_design` is rate-limit-exempt

---

### Workflow E: FigJam Diagrams

For working with FigJam boards and diagrams.

#### Reading a FigJam Board
1. Call `get_figjam` to convert the board to XML
2. Present the structured content

#### Generating a Diagram
1. Ask the user for the diagram type (flowchart, Gantt, state, sequence) if not clear
2. Accept Mermaid syntax input or generate it from the user's description
3. Call `generate_diagram` with the Mermaid content
4. Return the result

---

## Response Style

- Always confirm create/edit actions before executing
- Include Figma file URLs in responses when available
- When presenting design context, format it cleanly with code blocks
- For design tokens, organize by category (colors, spacing, typography, etc.)
- If a response seems truncated, suggest the user set `MAX_MCP_OUTPUT_TOKENS=50000`
- On rate-limit errors, immediately inform the user of their limit and suggest waiting or upgrading
