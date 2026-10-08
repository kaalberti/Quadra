Set-StrictMode -Version Latest
$ErrorActionPreference='Stop'
$script:Repo=Split-Path $PSScriptRoot -Parent
function Write-RepoText([string]$Relative,[string]$Text){
 $p=Join-Path $script:Repo $Relative
 [System.IO.File]::WriteAllText($p,$Text,[System.Text.UTF8Encoding]::new($false))
}
function Save-Report([string]$Relative,$Value){Write-RepoText $Relative (($Value|ConvertTo-Json -Depth 30)+"`n")}
function Start-BoundedTask([int]$Number,[string]$Title,[string]$Outputs,[string]$Validation,[int]$BatchFirst=32,[int]$BatchLast=41){
 $id='MEC-{0:000}' -f $Number
 $template=[System.IO.File]::ReadAllText((Join-Path $script:Repo 'TASK_TEMPLATE.md'))
 $script:TaskNumber=$Number;$script:TaskId=$id;$script:TaskTitle=$Title
 $script:TaskText=$template+@"

# $id`: $Title

## Objective
$Title. One independently checkable result within stage4.

## Inputs
PROJECT.md, STATUS.md, decisions/design-decisions.md and saved mechanical contracts.

## Outputs
$Outputs

## Validation
$Validation

## Assumptions and boundaries
Offline repository evidence only unless the user approves browsing. No dependency
change, deletion, supplier contact or actual measurement. Geometry/load proposals
are not physical qualification. Preserve historical contracts and actual inventory.

## Stop
Record this result before advancing. Authorized batch MEC-$BatchFirst through
MEC-$BatchLast; stop after MEC-$BatchLast. No physical prototype or following major stage.
"@
 Write-RepoText 'NEXT_TASK.md' $script:TaskText
 Write-RepoText "docs/tasks/$id.md" $script:TaskText
}
function Complete-BoundedTask([string]$Summary,[string]$Next){
 $completion="`n`n## Completion`n$script:TaskId complete 2026-10-08. $Summary`nNext suggested task: $Next`n"
 Write-RepoText 'NEXT_TASK.md' ($script:TaskText+$completion)
 Write-RepoText "docs/tasks/$script:TaskId.md" ($script:TaskText+$completion)
 [System.IO.File]::AppendAllText((Join-Path $script:Repo 'STATUS.md'),"`n## $script:TaskId complete - 2026-10-08`n$script:TaskTitle. $Summary`nNext: $Next`n")
 [System.IO.File]::AppendAllText((Join-Path $script:Repo 'decisions/design-decisions.md'),"`n## $script:TaskId - $script:TaskTitle`n$Summary`n")
 Write-Host "$script:TaskId complete: $script:TaskTitle"
}
function Assert-Check([bool]$Condition,[string]$Message){if(-not $Condition){throw "CHECK FAILED: $Message"}}
function Assert-Near([double]$Actual,[double]$Expected,[string]$Message){Assert-Check ([math]::Abs($Actual-$Expected) -le 1e-10) "$Message ($Actual vs $Expected)"}
function Assert-Saved([string]$Relative,$Expected){
 $actual=Get-Content (Join-Path $script:Repo $Relative) -Raw|ConvertFrom-Json
 Assert-Check (($actual|ConvertTo-Json -Depth 30 -Compress) -eq ($Expected|ConvertTo-Json -Depth 30 -Compress)) "Saved regeneration: $Relative"
}
