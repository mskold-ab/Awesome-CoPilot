---
name: azure-devops-backlog-manager
description: 'Manage Azure DevOps work items and backlogs using the Azure DevOps REST API. Use when asked to connect to an Azure DevOps organization/team project, list or prioritize product backlogs, view and filter work items, create or update tasks/bugs/user stories, or adjust backlog ordering and fields across boards without relying on the Azure DevOps CLI.'
---

# Azure DevOps Backlog Manager

A skill for managing Azure DevOps work items and backlogs from within GitHub Copilot.

## When to Use This Skill

- User mentions **Azure DevOps**, **ADO**, **DevOps boards**, or **work items**
- User asks to **list projects**, **list team project backlogs**, or **see the backlog**
- User wants to **create, update, or link work items** (user stories, bugs, tasks, features)
- User wants to **reorder / prioritize** items in a backlog (e.g., move to top, adjust priority)
- User wants to **filter/sort** backlog by area, iteration, state, tags, or assignee

## Prerequisites

- An Azure DevOps organization and at least one team project
- A **Personal Access Token (PAT)** with scope to read/write work items and boards (typically `Work Items (read, write)` and `Project and Team (read)`)
- The Azure DevOps organization URL (for example: `https://dev.azure.com/<org>`)
- The default team project name and team name you want to manage

Store or configure these securely in the environment (for example as environment variables):

- `AZDO_ORG_URL`
- `AZDO_PROJECT`
- `AZDO_TEAM`
- `AZDO_PAT`

## Capabilities

This skill should guide the agent to:

- **Connect to Azure DevOps**
  - Always use the Azure DevOps REST APIs (no CLI) to authenticate with PAT
  - Discover available projects and teams using the appropriate REST endpoints when needed

- **List Team Projects and Backlogs**
  - List all team projects in the organization
  - List boards/backlogs for a given team project
  - Show basic metadata (name, id, visibility, default team)

- **List iterations**
  - Show which iterations are active and their dates
   - For project-level iteration tree, use scripts/list-project-iterations.ps1
   - For team iterations with dates/timeframe, use scripts/list-team-iterations.ps1

- **Create iterations**
  - Create new iterations with specified names and dates

- **Query and List Work Items**
  - Use WIQL or REST queries to list items in:
    - Product backlog
    - Sprint backlog
    - Specific area/iteration paths
  - Show key fields: ID, Title, Work Item Type, State, Priority/Order, Assigned To, Tags
  - Support filters (e.g. `state=New`, `type=Bug`, `assignedTo=me`)

- **Prioritize and Reorder Backlog Items**
  - Adjust the **backlog order** (e.g., `Microsoft.VSTS.Common.BacklogPriority` or equivalent ordering field)
  - Move work items to the **top**, **bottom**, or relative to another item
  - Batch-update priority/order for a list of IDs

- **Create and Update Work Items**
  - Create new User Stories, Bugs, Tasks, etc.
  - Update fields on existing items:
    - Title, Description
    - State, Reason
    - Assigned To
    - Area Path, Iteration Path
    - Story Points / Effort, Priority, Tags
  - Add comments / discussion entries when supported

- **Backlog Housekeeping**
  - Identify stale items (e.g., not updated recently)
  - Flag or move deprecated/duplicate items
  - Suggest grouping under Epics/Features (based on titles/tags)

## Step-by-Step Workflows

### 1. Connect and Discover Team Project

1. Ensure `AZDO_ORG_URL`, `AZDO_PAT`, and optionally `AZDO_PROJECT`/`AZDO_TEAM` are configured.
2. If the user does not specify a project, call the Azure DevOps **Projects API** to list projects and ask which one to use.
3. Cache the chosen organization, project, and team context for subsequent operations in the session.

### 2. List and Inspect Backlog

1. Resolve the target **team project** and **team**.
2. Use Azure DevOps **Boards/Backlogs API** or **WIQL** queries to fetch backlog items.
3. Sort results by **backlog order** / **priority**.
4. Present a concise view (e.g., `ID  Title  Type  State  Priority`).
5. If the user asks for more detail on an item, fetch full work item details and show the requested fields.

### 3. Prioritize / Reorder Backlog Items

1. Accept user intent such as:
   - "Move item 123 to the top of the backlog"
   - "Move items 101, 102 after item 200"
   - "Increase priority of all bugs tagged `critical`"
2. Compute the new desired order using the appropriate ordering field.
3. Send **PATCH** requests to update work item ordering.
4. Confirm the new relative order to the user.

### 4. Create or Update Work Items

1. Parse the user request, e.g.:
   - "Create a user story for X with acceptance criteria Y"
   - "Update bug 456: set state to Resolved and assign to Alice"
2. Map natural language into Azure DevOps work item fields.
3. Call the **Work Items API** with JSON Patch documents to create or update items.
4. On updates, preserve unspecified fields and only patch what the user requested.
5. Return the resulting work item IDs and a short summary of changes.

## Troubleshooting

- **Authentication errors**:
  - Verify `AZDO_PAT` is valid, not expired, and has required scopes.
  - Confirm `AZDO_ORG_URL` matches the organization that the PAT belongs to.
- **Project or team not found**:
  - List available projects/teams and ask the user which one to target.
  - Ensure `AZDO_PROJECT` and `AZDO_TEAM` are spelled exactly as in Azure DevOps.
- **Insufficient permissions**:
  - Request that the user update PAT scopes or permissions in Azure DevOps.
- **Ordering/priority field differences**:
  - Some processes use different fields for backlog order; infer and remember the correct field (`Backlog Priority`, `Stack Rank`, `Order`) by inspecting existing work items.

## References

- Azure DevOps REST API Overview: https://learn.microsoft.com/azure/devops/integrate/rest-api-overview
- Work Items - REST API: https://learn.microsoft.com/rest/api/azure/devops/wit/work-items
- WIQL (Work Item Query Language): https://learn.microsoft.com/azure/devops/boards/queries/wiql-syntax
- Boards and Backlogs: https://learn.microsoft.com/azure/devops/boards/backlogs
