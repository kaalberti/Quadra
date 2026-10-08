$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest
$culture=[Globalization.CultureInfo]::InvariantCulture
$names=@('knee-support','lower-leg','knee-spacer','foot','cable-guide','bench-base')
$meshes=@()
foreach($name in $names) {
    $path=Join-Path $PSScriptRoot "prototype-$name.stl"
    $vertices=@([regex]::Matches([IO.File]::ReadAllText($path),'vertex\s+([-+\d.eE]+)\s+([-+\d.eE]+)\s+([-+\d.eE]+)') | ForEach-Object {
        ,@([double]::Parse($_.Groups[1].Value,$culture),[double]::Parse($_.Groups[2].Value,$culture),[double]::Parse($_.Groups[3].Value,$culture))
    })
    if($vertices.Count -eq 0 -or $vertices.Count%3) { throw "Invalid STL: $name" }
    $edges=@{}; $adj=@{}; $volume=0.0
    for($i=0;$i -lt $vertices.Count;$i+=3) {
        $triangle=[int]($i/3)
        $adj[$triangle]=[Collections.Generic.List[int]]::new()
        $keys=@(0..2 | ForEach-Object { ($vertices[$i+$_] | ForEach-Object {$_.ToString('G17',$culture)}) -join ',' })
        if(($keys | Select-Object -Unique).Count -ne 3) { throw "Degenerate facet: $name" }
        foreach($pair in @(@(0,1),@(1,2),@(2,0))) {
            $edge=(@($keys[$pair[0]],$keys[$pair[1]]) | Sort-Object) -join '|'
            if(-not $edges.ContainsKey($edge)) { $edges[$edge]=[Collections.Generic.List[int]]::new() }
            $edges[$edge].Add($triangle)
        }
        $a=$vertices[$i];$b=$vertices[$i+1];$c=$vertices[$i+2]
        $volume+=($a[0]*($b[1]*$c[2]-$b[2]*$c[1])+$a[1]*($b[2]*$c[0]-$b[0]*$c[2])+$a[2]*($b[0]*$c[1]-$b[1]*$c[0]))/6
    }
    foreach($owners in $edges.Values) {
        if($owners.Count -ne 2) { throw "Open/nonmanifold edge: $name" }
        $adj[$owners[0]].Add($owners[1]);$adj[$owners[1]].Add($owners[0])
    }
    $seen=[Collections.Generic.HashSet[int]]::new();$components=0
    foreach($id in $adj.Keys) {
        if($seen.Contains($id)) { continue }
        $components++;$queue=[Collections.Generic.Queue[int]]::new();$queue.Enqueue($id);[void]$seen.Add($id)
        while($queue.Count) {
            $current=$queue.Dequeue()
            foreach($neighbor in $adj[$current]) { if($seen.Add($neighbor)) {$queue.Enqueue($neighbor)} }
        }
    }
    if($components -ne 1) { throw "Disconnected part: $name ($components)" }
    $zmin=($vertices | ForEach-Object {$_[2]} | Measure-Object -Minimum).Minimum
    if([math]::Abs($zmin) -gt 0.00001) { throw "Part not on print bed: $name" }
    $meshes+=@{part=$name;triangles=$vertices.Count/3;closed=$true;components=$components;volume_mm3=[math]::Abs($volume)}
}

