$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest
$repo=Split-Path $PSScriptRoot -Parent
$pack=Join-Path $repo 'manufacturing'
$pending=Join-Path $repo 'manufacturing-pending-MFG-003'
$archive=Join-Path $repo 'ARCHIVE/MFG-002-three-dof-bench-3'
$root=[IO.Path]::GetFullPath($repo)+[IO.Path]::DirectorySeparatorChar
foreach($target in @($pack,$pending,$archive)){if(-not([IO.Path]::GetFullPath($target).StartsWith($root,[StringComparison]::OrdinalIgnoreCase))){throw 'Target outside repository'}}
if(Test-Path -LiteralPath $archive){throw 'Archive exists; refusing overwrite'}
& (Join-Path $PSScriptRoot 'check-manufacturing-pack.ps1')
& node (Join-Path $PSScriptRoot 'check-integrated-manufacturing-pack.mjs') $pending
if($LASTEXITCODE -ne 0){throw 'Pending pack verification failed'}
$old=Get-Content (Join-Path $pack 'release-manifest.json') -Raw|ConvertFrom-Json
if($old.revision -ne 'three-dof-bench-3'){throw 'Expected bench-3 fallback'}
$hash=(Get-FileHash (Join-Path $pack 'release-manifest.json')).Hash
Move-Item -LiteralPath $pack -Destination $archive
if((Get-FileHash (Join-Path $archive 'release-manifest.json')).Hash -ne $hash){throw 'Archived manifest bytes changed'}
foreach($file in $old.files){if((Get-FileHash (Join-Path $archive $file.file)).Hash -ne $file.sha256){throw 'Archived release bytes changed'}}
Move-Item -LiteralPath $pending -Destination $pack
& node (Join-Path $PSScriptRoot 'check-integrated-manufacturing-pack.mjs') $pack
if($LASTEXITCODE -ne 0){throw 'Promoted pack verification failed'}
Write-Output "Bench-3 archived intact ($hash); MFG-003 promoted and verified."