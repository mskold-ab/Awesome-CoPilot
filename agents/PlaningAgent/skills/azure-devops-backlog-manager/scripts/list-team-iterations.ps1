<#
.SYNOPSIS
Lists iterations configured for the current Azure DevOps team.

.REQUIRES
Env vars: AZDO_ORG_URL, AZDO_PROJECT, AZDO_TEAM, AZDO_PAT
#>

param(
    [ValidateSet("all","current","past","future")]
    [string]$Timeframe = "all"
)

if (-not $env:AZDO_ORG_URL -or -not $env:AZDO_PROJECT -or -not $env:AZDO_TEAM -or -not $env:AZDO_PAT) {
    throw "AZDO_ORG_URL, AZDO_PROJECT, AZDO_TEAM, and AZDO_PAT must be set."
}

$orgUrl  = $env:AZDO_ORG_URL.TrimEnd('/')
$project = $env:AZDO_PROJECT
$team    = $env:AZDO_TEAM
$pat     = $env:AZDO_PAT
$auth    = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$pat"))

$timeframeParam = if ($Timeframe -ne "all") { "&timeframe=$Timeframe" } else { "" }
$uri = "$orgUrl/$project/$team/_apis/work/teamsettings/iterations?api-version=7.1-preview.1$timeframeParam"

$response = Invoke-RestMethod -Uri $uri -Headers @{ Authorization = "Basic $auth" } -Method Get

$response.value |
    Select-Object name,
        path,
        @{ Name = "StartDate";  Expression = { $_.attributes.startDate } },
        @{ Name = "FinishDate"; Expression = { $_.attributes.finishDate } },
        @{ Name = "Timeframe";  Expression = { $_.attributes.timeFrame } } |
    Sort-Object StartDate |
    Format-Table -AutoSize
