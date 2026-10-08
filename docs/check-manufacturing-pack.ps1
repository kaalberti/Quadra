$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest
$repo=Split-Path $PSScriptRoot -Parent
$pack=Join-Path $repo 'manufacturing'
$manifest=Get-Content (Join-Path $pack 'release-manifest.json') -Raw|ConvertFrom-Json
$threeDof=$manifest.pack_revision -eq 'MFG-002'
$baselineName=if($threeDof){'three-dof-print-manifest.json'}else{'pitch-leg-print-manifest.json'}
$baseline=Get-Content (Join-Path $repo "mechanical/$baselineName") -Raw|ConvertFrom-Json
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
 $releasedText=[IO.File]::ReadAllText($file.FullName).Replace("`r`n","`n")
 $activeText=[IO.File]::ReadAllText($active).Replace("`r`n","`n")
 if($releasedText -ne $activeText) {throw "Source snapshot differs: $($file.Name)"}
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
$hardwareName=if($threeDof){'three-dof-hardware.json'}else{'pitch-leg-hardware.json'}
$releasedHardware=[IO.File]::ReadAllText((Join-Path $pack 'bom-hardware.json')).Replace("`r`n","`n").TrimEnd()
$activeHardware=[IO.File]::ReadAllText((Join-Path $repo "mechanical/$hardwareName")).Replace("`r`n","`n").TrimEnd()
if($releasedHardware -ne $activeHardware) {throw 'Hardware BOM snapshot differs'}
$boltCount=if($threeDof){35}else{23}
if(($hardware.M3_fastener_roles|Measure-Object quantity -Sum).Sum -ne $boltCount) {throw 'Hardware count mismatch'}
$assemblyParts=@($manifest.parts|Where-Object {-not $_.fit_coupon})
$coupons=@($manifest.parts|Where-Object {$_.fit_coupon})
$unique=if($threeDof){18}else{16};$pieces=if($threeDof){29}else{20}
if($assemblyParts.Count -ne $unique -or ($assemblyParts|Measure-Object quantity -Sum).Sum -ne $pieces -or $coupons.Count -ne 4) {throw 'Release counts mismatch'}
if($threeDof -and $manifest.revision -in @('three-dof-bench-2','three-dof-bench-3')) {
 $fit=(Get-Content (Join-Path $pack 'validation.json') -Raw|ConvertFrom-Json).bench_adapter
 if(-not $fit.closed -or -not $fit.connected -or -not $fit.fixing_and_pivot_paths_clear -or -not $fit.support_intersection_empty -or $fit.physical_fit_verified){throw 'Adapter validation incomplete'}
 if($fit.stl_sha256 -ne (Get-FileHash (Join-Path $pack 'stl/prototype-bench-base.stl')).Hash -or $fit.cad_sha256 -ne (Get-FileHash (Join-Path $pack 'cad/prototype-bench-base.scad')).Hash){throw 'Adapter validation differs from released CAD/STL'}
}
if($threeDof -and $manifest.revision -eq 'three-dof-bench-3') {
 $rigid=(Get-Content (Join-Path $pack 'validation.json') -Raw|ConvertFrom-Json).rigid_bench
 if($rigid.proper_printed_poses -ne 29 -or $rigid.proper_servo_poses -ne 3 -or $rigid.physical_fit_verified){throw 'Rigid bench validation incomplete'}
 if(@($rigid.new_mesh_checks).Count -ne 2 -or @($rigid.new_mesh_checks|Where-Object {-not $_.closed -or -not $_.connected -or -not $_.on_bed}).Count){throw 'Mirrored print validation incomplete'}
 if(@($rigid.source_correspondence).Count -ne 2 -or @($rigid.source_correspondence|Where-Object {$_.max_bidirectional_vertex_difference_mm -gt 0.002 -or $_.relative_volume_difference -ge 0.0001}).Count){throw 'Handed source correspondence incomplete'}
 if($rigid.assembly_sha256 -ne (Get-FileHash (Join-Path $pack 'cad/rigid-bench-parts.scad')).Hash){throw 'Rigid assembly differs from validation'}
 foreach($p in $rigid.parts){if((Get-FileHash (Join-Path $pack "stl/$(Split-Path $p.file -Leaf)")).Hash -ne $p.sha256){throw 'Rigid assembly mesh differs'}}
 foreach($m in [regex]::Matches([IO.File]::ReadAllText((Join-Path $pack 'cad/rigid-bench-parts.scad')),'import\(str\(mesh_dir,"/([^"\r\n]+)"\)\)')){
  if(-not(Test-Path (Join-Path $pack "stl/$($m.Groups[1].Value)"))){throw 'Missing imported bench mesh'}
 }
}
Write-Output "PASS: $($actual.Count) release files, hashes/current CAD/dependencies/links/BOM; $unique assembly STLs/$pieces pieces and four coupons."
