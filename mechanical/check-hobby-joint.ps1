$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest
$culture=[Globalization.CultureInfo]::InvariantCulture
$names=@('support','front-arm','rear-arm','bridge','retainer','front-spacer','rear-spacer','bearing-coupon','horn-coupon')
$meshes=@()
foreach($name in $names) {
    $path=Join-Path $PSScriptRoot "hobby-joint-$name.stl"
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
$layout=Get-Content (Join-Path $PSScriptRoot 'hobby-joint-layout.json') -Raw | ConvertFrom-Json
$source=Get-Content (Join-Path $PSScriptRoot 'hobby-joint-common.scad') -Raw
foreach($pair in @(@('shaft_x',$layout.servo.shaft_x_in_cradle),@('horn_z',$layout.front_arm.bottom_z),@('front_t',$layout.front_arm.thickness),@('rear_top',$layout.rear_arm.top_z),@('rear_t',$layout.rear_arm.thickness),@('bridge_r',$layout.bridge.radius),@('bridge_pitch',$layout.bridge.bolt_spacing),@('seat_d',$layout.rear_arm.bearing_seat_diameter),@('seat_depth',$layout.rear_arm.bearing_seat_depth))) {
    $match=[regex]::Match($source,($pair[0]+'\s*=\s*([-\d.]+)'))
    if(-not $match.Success -or [double]::Parse($match.Groups[1].Value,$culture) -ne $pair[1]) { throw "Layout/source drift: $($pair[0])" }
}
$fixedRadius=[math]::Sqrt([math]::Pow(33.75-$layout.servo.shaft_x_in_cradle,2)+20.25*20.25)
$bridgeInner=$layout.bridge.radius-$layout.bridge.column_diameter/2
$allowance=0.8
$radialMargin=$bridgeInner-$fixedRadius-$allowance
$frontGap=$layout.front_arm.bottom_z-(3+$layout.servo.body_height)-$allowance
$rearGap=$layout.fixed_support.pivot_boss_bottom_z-$layout.rear_arm.top_z-$allowance
if($radialMargin -le 0 -or $frontGap -le 0 -or $rearGap -le 0) { throw 'Nominal rotating clearance fails' }
if([math]::Abs(($layout.front_arm.bottom_z-$layout.rear_arm.top_z)-$layout.bridge.length) -gt 0.00001) { throw 'Axial stack mismatch' }
# Volume is one cheap mass screen, not a structural/infill analysis.
$jointVolume=($meshes | Where-Object {$_.part -notmatch 'coupon'} | Measure-Object volume_mm3 -Sum).Sum
$cradleVolume=0.0
foreach($side in @('left','right')) {
    $vs=@([regex]::Matches([IO.File]::ReadAllText((Join-Path $PSScriptRoot "hobby-servo-cradle-$side.stl")),'vertex\s+([-+\d.eE]+)\s+([-+\d.eE]+)\s+([-+\d.eE]+)') | ForEach-Object { ,@([double]::Parse($_.Groups[1].Value,$culture),[double]::Parse($_.Groups[2].Value,$culture),[double]::Parse($_.Groups[3].Value,$culture)) })
    $v=0.0
    for($i=0;$i -lt $vs.Count;$i+=3) {
        $a=$vs[$i];$b=$vs[$i+1];$c=$vs[$i+2]
        $v+=($a[0]*($b[1]*$c[2]-$b[2]*$c[1])+$a[1]*($b[2]*$c[0]-$b[0]*$c[2])+$a[2]*($b[0]*$c[1]-$b[1]*$c[0]))/6
    }
    $cradleVolume+=[math]::Abs($v)
}
$solidMass=($jointVolume+$cradleVolume)/1000*1.27
$report=@{
    meshes=$meshes
    nominal_clearance_mm=@{bridge_radial_margin_after_allowance=$radialMargin;front_case_gap_after_allowance=$frontGap;rear_fixed_gap_after_allowance=$rearGap;allowance=$allowance}
    coverage='All local rotations by radial bound and axial separation; excludes actual ears/horn/cables/fasteners and downstream links'
    printed_solid_volume_mm3=$jointVolume+$cradleVolume
    assumed_PETG_density_g_cm3=1.27
    solid_print_mass_g=$solidMass
    illustrative_print_mass_at_65_percent_material_g=$solidMass*0.65
    illustrative_12_joint_mass_with_servos_g=12*(55+$solidMass*0.65)
    mass_status='Oversized bench-joint proof only; full robot mass target not established. Slicer and measured mass replace material-fraction assumption.'
    torque_screen_reference='hobby-servo-cradle-check.json; no new operating approval'
    actual_fit_or_motion_verified=$false
}
$report | ConvertTo-Json -Depth 8 | Set-Content (Join-Path $PSScriptRoot 'hobby-joint-check.json') -Encoding UTF8
Write-Output ('PASS: nine closed connected printable meshes; nominal bridge margin {0:F2}mm; solid printed mass {1:F1}g.' -f $radialMargin,$solidMass)
Write-Output ('Illustrative12-joint mass with55g servos, before other hardware: {0:F0}g. Not a robot mass approval.' -f $report.illustrative_12_joint_mass_with_servos_g)
