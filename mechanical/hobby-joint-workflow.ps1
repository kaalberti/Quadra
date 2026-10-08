. "$PSScriptRoot/measurement-workflow.ps1"
function Resume-JointTask {
    $script:TaskText=[IO.File]::ReadAllText((Join-Path $script:Repo 'NEXT_TASK.md'))
    $match=[regex]::Match($script:TaskText,'# (MEC-\d+): ([^\r\n]+)')
    if (-not $match.Success -or $script:TaskText -match '## Completion') { throw 'No active bounded task' }
    $script:TaskId=$match.Groups[1].Value
    $script:TaskTitle=$match.Groups[2].Value
}
function Compile-JointPart([string]$Source,[string]$Name,[string[]]$Definitions=@()) {
    $cad=Join-Path $PSScriptRoot 'tools/openscad-2021.01/openscad.com'
    $output=Join-Path $PSScriptRoot "$Name.stl"
    $args=@('-o',$output)
    foreach($definition in $Definitions) { $args+=@('-D',$definition) }
    $args+=(Join-Path $PSScriptRoot $Source)
    $log=(& $cad @args 2>&1 | Out-String)
    if($LASTEXITCODE -ne 0 -or $log -match 'ERROR:|WARNING:') { throw "CAD failed: $Name`n$log" }
    if($log -notmatch 'Simple:\s+yes') { throw "Not a simple solid: $Name" }
    Write-RepoText "mechanical/$Name-compile.log" $log
    Write-Output "Compiled: $Name"
}
