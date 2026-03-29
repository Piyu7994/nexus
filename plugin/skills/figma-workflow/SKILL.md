---
name: figma
description: Auto-triggers when the user mentions Figma-related tasks like inspecting designs, extracting design tokens, getting screenshots, searching design systems, creating or editing Figma files, generating diagrams, or working with Code Connect. Trigger phrases include "figma", "design tokens", "design system", "component mapping", "code connect", "figjam", "diagram", "mockup", "frame", "layer", "variant", "screenshot of design", and Figma URL patterns like "figma.com/design/".
---

# Figma Workflow Skill

This skill activates when the user mentions Figma-related work in conversation.

## When This Applies
- User mentions inspecting or extracting from a Figma design
- User mentions design tokens, variables, or styles from Figma
- User wants a screenshot of a Figma selection
- User mentions Code Connect or component mapping
- User wants to search a design system or library in Figma
- User wants to create or edit a Figma file
- User mentions FigJam or generating a diagram
- User shares a Figma URL (figma.com/design/...)
- User mentions converting a design to code

## What To Do

Invoke `/nexus:figma` with the user's request. The figma command handles everything — MCP setup detection, plan-based rate-limit gating, and all Figma workflows.
