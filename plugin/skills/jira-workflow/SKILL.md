---
name: jira
description: Auto-triggers when the user mentions Jira tasks like creating tickets, updating story points, searching issues, changing ticket status, breaking down features into tickets, or assigning team members. Trigger phrases include "jira", "ticket", "story points", "sprint", "backlog", "issue", "epic", "subtask", "break down feature", "create stories", "assign to", and Jira key patterns like "PROJ-123".
---

# Jira Workflow Skill

This skill activates when the user mentions Jira-related work in conversation.

## When This Applies
- User mentions creating a ticket/issue/story/task
- User mentions updating story points or estimates
- User mentions searching for issues
- User mentions transitioning/moving ticket status
- User references a Jira issue key (e.g., PROJ-123)
- User mentions sprint, backlog, or board operations
- User wants to break down a feature into tickets
- User wants to assign tickets to team members
- User provides a feature spec and mentions creating Jira tickets from it

## What To Do

Invoke `/nexus:jira` with the user's request. The jira command handles everything — MCP setup detection, project context loading, and all Jira workflows.

If the user says something like "break down this feature into Jira tickets", ask them for:
1. The feature spec (file path or description)
2. The epic key to create tickets under

Then invoke `/nexus:jira break down feature from [spec] into [EPIC-KEY]`
