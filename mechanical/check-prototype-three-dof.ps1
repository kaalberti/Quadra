$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest
$culture=[Globalization.CultureInfo]::InvariantCulture
$names=@('j1-carrier')
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

$layout=Get-Content (Join-Path $PSScriptRoot 'prototype-three-dof-layout.json') -Raw|ConvertFrom-Json
$screens=@()
foreach($q in @(0,15,30)) {
 $r=$q*[math]::PI/180
 $lever=($layout.foot_outward_mm*[math]::Cos($r)+120*[math]::Sin($r))/1000
 $screens+=@{q1_deg=$q;ground_force_N=2*9.81/3;lateral_lever_mm=$lever*1000;moving_mass_allowance_Nm=0.12;required_Nm=(2*9.81/3)*$lever+0.12}
}
$report=@{revision='three-dof-bench-1';meshes=$meshes;carrier_solid_mass_g=$meshes[0].volume_mm3/1000*1.27;j1_static_screens=$screens;published_stall_at_4_8V_Nm=9.4*0.0980665;physical_fit_verified=$false;powered_operation_approved=$false;limits='Ground force uses 2kg/three support legs, 120mm nominal stance and 0.12Nm moving-part allowance. Stall is not continuous torque; no loaded range approval. Prototype offsets do not amend the historical skeleton.'}
$report|ConvertTo-Json -Depth 8|Set-Content (Join-Path $PSScriptRoot 'prototype-three-dof-check.json') -Encoding UTF8
Write-Output ('PASS: closed connected carrier on bed; {0:F1}g solid; J1 neutral {1:F2}Nm vs {2:F2}Nm stall.' -f $report.carrier_solid_mass_g,$screens[0].required_Nm,$report.published_stall_at_4_8V_Nm)


