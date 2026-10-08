$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest
$repo=Split-Path $PSScriptRoot -Parent
$utf8=[Text.UTF8Encoding]::new($false)
function WriteText($path,$text) {[IO.File]::WriteAllText((Join-Path $repo $path),$text,$utf8)}
if(Test-Path (Join-Path $repo 'manufacturing')) {throw 'Existing manufacturing pack requires explicit revision review; refusing to overwrite.'}
$task=[IO.File]::ReadAllText((Join-Path $repo 'TASK_TEMPLATE.md'))+@'

# MFG-001: Package the current two-DOF mechanical prototype

Scope: package existing pitch-leg-1 geometry for printing and unpowered fit only.
Outputs: manufacturing STL kit, coupons, self-contained assembly/BOM, dimensions,
CAD snapshot, release manifest and validation report. Working exports stay in docs.
Validation: fresh CAD exports geometrically match each original STL; quantities
match current print manifest and hardware roles; active checks pass; release hashes,
CAD dependencies, drawing dimensions and package file inventory verified.
No new dependencies, geometry changes, J1 design, electronics or powered release.
TASK_TEMPLATE.md is empty and is used as the prefix. Stop after updating STATUS.
'@
WriteText 'NEXT_TASK.md' $task
$pack=Join-Path $repo 'manufacturing'
if(Test-Path $pack) {throw 'Existing manufacturing pack requires explicit revision review; refusing to overwrite.'}
$scratch=Join-Path $repo 'docs/manufacturing-verification'
New-Item -ItemType Directory -Path $scratch -Force | Out-Null
$print=Get-Content (Join-Path $repo 'mechanical/pitch-leg-print-manifest.json') -Raw | ConvertFrom-Json
$exports=@()
foreach($p in $print.parts) {
 $name=[IO.Path]::GetFileNameWithoutExtension($p.file);$source="$name.scad";$selector=$null
 if($name -match '^hobby-servo-cradle-(left|right)$') {$source='hobby-servo-cradle.scad';$selector=$Matches[1]}
 if($name -match '^prototype-upper-leg-(plate|saddle)$') {$source='prototype-upper-leg.scad';$selector=$Matches[1]}
 if($name -match '^hobby-joint-(retainer|front-spacer|rear-spacer)$') {$source='hobby-joint-bearing-parts.scad';$selector=$Matches[1]}
 $exports+=[pscustomobject]@{name=$name;source=$source;selector=$selector;quantity=$p.quantity;fixture_only=$p.fixture_only;coupon=$false;original=$p.file}
}
foreach($spec in @(@('hobby-servo-cradle-coupon','hobby-servo-cradle.scad','coupon'),@('hobby-joint-bearing-coupon','hobby-joint-fit-samples.scad','bearing'),@('hobby-joint-horn-coupon','hobby-joint-fit-samples.scad','horn'),@('prototype-upper-leg-ear-coupon','prototype-upper-leg.scad','ear-coupon'))) {
 $exports+=[pscustomobject]@{name=$spec[0];source=$spec[1];selector=$spec[2];quantity=1;fixture_only=$false;coupon=$true;original="mechanical/$($spec[0]).stl"}
}
function GeometrySignature($path) {
 $content=[IO.File]::ReadAllText($path)
 # Canonical sorted vertex text avoids STL facet ordering differences.
 $values=@([regex]::Matches($content,'vertex\s+([-+\d.eE]+)\s+([-+\d.eE]+)\s+([-+\d.eE]+)')|ForEach-Object {
  $match=$_; (@(1..3|ForEach-Object {([math]::Round([double]::Parse($match.Groups[$_].Value,[Globalization.CultureInfo]::InvariantCulture),5)).ToString('F5',[Globalization.CultureInfo]::InvariantCulture)}) -join ',')
 } | Sort-Object)
 if($values.Count -eq 0) {throw "No ASCII STL vertices: $path"}
 $sha=[Security.Cryptography.SHA256]::Create()
 try {([BitConverter]::ToString($sha.ComputeHash([Text.Encoding]::UTF8.GetBytes(($values -join "`n"))))).Replace('-','')} finally {$sha.Dispose()}
}
$cad=Join-Path $repo 'mechanical/tools/openscad-2021.01/openscad.com'
$verified=@()
foreach($e in $exports) {
 $out=Join-Path $scratch "$($e.name).stl"
 $arguments=@('-o',$out)
 if($null -ne $e.selector) {$arguments+=@('-D',('part="'+$e.selector+'"'))}
 $arguments+=(Join-Path $repo "mechanical/$($e.source)")
 $log=(& $cad @arguments 2>&1|Out-String)
 if($LASTEXITCODE -ne 0 -or $log -match 'ERROR:|WARNING:' -or $log -notmatch 'Simple:\s+yes') {throw "Export failed: $($e.name) $log"}
 WriteText "docs/manufacturing-verification/$($e.name).log" $log
 if((GeometrySignature $out) -ne (GeometrySignature (Join-Path $repo $e.original))) {throw "Current CAD differs from manifest STL: $($e.name)"}
 $verified+=$e
 Write-Output "CAD verified: $($e.name)"
}
foreach($check in @('check-hobby-servo-cradle.ps1','check-hobby-joint.ps1','check-prototype-upper-leg.ps1','check-prototype-pitch-leg.ps1')) {& (Join-Path $repo "mechanical/$check")}
foreach($dir in @('stl','coupons','cad','docs')) {New-Item -ItemType Directory -Path (Join-Path $pack $dir) -Force|Out-Null}
$parts=@()
foreach($e in $verified) {
 $folder=if($e.coupon){'coupons'}else{'stl'}
 $relative="$folder/$($e.name).stl"
 Copy-Item -LiteralPath (Join-Path $repo $e.original) -Destination (Join-Path $pack $relative)
 $parts+=[pscustomobject]@{file=$relative;quantity=$e.quantity;fixture_only=$e.fixture_only;fit_coupon=$e.coupon;cad="cad/$($e.source)";selector=$e.selector;sha256=(Get-FileHash (Join-Path $pack $relative)).Hash}
}
# Snapshot the transitive SCAD dependency closure of the assembly and all exports.
$queue=[Collections.Generic.Queue[string]]::new();$seen=@{}
$queue.Enqueue('prototype-pitch-leg.scad')
foreach($e in $exports) {$queue.Enqueue($e.source)}
while($queue.Count) {
 $name=$queue.Dequeue();if($seen.ContainsKey($name)){continue};$seen[$name]=$true
 $source=Join-Path $repo "mechanical/$name"
 Copy-Item -LiteralPath $source -Destination (Join-Path $pack "cad/$name")
 foreach($m in [regex]::Matches([IO.File]::ReadAllText($source),'(?:use|include)\s*<([^>]+)>')) {$queue.Enqueue($m.Groups[1].Value)}
}
Copy-Item (Join-Path $repo 'mechanical/prototype-pitch-leg-preview.png') (Join-Path $pack 'docs/assembly.png')
$bom=[IO.File]::ReadAllText((Join-Path $repo 'docs/purchasing-bom.md')).Replace('mechanical/pitch-leg-hardware.json','bom-hardware.json')
WriteText 'manufacturing/BOM.md' $bom
Copy-Item (Join-Path $repo 'mechanical/pitch-leg-hardware.json') (Join-Path $pack 'bom-hardware.json')
$assembly=[IO.File]::ReadAllText((Join-Path $repo 'docs/prototype-pitch-leg-build.md'))
$assembly=$assembly.Replace('mechanical/pitch-leg-print-manifest.json','../release-manifest.json').Replace('docs/purchasing-bom.md','../BOM.md')
$assembly=$assembly.Replace('1. Assemble the supported hip using the earlier guide, with the upper plate',@'
1. Fit a 624 bearing into the hip rear arm and secure its retainer with two
   M3x16 bolts/nuts. Insert the M4x35 pivot into the fixed support recess,
   then fit the 8mm spacer, bearing/rear arm, 3mm spacer, washer and locking
   nut. Spacers contact only the inner ring; check smooth rotation.
   Join the rear arm and upper plate with the bridge and two M3x90 bolts.
   Clamp the servo gently between cradle halves using two M3x40 bolts.
   Mount cradle/support/bench adapter with four M3x20 bolts; assemble the
   recessed pivot first. Attach the supplied horn to the upper plate through
   its slots, then use the original servo centre screw. Check screw tips,
   actual horn geometry and case alignment. The upper plate is
'@)
$assembly=$assembly.Replace('Next suggested stage4 task: design the J1 abduction carrier connecting this','Not included in this package: the J1 abduction carrier connecting this')
$assembly=$assembly.Replace('## Assembly changes','## Assembly sequence').Replace('4. Attach the knee servo by its ears, then mount','4. Attach the knee servo by its ears using four M3x12 bolts/nuts, then mount')
$assembly=$assembly.Replace('`powershell -File mechanical/check-prototype-pitch-leg.ps1` checks six new','The recorded source verification in ../validation.json checks six new')
$assembly="![Current assembly](assembly.png)`n`n"+$assembly+"`nFit coupon IDs: cradle coupon, bearing coupon (1/2/3 dots = 13.0/13.2/13.4mm seats), horn coupon and upper-leg ear coupon. Files are in ../coupons; print one each before the full kit. The current rear-arm bearing seat is 13.2mm. Failed fit requires a design revision and regenerated pack.`n"
WriteText 'manufacturing/docs/assembly.md' $assembly
$table="# Print list and exported dimensions`n`nUnits: mm. Bounding boxes are derived from released STL vertices, not tolerance drawings. Print in exported orientation at z=0. PLA+/PETG, 0.4mm nozzle, 0.2mm layers, four walls, about 30% infill; bridge upright with brim. Inspect horizontal hole roofs and small spacers in the slicer. No printer-specific G-code supplied.`n`n| STL | Qty | X | Y | Z | Type |`n|---|---:|---:|---:|---:|---|`n"
foreach($p in $parts) {
 $matches=[regex]::Matches([IO.File]::ReadAllText((Join-Path $pack $p.file)),'vertex\s+([-+\d.eE]+)\s+([-+\d.eE]+)\s+([-+\d.eE]+)')
 $dimensions=@();foreach($axis in 1..3) {$numbers=@($matches|ForEach-Object {[double]::Parse($_.Groups[$axis].Value,[Globalization.CultureInfo]::InvariantCulture)});$stats=$numbers|Measure-Object -Minimum -Maximum;$dimensions+= [math]::Round($stats.Maximum-$stats.Minimum,3)}
 $type=if($p.fit_coupon){'Fit coupon'}elseif($p.fixture_only){'Bench fixture'}else{'Leg part'}
 $table+="| [$($p.file)](../$($p.file)) | $($p.quantity) | $($dimensions[0]) | $($dimensions[1]) | $($dimensions[2]) | $type |`n"
}
WriteText 'manufacturing/docs/print-list.md' $table
WriteText 'manufacturing/README.md' @'
# Manufacturing pack — pitch-leg-1 / MFG-001

Scope: one supported two-DOF pitch-leg mechanical prototype and bench adapter.
Ready for printing and unpowered fit assessment. Physical fit is unverified.
This is not a complete robot or a powered-operation release; J1 is absent.

- [BOM](BOM.md): current assembly quantities, fit-first purchases and separate future estimates.
- [Print quantities and dimensions](docs/print-list.md): 16 assembly STL files / 20 pieces, plus four fit coupons.
- [Assembly instructions and view](docs/assembly.md).
- Editable CAD snapshot: cad/prototype-pitch-leg.scad, with its dependencies.
- release-manifest.json: selectors, quantities and file/source hashes.
- validation.json: release verification and applicability of manufacturing checks.

STLs use millimetres. STEP is not supplied: the approved OpenSCAD workflow
produces STL and editable SCAD. No electronics, PCB, wiring, connector pinout
or firmware has been released; those checks are not applicable to this
unpowered mechanical scope. The 2kg robot limit is a design requirement,
not a tested capacity of this kit. Read the fit and loading limits before use.

Working verification exports and release tooling stay outside this folder.
Any manufacturing-affecting design change requires regenerating and checking
the affected outputs and manifest before updating this package. Superseded
release files must be moved to ARCHIVE rather than retained in this folder.
'@
$roles=Get-Content (Join-Path $pack 'bom-hardware.json') -Raw|ConvertFrom-Json
if(($roles.M3_fastener_roles|Measure-Object quantity -Sum).Sum -ne $roles.M3_nuts -or $roles.servos -ne 2 -or $roles.bearings_624 -ne 2) {throw 'BOM role mismatch'}
$validation=[ordered]@{revision='pitch-leg-1';scope='unpowered two-DOF mechanical prototype';cad_exports_checked=$verified.Count;geometry_comparison='sorted STL vertices rounded to 0.00001 mm; fresh CGAL simple solid; existing independent mesh checks';assembly_unique_stls=16;assembly_pieces=20;fit_coupons=4;bom='23 M3 bolt/nut roles, 45 normal and one backing washer, two servos/two bearings; horn hardware conditional on actual fit';drawing='STL-derived bounding dimensions; nominal 70/85mm chain verified by pitch-leg checker';pcb='not applicable: no PCB released';connector_pinouts='not applicable: no electrical release';wiring='not applicable: unpowered fit scope';firmware='not applicable: no powered operation';physical_fit_verified=$false;powered_operation_approved=$false}
WriteText 'manufacturing/validation.json' (($validation|ConvertTo-Json -Depth 6)+"`n")
$files=@(Get-ChildItem $pack -Recurse -File|ForEach-Object {[pscustomobject]@{file=$_.FullName.Substring($pack.Length+1).Replace('\','/');sha256=(Get-FileHash $_.FullName).Hash}})
$release=[ordered]@{revision='pitch-leg-1';pack_revision='MFG-001';date='2026-10-08';scope=$validation.scope;parts=$parts;files=$files}
WriteText 'manufacturing/release-manifest.json' (($release|ConvertTo-Json -Depth 8)+"`n")
Write-Output "Pack created: $($files.Count+1) files."
