$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest
$repo=Split-Path $PSScriptRoot -Parent
$pack=Join-Path $repo 'manufacturing'
$manifest=Get-Content (Join-Path $pack 'release-manifest.json') -Raw|ConvertFrom-Json
$baseline=Get-Content (Join-Path $repo 'mechanical/pitch-leg-print-manifest.json') -Raw|ConvertFrom-Json
$expected=@('release-manifest.json')+@($manifest.files.file)
$actual=@(Get-ChildItem $pack -Recurse -File|ForEach-Object {$_.FullName.Substring($pack.Length+1).Replace('\','/')})
if(Compare-Object ($expected|Sort-Object) ($actual|Sort-Object)) {throw 'Unexpected or missing release files'}
foreach($entry in $manifest.files) {
 if((Get-FileHash -LiteralPath (Join-Path $pack $entry.file)).Hash -ne $entry.sha256) {throw "Release hash mismatch: $($entry.file)"}
}
foreach($part in $baseline.parts) {
 $name=Split-Path $part.file -Leaf
 $released=@($manifest.parts|Where-Object {$_.file -eq "stl/$name"})
 if($released.Count -ne 1 -or $released[0].quantity -ne $part.quantity -or $released[0].sha256 -ne $part.sha256 -or $released[0].fixture_only -ne $part.fixture_only) {throw "Print manifest mismatch: $name"}
}
foreach($file in Get-ChildItem (Join-Path $pack 'cad') -File) {
 $active=Join-Path $repo "mechanical/$($file.Name)"
 if((Get-FileHash $file.FullName).Hash -ne (Get-FileHash $active).Hash) {throw "Source snapshot differs: $($file.Name)"}
 foreach($m in [regex]::Matches([IO.File]::ReadAllText($file.FullName),'(?:use|include)\s*<([^>]+)>')) {
  if(-not(Test-Path (Join-Path $file.DirectoryName $m.Groups[1].Value))) {throw "Missing released CAD dependency: $($m.Groups[1].Value)"}
 }
}
foreach($file in Get-ChildItem $pack -Recurse -File -Filter '*.md') {
 foreach($m in [regex]::Matches([IO.File]::ReadAllText($file.FullName),'\]\(([^)]+)\)')) {
  $target=$m.Groups[1].Value;if($target -match '^(https?:|#)'){continue}
  if(-not(Test-Path (Join-Path $file.DirectoryName $target))) {throw "Broken pack link: $target"}
 }
}
$hardware=Get-Content (Join-Path $pack 'bom-hardware.json') -Raw|ConvertFrom-Json
$activeHardware=Get-Content (Join-Path $repo 'mechanical/pitch-leg-hardware.json') -Raw|ConvertFrom-Json
if((Get-FileHash (Join-Path $pack 'bom-hardware.json')).Hash -ne (Get-FileHash (Join-Path $repo 'mechanical/pitch-leg-hardware.json')).Hash) {throw 'Hardware BOM snapshot differs'}
if(($hardware.M3_fastener_roles|Measure-Object quantity -Sum).Sum -ne 23) {throw 'Hardware count mismatch'}
$assemblyParts=@($manifest.parts|Where-Object {-not $_.fit_coupon})
$coupons=@($manifest.parts|Where-Object {$_.fit_coupon})
if($assemblyParts.Count -ne 16 -or ($assemblyParts|Measure-Object quantity -Sum).Sum -ne 20 -or $coupons.Count -ne 4) {throw 'Release counts mismatch'}
Write-Output "PASS: $($actual.Count) release files, hashes/current CAD/dependencies/links/BOM; 16 assembly STLs/20 pieces and four coupons."
