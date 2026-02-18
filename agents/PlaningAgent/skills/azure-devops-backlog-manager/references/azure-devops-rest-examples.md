# Azure DevOps REST Examples

Practical examples for the `azure-devops-backlog-manager` skill using the Azure DevOps REST APIs.

> NOTE: Replace placeholders like `<ORG>`, `<PROJECT>`, `<TEAM>`, `<PAT>` with real values.

## 1. Authentication Setup (PowerShell)

```powershell
$OrgUrl = "https://dev.azure.com/<ORG>"
$Project = "<PROJECT>"
$Pat = "<PAT>"   # Personal Access Token with Work Items (read, write) and Project/Team (read)

$base64Auth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$Pat"))
$Headers = @{ Authorization = "Basic $base64Auth" }
```

## 2. List Projects

```powershell
$uri = "$OrgUrl/_apis/projects?api-version=7.1-preview.4"
$response = Invoke-RestMethod -Method Get -Uri $uri -Headers $Headers
$response.value | Select-Object id, name, state, visibility
```

## 3. List Teams in a Project

```powershell
$uri = "$OrgUrl/_apis/projects/$Project/teams?api-version=7.1-preview.3"
$response = Invoke-RestMethod -Method Get -Uri $uri -Headers $Headers
$response.value | Select-Object id, name, description
```

## 4. WIQL Query – Product Backlog Items

Example WIQL to get all active items in the product backlog for a project:

```powershell
$wiqlBody = @{
  query = @"
SELECT
    [System.Id],
    [System.WorkItemType],
    [System.Title],
    [System.State],
    [Microsoft.VSTS.Common.Priority]
FROM WorkItems
WHERE
    [System.TeamProject] = '$Project'
    AND [System.WorkItemType] IN ('Product Backlog Item', 'User Story', 'Bug')
ORDER BY [Microsoft.VSTS.Common.BacklogPriority] ASC
"@
} | ConvertTo-Json

$wiqlUri = "$OrgUrl/$Project/_apis/wit/wiql?api-version=7.1-preview.2"
$wiqlResult = Invoke-RestMethod -Method Post -Uri $wiqlUri -Headers $Headers -Body $wiqlBody -ContentType "application/json"

$ids = ($wiqlResult.workItems | Select-Object -ExpandProperty id) -join ","
```

## 5. Get Work Item Details by IDs

```powershell
if (-not [string]::IsNullOrWhiteSpace($ids)) {
  $itemsUri = "$OrgUrl/_apis/wit/workitems?ids=$ids&api-version=7.1-preview.3"
  $items = Invoke-RestMethod -Method Get -Uri $itemsUri -Headers $Headers

  $items.value |
    Select-Object @{Name="ID";Expression={$_.id}},
                  @{Name="Title";Expression={$_.fields.'System.Title'}},
                  @{Name="Type";Expression={$_.fields.'System.WorkItemType'}},
                  @{Name="State";Expression={$_.fields.'System.State'}},
                  @{Name="Priority";Expression={$_.fields.'Microsoft.VSTS.Common.Priority'}}
}
```

## 6. Update a Work Item (Title, State, Assigned To)

```powershell
$workItemId = 123
$patch = @(
  @{ op = "add"; path = "/fields/System.Title";        value = "New title from REST" },
  @{ op = "add"; path = "/fields/System.State";        value = "Active" },
  @{ op = "add"; path = "/fields/System.AssignedTo";   value = "user@domain.com" }
) | ConvertTo-Json

$uri = "$OrgUrl/$Project/_apis/wit/workitems/$workItemId?api-version=7.1-preview.3"
$response = Invoke-RestMethod -Method Patch -Uri $uri -Headers $Headers -Body $patch -ContentType "application/json-patch+json"
```

## 7. Create a New User Story

```powershell
$patch = @(
  @{ op = "add"; path = "/fields/System.Title";              value = "As a user, I want..." },
  @{ op = "add"; path = "/fields/System.Description";        value = "Detailed description" },
  @{ op = "add"; path = "/fields/System.AssignedTo";         value = "user@domain.com" },
  @{ op = "add"; path = "/fields/System.AreaPath";           value = "$Project" },
  @{ op = "add"; path = "/fields/System.IterationPath";      value = "$Project" },
  @{ op = "add"; path = "/fields/Microsoft.VSTS.Common.Priority"; value = 2 }
) | ConvertTo-Json

$uri = "$OrgUrl/$Project/_apis/wit/workitems/$('User Story')?api-version=7.1-preview.3"
$response = Invoke-RestMethod -Method Patch -Uri $uri -Headers $Headers -Body $patch -ContentType "application/json-patch+json"
```

## 8. Adjust Backlog Order / Priority

Many processes use `Microsoft.VSTS.Common.BacklogPriority` or `Microsoft.VSTS.Common.StackRank` for ordering. Example to move an item near the top:

```powershell
$workItemId = 456
$patch = @(
  @{ op = "add"; path = "/fields/Microsoft.VSTS.Common.BacklogPriority"; value = 1.0 }
) | ConvertTo-Json

$uri = "$OrgUrl/$Project/_apis/wit/workitems/$workItemId?api-version=7.1-preview.3"
$response = Invoke-RestMethod -Method Patch -Uri $uri -Headers $Headers -Body $patch -ContentType "application/json-patch+json"
```

## 9. Example curl WIQL Request (bash)

```bash
ORG_URL="https://dev.azure.com/<ORG>"
PROJECT="<PROJECT>"
PAT="<PAT>"

WIQL_JSON='{
  "query": "SELECT [System.Id], [System.Title] FROM WorkItems WHERE [System.TeamProject] = \'${PROJECT}\' ORDER BY [System.ChangedDate] DESC"
}'

curl -s \
  -u :"${PAT}" \
  -H "Content-Type: application/json" \
  -X POST \
  -d "${WIQL_JSON}" \
  "${ORG_URL}/${PROJECT}/_apis/wit/wiql?api-version=7.1-preview.2"
```
