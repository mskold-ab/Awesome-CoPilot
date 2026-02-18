<#
.SYNOPSIS
Lists all iteration nodes for the current Azure DevOps project.

.REQUIRES
Env vars: AZDO_ORG_URL, AZDO_PROJECT, AZDO_PAT
#>

param(
    [int]$Depth = 10
)

if (-not $env:AZDO_ORG_URL -or -not $env:AZDO_PROJECT -or -not $env:AZDO_PAT) {
    throw "AZDO_ORG_URL, AZDO_PROJECT, and AZDO_PAT must be set."
}

$orgUrl  = $env:AZDO_ORG_URL.TrimEnd('/')
$project = $env:AZDO_PROJECT
$pat     = $env:AZDO_PAT
$auth    = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$pat"))

$uri = "$orgUrl/$project/_apis/wit/classificationnodes/iterations?`$depth=$Depth&api-version=7.1-preview.2"

$response = Invoke-RestMethod -Uri $uri -Headers @{ Authorization = "Basic $auth" } -Method Get

function Flatten-Iterations {
    param(
        [Parameter(Mandatory)]
        $Node,
        [string]$ParentPath = ""
    )

    $currentPath = if ($ParentPath) { "$ParentPath\$($Node.name)" } else { $Node.name }

    [PSCustomObject]@{
        Name       = $Node.name
        Path       = $currentPath
        StartDate  = $Node.attributes.startDate
        FinishDate = $Node.attributes.finishDate
    }

    if ($Node.children) {
        foreach ($child in $Node.children) {
            Flatten-Iterations -Node $child -ParentPath $currentPath
        }
    }
}

Flatten-Iterations -Node $response |
    Sort-Object Path |
    Format-Table Name, Path, StartDate, FinishDate -AutoSize
