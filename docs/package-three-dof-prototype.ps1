$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest
$repo=Split-Path $PSScriptRoot -Parent
$pack=Join-Path $repo 'manufacturing'
$old=Join-Path $repo 'ARCHIVE/MFG-001-two-dof-pack'
if(Test-Path $old){throw 'Previous release already archived; review before rerunning'}
$hardware=Get-Content (Join-Path $repo 'mechanical/pitch-leg-hardware.json') -Raw|ConvertFrom-Json
$hardware.scope='One supported3DOF bench leg; prototype offsets85/32mm'
$hardware.servos=3;$hardware.bearings_624=3
$hardware.M3_fastener_roles+=@(@{role='J1 case clamp';length_mm=40;quantity=2},@{role='J1 cradle/support/bench adapter';length_mm=20;quantity=4},@{role='J1 bearing retainer';length_mm=16;quantity=2},@{role='J1 carrier end tabs';length_mm=20;quantity=4})
$hardware.M3_nuts=35;$hardware.M3_normal_washers=69
$hardware.M4x35_socket_head_pivots=3;$hardware.M4_pivot_locknuts=3;$hardware.M4_pivot_washers=3
$hardware.M2x10_horn_bolts_max=12;$hardware.M2_horn_nuts_max=12;$hardware.M2_horn_washers_max=24
$hardware.printed_or_metal_inner_spacers_mm=@(8,10,3,3,8,3);$hardware.small_cable_ties=4
$hardware.M3_fastener_roles[1].role='J2 cradle/support/J1 carrier'
$hardware|ConvertTo-Json -Depth 8|Set-Content (Join-Path $repo 'mechanical/three-dof-hardware.json') -Encoding UTF8
$previous=Get-Content (Join-Path $pack 'release-manifest.json') -Raw|ConvertFrom-Json
$parts=@($previous.parts)
foreach($name in @('hobby-servo-cradle-left','hobby-servo-cradle-right','hobby-joint-support','hobby-joint-rear-arm','hobby-joint-retainer','hobby-joint-front-spacer','hobby-joint-rear-spacer')) {
 ($parts|Where-Object {$_.file -eq "stl/$name.stl"}).quantity++
}
foreach($entry in @(@('hobby-joint-front-arm','hobby-joint-front-arm.scad'),@('prototype-j1-carrier','prototype-j1-carrier.scad'))) {
 $parts+=[pscustomobject]@{file="stl/$($entry[0]).stl";quantity=1;fixture_only=$false;fit_coupon=$false;cad="cad/$($entry[1])";selector=$null;sha256=(Get-FileHash (Join-Path $repo "mechanical/$($entry[0]).stl")).Hash}
}
$manifest=@{revision='three-dof-bench-1';guide='docs/three-dof-prototype-build.md';bom='docs/purchasing-bom.md';physical_fit_verified=$false;parts=@($parts|Where-Object {-not $_.fit_coupon}|ForEach-Object { [pscustomobject]@{file="mechanical/$(Split-Path $_.file -Leaf)";quantity=$_.quantity;fixture_only=$_.fixture_only;sha256=$_.sha256}})}
$manifest|ConvertTo-Json -Depth 8|Set-Content (Join-Path $repo 'mechanical/three-dof-print-manifest.json') -Encoding UTF8
foreach($mode in @('carrier-collision','fixed-collision')) {
 $probes=@(Get-Content (Join-Path $repo "mechanical/three-dof-$mode-results.json") -Raw|ConvertFrom-Json)
 if($probes.Count -ne 3 -or @($probes|Where-Object {-not $_.acceptable}).Count){throw "Incomplete probe results: $mode"}
}
& (Join-Path $repo 'mechanical/check-prototype-three-dof.ps1')
& (Join-Path $repo 'mechanical/check-prototype-pitch-leg.ps1')
# Verify the old release before relocating it; preserve it rather than delete.
foreach($file in $previous.files) {if((Get-FileHash (Join-Path $pack $file.file)).Hash -ne $file.sha256){throw 'Old release differs from manifest'}}
$root=[IO.Path]::GetFullPath($repo)+[IO.Path]::DirectorySeparatorChar
foreach($path in @($pack,$old)) {if(-not([IO.Path]::GetFullPath($path).StartsWith($root,[StringComparison]::OrdinalIgnoreCase))){throw 'Move outside repository'}}
Move-Item -LiteralPath $pack -Destination $old
foreach($dir in @('stl','coupons','cad','docs')) {New-Item -ItemType Directory -Path (Join-Path $pack $dir) -Force|Out-Null}
foreach($part in $parts){Copy-Item -LiteralPath (Join-Path $repo "mechanical/$(Split-Path $part.file -Leaf)") -Destination (Join-Path $pack $part.file)}
$queue=[Collections.Generic.Queue[string]]::new();$seen=@{}
$queue.Enqueue('prototype-three-dof-leg.scad');foreach($p in $parts){$queue.Enqueue((Split-Path $p.cad -Leaf))}
while($queue.Count){
 $name=$queue.Dequeue();if($seen.ContainsKey($name)){continue};$seen[$name]=$true
 $source=Join-Path $repo "mechanical/$name";Copy-Item $source (Join-Path $pack "cad/$name")
 foreach($m in [regex]::Matches([IO.File]::ReadAllText($source),'(?:use|include)\s*<([^>]+)>')){$queue.Enqueue($m.Groups[1].Value)}
}
Copy-Item (Join-Path $repo 'mechanical/prototype-three-dof-leg-preview.png') (Join-Path $pack 'docs/assembly.png')
Copy-Item (Join-Path $repo 'mechanical/three-dof-hardware.json') (Join-Path $pack 'bom-hardware.json')
Copy-Item (Join-Path $repo 'mechanical/prototype-three-dof-layout.json') (Join-Path $pack 'layout.json')
$guide=[IO.File]::ReadAllText((Join-Path $repo 'docs/three-dof-prototype-build.md')).Replace('../mechanical/prototype-three-dof-leg-preview.png','assembly.png')
$guide=$guide.Replace('using its guide','using [the pitch-leg guide](pitch-leg-assembly.md)')
$guide|Set-Content (Join-Path $pack 'docs/assembly.md') -Encoding UTF8
$pitch=[IO.File]::ReadAllText((Join-Path $old 'docs/assembly.md')).Replace('assembly.png','pitch-leg.png')
$pitch|Set-Content (Join-Path $pack 'docs/pitch-leg-assembly.md') -Encoding UTF8
Copy-Item (Join-Path $old 'docs/assembly.png') (Join-Path $pack 'docs/pitch-leg.png')
$bom=[IO.File]::ReadAllText((Join-Path $repo 'docs/purchasing-bom.md')).Replace('mechanical/three-dof-hardware.json','bom-hardware.json')
$bom|Set-Content (Join-Path $pack 'BOM.md') -Encoding UTF8
$list="# Print quantities — three-dof-bench-1`n`nMillimetres; print in exported orientation. Four fit coupons first, then29 assembly pieces from18 unique STL files.`n`n| File | Quantity | Type |`n|---|---:|---|`n"
foreach($p in $parts){$type=if($p.fit_coupon){'Fit coupon'}elseif($p.fixture_only){'Bench adapter'}else{'Leg part'};$list+="| [$($p.file)](../$($p.file)) | $($p.quantity) | $type |`n"}
$list|Set-Content (Join-Path $pack 'docs/print-list.md') -Encoding UTF8
@'
# Manufacturing pack — three-dof-bench-1 / MFG-002

