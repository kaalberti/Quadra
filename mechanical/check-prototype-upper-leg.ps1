$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest
$culture=[Globalization.CultureInfo]::InvariantCulture
$names=@('plate','saddle','ear-coupon')
$meshes=@()
foreach($name in $names) {
    $path=Join-Path $PSScriptRoot "prototype-upper-leg-$name.stl"
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

function Test-RectSeparation([double[]]$Rect,[double]$Angle,[double[]]$Fixed) {
    $r=$Angle*[math]::PI/180;$c=[math]::Cos($r);$s=[math]::Sin($r)
    $moving=@(foreach($x in @($Rect[0],$Rect[1])) {foreach($y in @($Rect[2],$Rect[3])) {,@(($c*$x-$s*$y),($s*$x+$c*$y))}})
    $fixedPoints=@(foreach($x in @($Fixed[0],$Fixed[1])) {foreach($y in @($Fixed[2],$Fixed[3])) {,@($x,$y)}})
    $best=-[double]::MaxValue
    foreach($axis in @(@(1.0,0.0),@(0.0,1.0),@($c,$s),@((-$s),$c))) {
        $m=$moving | ForEach-Object {$_[0]*$axis[0]+$_[1]*$axis[1]} | Measure-Object -Minimum -Maximum
        $f=$fixedPoints | ForEach-Object {$_[0]*$axis[0]+$_[1]*$axis[1]} | Measure-Object -Minimum -Maximum
        $best=[math]::Max($best,[math]::Max($m.Minimum-$f.Maximum,$f.Minimum-$m.Maximum))
    }
    return $best
}
$source=Get-Content (Join-Path $PSScriptRoot 'prototype-upper-leg.scad') -Raw
if($source -notmatch 'upper_length=70;' -or $source -notmatch 'ear_face_z=31;') {throw 'Update numeric checker for changed length or ear face'}
$fixed=@(-23.4,44.1,-24.0,24.0) # Existing cradle plus allowance for clamp hardware.
$samples=@()
foreach($q in -40..85) {
    $saddleGap=Test-RectSeparation @(-84.0,-44.0,-20.0,40.7) $q $fixed
    if($saddleGap -le 0.8) {throw "Sampled saddle/hip clearance fails at$q"}
    $samples+=@{q2_deg=$q;separating_axis_gap_mm=$saddleGap}
}
$old=Get-Content (Join-Path $PSScriptRoot 'hobby-joint-check.json') -Raw | ConvertFrom-Json
$oldJointOnly=($old.meshes | Where-Object {$_.part -notmatch 'coupon'} | Measure-Object volume_mm3 -Sum).Sum
$oldCradle=$old.printed_solid_volume_mm3-$oldJointOnly
$oldSupport=($old.meshes | Where-Object {$_.part -eq 'support'}).volume_mm3
$saddle=($meshes | Where-Object {$_.part -eq 'saddle'}).volume_mm3
$plate=($meshes | Where-Object {$_.part -eq 'plate'}).volume_mm3
$report=@{
    meshes=$meshes
    upper_axis_spacing_mm=70
    selected_q2_range_deg=@(-40,85)
    clearance_samples=$samples
    minimum_sampled_separating_axis_gap_mm=($samples | Measure-Object separating_axis_gap_mm -Minimum).Minimum
    clearance_scope='One-degree samples of saddle rectangle against conservative hip cradle/clamp rectangle; not a continuous proof or actual cable/ear/fastener check. Upper plate is axially above cases; bridge radial bound from previous joint remains valid.'
    knee_case_window_clearance_per_side_mm=0.7
    hip_plate_case_axial_gap_mm=4.1
    knee_holder_solid_mass_g=$saddle/1000*1.27
    old_clamp_alone_solid_mass_g=$oldCradle/1000*1.27
    old_clamp_plus_support_solid_mass_g=($oldCradle+$oldSupport)/1000*1.27
    upper_plate_solid_mass_g=$plate/1000*1.27
    case_holder_volume_reduction_percent=100*(1-$saddle/$oldCradle)
    mass_comparison_scope='Case holder only; new knee passive rear support still required and excluded from saddle mass'
    knee_holder_gravity_at_70mm_with_55g_servo_Nm=(55+$saddle/1000*1.27)/1000*9.81*0.07
    limits='Knee passive rear support and lower leg not designed here; no output loading. Prototype knee20–90deg is a provisional downstream packaging limit, not measured or a revision of historical desired20–130deg.'
    actual_fit_verified=$false
}
$report | ConvertTo-Json -Depth 8 | Set-Content (Join-Path $PSScriptRoot 'prototype-upper-leg-check.json') -Encoding UTF8
Write-Output ('PASS: three connected closed print meshes;70mm spacing; sampled clearance minimum {0:F2}mm.' -f $report.minimum_sampled_separating_axis_gap_mm)
Write-Output ('Knee case holder {0:F1}g solid versus old clamp alone {1:F1}g; upper plate {2:F1}g solid. New rear support excluded.' -f $report.knee_holder_solid_mass_g,$report.old_clamp_alone_solid_mass_g,$report.upper_plate_solid_mass_g)
