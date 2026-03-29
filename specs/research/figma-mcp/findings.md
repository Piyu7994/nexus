# Figma MCP Integration — Research Findings

## Official Figma MCP Server

- **First-party**, built and maintained by Figma (open beta as of June 2025)
- **Remote endpoint**: `https://mcp.figma.com/mcp`
- **Auth**: OAuth via browser (no API key needed)
- **No npm package** — hosted HTTP endpoint; we'll use `mcp-remote` as a stdio bridge (same pattern as Atlassian)

## Tools Available (16 total)

| Tool | Description | Remote Only? |
|------|-------------|:---:|
| `get_design_context` | Extract design context for a layer/selection (React+Tailwind by default) | |
| `get_variable_defs` | Return variables and styles (colors, spacing, typography) | |
| `get_metadata` | Sparse XML layer tree (IDs, names, types, positions) | |
| `get_screenshot` | Screenshot of current selection | |
| `get_figjam` | Convert FigJam diagram to XML | |
| `get_code_connect_map` | Retrieve Figma node → code component mappings | |
| `add_code_connect_map` | Add a node → code component mapping | |
| `get_code_connect_suggestions` | Detect and suggest component mappings | |
| `send_code_connect_mappings` | Confirm Code Connect mappings | |
| `search_design_system` | Search connected design libraries | |
| `use_figma` | Create/edit/delete pages, frames, components, variants, etc. | Yes |
| `generate_figma_design` | Capture live web UI and send as design layers | Yes |
| `generate_diagram` | Generate FigJam diagram from Mermaid syntax | |
| `create_new_file` | Create a new blank Figma/FigJam file | |
| `create_design_system_rules` | Create agent-friendly design context rules | |
| `whoami` | Return authenticated user's email and plan info | Yes |

## Rate Limits (Critical)

| Plan / Seat | Limit |
|---|---|
| Starter plan or View/Collab seats | **6 tool calls per month** |
| Dev/Full seat on Professional plan | 15 calls/min, 200 calls/day |
| Dev/Full seat on Organization plan | 20 calls/min, 200 calls/day |
| Dev/Full seat on Enterprise plan | Unlimited/min, 600 calls/day |

**Rate-limit-exempt tools**: `add_code_connect_map`, `generate_figma_design`, `whoami`

## Known Issues

- **Token limit**: Figma responses can exceed Claude Code's default 25,000 token MCP output limit. Workaround: set `MAX_MCP_OUTPUT_TOKENS=50000` or higher.
- **Large designs**: `get_design_context` may truncate on large frames; use `get_metadata` first to map structure, then fetch specific layers.
- **Write features**: `use_figma` is free during beta but will become usage-based paid.

## References

- https://developers.figma.com/docs/figma-mcp-server/
- https://developers.figma.com/docs/figma-mcp-server/tools-and-prompts/
- https://developers.figma.com/docs/figma-mcp-server/remote-server-installation/
- https://developers.figma.com/docs/figma-mcp-server/plans-access-and-permissions/
- https://developers.figma.com/docs/figma-mcp-server/mcp-clients-issues/
