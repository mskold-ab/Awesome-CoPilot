param(
    [string]$OrgUrl = $env:AZDO_ORG_URL,
    [string]$Project = "Enhanced Export",
    [string]$Pat = $env:AZDO_PAT
)

if (-not $OrgUrl) {
    $OrgUrl = "https://dev.azure.com/mskold"
}

if (-not $Pat) {
    Write-Error "AZDO_PAT environment variable or -Pat parameter is required (with Work Items read access)."
    exit 1
}

$base64Auth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$Pat"))
$Headers = @{ Authorization = "Basic $base64Auth" }

Write-Host "Using organization: $OrgUrl" -ForegroundColor Cyan
Write-Host "Using project: $Project" -ForegroundColor Cyan

# 1. Run WIQL to get all work item IDs for the project
$wiqlBody = @{
  query = @"
SELECT
    [System.Id],
    [System.WorkItemType],
    [System.Title],
    [System.State]
FROM WorkItems
WHERE
    [System.TeamProject] = '$Project'
ORDER BY [System.ChangedDate] DESC
"@
} | ConvertTo-Json

$wiqlUri = "$OrgUrl/$Project/_apis/wit/wiql?api-version=7.1-preview.2"

try {
    $wiqlResult = Invoke-RestMethod -Method Post -Uri $wiqlUri -Headers $Headers -Body $wiqlBody -ContentType "application/json"
} catch {
    Write-Error "Failed to execute WIQL query: $($_.Exception.Message)"
    exit 1
}

if (-not $wiqlResult.workItems -or $wiqlResult.workItems.Count -eq 0) {
    Write-Host "No work items found in project '$Project'." -ForegroundColor Yellow
    exit 0
}

$allIds = $wiqlResult.workItems | Select-Object -ExpandProperty id
Write-Host "Found $($allIds.Count) work items. Fetching details..." -ForegroundColor Green

# 2. Fetch work item details in batches (max 200 IDs per request is safe)
$batchSize = 200
$results = @()
for ($i = 0; $i -lt $allIds.Count; $i += $batchSize) {
    $batchIds = $allIds[$i..([Math]::Min($i + $batchSize - 1, $allIds.Count - 1))]
    $idsParam = ($batchIds -join ",")

    $itemsUri = "$OrgUrl/_apis/wit/workitems?ids=$idsParam&api-version=7.1-preview.3"
    try {
        $items = Invoke-RestMethod -Method Get -Uri $itemsUri -Headers $Headers
        $results += $items.value
    } catch {
        Write-Error "Failed to fetch work item details for IDs: $idsParam. Error: $($_.Exception.Message)"
    }
}

if (-not $results -or $results.Count -eq 0) {
    Write-Host "No work item details returned." -ForegroundColor Yellow
    exit 0
}

# 3. Output a concise table of work items
$results |
  Select-Object @{Name="ID";Expression={$_.id}},
                @{Name="Title";Expression={$_.fields.'System.Title'}},
                @{Name="Type";Expression={$_.fields.'System.WorkItemType'}},
                @{Name="State";Expression={$_.fields.'System.State'}},
                @{Name="AssignedTo";Expression={$_.fields.'System.AssignedTo'.displayName}},
                @{Name="ChangedDate";Expression={$_.fields.'System.ChangedDate'}} |
  Sort-Object ID |
  Format-Table -AutoSize