One supported three-DOF bench leg, for printing and unpowered fit assessment.
No chassis, electronics, powered capacity or gait release is included.
Physical fit remains unverified. Start with four coupons before the full kit.

- [Assembly and view](docs/assembly.md)
- [Print quantities](docs/print-list.md): 18 unique assembly STLs / 29 pieces
- [Buying BOM](BOM.md): three servos/three bearings; benchmark costs only
- Editable assembly: cad/prototype-three-dof-leg.scad
- layout.json: prototype frame offsets and conservative trial envelope
- release-manifest.json: quantities and hashes
- validation.json: mesh, torque and sampled intersection evidence

STL units are mm. No STEP or printer-specific G-code is supplied. PLA+/PETG,
0.4mm nozzle, 0.2mm layers, four walls and 30% infill are starting settings.
Horizontal holes, bearing/horn fit and actual cables need physical inspection.
The prototype has an85mm forward pitch offset and32mm foot-plane offset;
it is not the old25mm-offset skeleton or a finalized four-leg chassis layout.
J1 torque is screened against stall, not certified continuous operation.
PCB/pinout/wiring/firmware checks are not applicable to this unpowered scope.
The previous two-DOF manufacturing pack is retained in ARCHIVE/MFG-001-two-dof-pack.
'@|Set-Content (Join-Path $pack 'README.md') -Encoding UTF8
$report=Get-Content (Join-Path $repo 'mechanical/prototype-three-dof-check.json') -Raw|ConvertFrom-Json
$report|Add-Member NoteProperty carrier_probes (Get-Content (Join-Path $repo 'mechanical/three-dof-carrier-collision-results.json') -Raw|ConvertFrom-Json)
$report|Add-Member NoteProperty fixed_case_probes (Get-Content (Join-Path $repo 'mechanical/three-dof-fixed-collision-results.json') -Raw|ConvertFrom-Json)
$report|ConvertTo-Json -Depth 12|Set-Content (Join-Path $pack 'validation.json') -Encoding UTF8
$files=@(Get-ChildItem $pack -Recurse -File|ForEach-Object {[pscustomobject]@{file=$_.FullName.Substring($pack.Length+1).Replace('\','/');sha256=(Get-FileHash $_.FullName).Hash}})
@{revision='three-dof-bench-1';pack_revision='MFG-002';date='2026-10-08';scope='Unpowered3DOF bench prototype';parts=$parts;files=$files}|ConvertTo-Json -Depth 9|Set-Content (Join-Path $pack 'release-manifest.json') -Encoding UTF8
Write-Output 'MFG-002 created; prior release archived intact.'