$req=Get-Content (Join-Path $PSScriptRoot 'prototype-requirements.json') -Raw | ConvertFrom-Json
$angles=Get-Content (Join-Path $PSScriptRoot 'standing-pose.json') -Raw | ConvertFrom-Json
$q2=$angles.joint_angles_degrees_all_legs[1]*[math]::PI/180
$q3=$angles.joint_angles_degrees_all_legs[2]*[math]::PI/180
$footX=70*[math]::Sin($q2)+85*[math]::Sin($q2-$q3)
$footZ=-70*[math]::Cos($q2)-85*[math]::Cos($q2-$q3)
if([math]::Abs($footX) -gt 0.001 -or [math]::Abs($footZ+120) -gt 0.001) {throw '70/85 closure failed'}
$sweep=@()
foreach($q in 20..90) {
    $r=$q*[math]::PI/180
    $x=-58*[math]::Cos($r);$y=58*[math]::Sin($r)
    $dx=[math]::Max([math]::Max(-14-$x,$x-26),0)
    $dy=[math]::Max([math]::Max(-20-$y,$y-40.7),0)
    $gap=[math]::Sqrt($dx*$dx+$dy*$dy)-13-0.8
    if($gap -le 0) {throw "Bridge/saddle bound fails at$q"}
    $sweep+=@{q3_deg=$q;margin_mm=$gap}
}
foreach($q in @(20,79,90)) {
    $log=Get-Content (Join-Path $PSScriptRoot "prototype-knee-front-probe-$q.log") -Raw
    if($log -notmatch 'top level object is empty' -or $log -match 'ERROR:|WARNING:') {throw "Collision probe$q failed"}
}
$force=$req.maximum_operating_mass_kg*9.81/3
$knee=$force*0.049+0.10
$stall=9.4*0.0980665
$old=Get-Content (Join-Path $PSScriptRoot 'hobby-joint-check.json') -Raw | ConvertFrom-Json
$upper=Get-Content (Join-Path $PSScriptRoot 'prototype-upper-leg-check.json') -Raw | ConvertFrom-Json
$oldFront=($old.meshes | Where-Object {$_.part -eq 'front-arm'}).volume_mm3
$upperV=($upper.meshes | Where-Object {$_.part -in @('plate','saddle')} | Measure-Object volume_mm3 -Sum).Sum
$reusedKnee=($old.meshes | Where-Object {$_.part -in @('rear-arm','bridge','retainer','rear-spacer')} | Measure-Object volume_mm3 -Sum).Sum
$newV=($meshes | Where-Object {$_.part -ne 'bench-base'} | Measure-Object volume_mm3 -Sum).Sum
$printedV=$old.printed_solid_volume_mm3-$oldFront+$upperV+$reusedKnee+$newV
$adapterRadius=[math]::Sqrt(35.1*35.1+20.25*20.25)
$adapterMargin=52-$adapterRadius-0.8
$anchorMinimum=[double]::MaxValue
foreach($q in -40..85) {
    $r=$q*[math]::PI/180
    foreach($y in @(-12,12)) {
        $x=-24.65
        $projection=$x*[math]::Cos($r)+$y*[math]::Sin($r)
        $t=[math]::Max(0,[math]::Min(58,$projection))
        $dx=$x-$t*[math]::Cos($r);$dy=$y-$t*[math]::Sin($r)
        $gap=[math]::Sqrt($dx*$dx+$dy*$dy)-16-5-0.8
        $anchorMinimum=[math]::Min($anchorMinimum,$gap)
    }
}
if($adapterMargin -le 0 -or $anchorMinimum -le 0) {throw 'Bench adapter/standoff reservation fails'}
$report=@{
    meshes=$meshes
    operating_mass_limit_kg=$req.maximum_operating_mass_kg
    closure_mm=@{forward=$footX;height=-$footZ;upper=70;lower_contact=85;pad_thickness_assumed=1}
    knee_bridge_samples=$sweep
    minimum_sampled_knee_bridge_margin_mm=($sweep | Measure-Object margin_mm -Minimum).Minimum
    exact_front_plate_probe_angles_deg=@(20,79,90)
    exact_front_plate_intersections_empty=$true
    knee_static_screen=@{support_legs=3;force_N=$force;lever_mm=49;moving_parts_allowance_Nm=0.10;nominal_Nm=$knee;published_stall_at_4_8V_Nm=$stall;stall_ratio=$stall/$knee;horizontal_full_leg_bound_Nm=$force*0.155+0.10}
    printed_solid_volume_mm3=$printedV
    printed_solid_mass_g=$printedV/1000*1.27
    illustrative_65_percent_material_mass_g=$printedV/1000*1.27*0.65
    servo_mass_g=110
    bench_adapter_solid_mass_g=($meshes | Where-Object {$_.part -eq 'bench-base'}).volume_mm3/1000*1.27
    fixture_clearance_mm=@{adapter_to_bridge_radial_bound=$adapterMargin;sampled_10mm_OD_anchor_standoff_to_rear_arm_capsule=$anchorMinimum;board_gap_behind_adapter=40;rear_arm_to_adapter_axial_gap=6.2}
    actual_fit_verified=$false
    limits='Two-DOF pitch leg only; noJ1. Three sampled plate intersections and1deg bridge samples are not full motion qualification. Initial2kg loaded use restricted to bent standing; stall is not continuous rating. Actual cable/horn/fastener/pad fit and electrical capacity unverified.'
}
$report | ConvertTo-Json -Depth 8 | Set-Content (Join-Path $PSScriptRoot 'prototype-pitch-leg-check.json') -Encoding UTF8
Write-Output ('PASS: six new meshes and70/85 closure; sampled bridge margin {0:F2}mm;2kg nominal knee {1:F2}Nm vs {2:F2}Nm stall.' -f $report.minimum_sampled_knee_bridge_margin_mm,$knee,$stall)
Write-Output ('Pitch-leg solid printed mass {0:F1}g; final robot mass unresolved.' -f $report.printed_solid_mass_g)
