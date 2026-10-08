$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest
$repo=Split-Path $PSScriptRoot -Parent
$pack=Join-Path $repo 'manufacturing'
$archive=Join-Path $repo 'ARCHIVE/MFG-002-three-dof-bench-1'
$utf8=[Text.UTF8Encoding]::new($false)
function WriteJson($path,$value){[IO.File]::WriteAllText($path,($value|ConvertTo-Json -Depth 14)+"`n",$utf8)}
$manifest=Get-Content (Join-Path $pack 'release-manifest.json') -Raw|ConvertFrom-Json
if($manifest.revision -ne 'three-dof-bench-1' -or $manifest.pack_revision -ne 'MFG-002'){throw 'Expected original MFG-002 checkpoint; refuse another revision'}
if(-not(Test-Path -LiteralPath $archive)){throw 'Archive the prior pack before revising it'}
foreach($entry in $manifest.files){
 foreach($base in @($pack,$archive)){
  if((Get-FileHash -LiteralPath (Join-Path $base $entry.file)).Hash -ne $entry.sha256){throw "Previous checkpoint mismatch: $($entry.file)"}
 }
}
if((Get-FileHash (Join-Path $archive 'release-manifest.json')).Hash -ne (Get-FileHash (Join-Path $pack 'release-manifest.json')).Hash){throw 'Archived manifest differs'}
$fit=Get-Content (Join-Path $repo 'mechanical/prototype-bench-fit-check.json') -Raw|ConvertFrom-Json
if(-not $fit.closed -or -not $fit.connected -or -not $fit.fixing_and_pivot_paths_clear -or -not $fit.support_intersection_empty -or $fit.physical_fit_verified){throw 'Missing or invalid adapter validation'}
$source=Join-Path $repo 'mechanical/prototype-bench-base.stl'
$newHash=(Get-FileHash $source).Hash
if($fit.stl_sha256 -ne $newHash -or $fit.cad_sha256 -ne (Get-FileHash (Join-Path $repo 'mechanical/prototype-bench-base.scad')).Hash){throw 'Adapter validation is stale'}
Copy-Item -LiteralPath $source -Destination (Join-Path $pack 'stl/prototype-bench-base.stl')
Copy-Item -LiteralPath (Join-Path $repo 'mechanical/prototype-bench-base.scad') -Destination (Join-Path $pack 'cad/prototype-bench-base.scad')
foreach($name in @('pitch-leg-print-manifest.json','three-dof-print-manifest.json')){
 $path=Join-Path $repo "mechanical/$name"
 $print=Get-Content $path -Raw|ConvertFrom-Json
 $matches=@($print.parts|Where-Object {$_.file -eq 'mechanical/prototype-bench-base.stl'})
 if($matches.Count -ne 1){throw 'Expected exactly one active adapter entry'}
 $matches[0].sha256=$newHash
 if($name -eq 'three-dof-print-manifest.json'){$print.revision='three-dof-bench-2'}
 WriteJson $path $print
}
$adapter=@($manifest.parts|Where-Object {$_.file -eq 'stl/prototype-bench-base.stl'})
if($adapter.Count -ne 1){throw 'Expected exactly one released adapter entry'}
$adapter[0].sha256=$newHash
$manifest.revision='three-dof-bench-2';$manifest.date='2026-10-09'
foreach($name in @('README.md','docs/assembly.md','docs/print-list.md')){
 $path=Join-Path $pack $name
 $text=[IO.File]::ReadAllText($path).Replace('three-dof-bench-1','three-dof-bench-2')
 if($name -eq 'README.md'){$text+="`nMEC-157 corrects adapter/support rib clearance with0.2mm pockets; interfaces,`nquantities and hardware are unchanged. Prior checkpoint: ARCHIVE/MFG-002-three-dof-bench-1.`nThe prior adapter had a CAD clash; use this corrected adapter. Physical fit is untested.`n"}
 if($name -eq 'docs/assembly.md'){$text+="`nBench adapter revision: use the current rib-relieved STL. Pockets face the passive`nsupport; verify free seating before tightening. Overall assembly image is unchanged.`n"}
 [IO.File]::WriteAllText($path,$text,$utf8)
}
$reportPath=Join-Path $pack 'validation.json'
$report=Get-Content $reportPath -Raw|ConvertFrom-Json
$report.revision='three-dof-bench-2'
$report|Add-Member NoteProperty bench_adapter $fit
WriteJson $reportPath $report
$manifest.files=@(Get-ChildItem $pack -Recurse -File|Where-Object {$_.Name -ne 'release-manifest.json'}|ForEach-Object{
 [pscustomobject]@{file=$_.FullName.Substring($pack.Length+1).Replace('\','/');sha256=(Get-FileHash -LiteralPath $_.FullName).Hash}
})
WriteJson (Join-Path $pack 'release-manifest.json') $manifest
& (Join-Path $PSScriptRoot 'check-manufacturing-pack.ps1')
Write-Output 'Corrected MFG-002 / three-dof-bench-2; prior checkpoint preserved.'
