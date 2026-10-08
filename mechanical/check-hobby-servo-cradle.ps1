$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
$repo = Split-Path $PSScriptRoot -Parent
$culture = [Globalization.CultureInfo]::InvariantCulture
$results = @()
foreach ($part in @('left','right','coupon')) {
    $path = Join-Path $PSScriptRoot "hobby-servo-cradle-$part.stl"
    $vertices = @([regex]::Matches([IO.File]::ReadAllText($path), 'vertex\s+([-+\d.eE]+)\s+([-+\d.eE]+)\s+([-+\d.eE]+)') | ForEach-Object {
        ,@([double]::Parse($_.Groups[1].Value,$culture),[double]::Parse($_.Groups[2].Value,$culture),[double]::Parse($_.Groups[3].Value,$culture))
    })
    if ($vertices.Count -eq 0 -or $vertices.Count % 3) { throw "Invalid triangle data: $part" }
    $edges = @{}
    for ($i=0; $i -lt $vertices.Count; $i+=3) {
        $keys = @(0..2 | ForEach-Object { ($vertices[$i+$_] | ForEach-Object { $_.ToString('G17',$culture) }) -join ',' })
        if (($keys | Select-Object -Unique).Count -ne 3) { throw "Degenerate triangle: $part" }
        foreach ($pair in @(@(0,1),@(1,2),@(2,0))) {
            $edge = (@($keys[$pair[0]],$keys[$pair[1]]) | Sort-Object) -join '|'
            if ($edges.ContainsKey($edge)) { $edges[$edge]++ } else { $edges[$edge]=1 }
        }
    }
    if (@($edges.Values | Where-Object { $_ -ne 2 }).Count) { throw "Mesh is not closed: $part" }
    $bounds = @(0..2 | ForEach-Object {
        $axis = $_
        $m = $vertices | ForEach-Object { $_[$axis] } | Measure-Object -Minimum -Maximum
        @{min=$m.Minimum;max=$m.Maximum}
    })
    if ([math]::Abs($bounds[2].min) -gt 0.00001) { throw "Part not on print bed: $part" }
    $results += @{part=$part;triangles=$vertices.Count/3;closed_edges=$true;bounds_mm=$bounds}
}
$force = 1.2*9.81/3
$standingKnee = $force*0.049 + 0.08
$straightLeg = $force*0.155 + 0.08
$stall = 9.4*0.0980665
$report = @{
    meshes=$results
    pocket_mm=@{length=41.5;width=20.5;depth=18;floor=3;split_gap=1}
    screen=@{support_force_N=$force;standing_knee_Nm=$standingKnee;allowance_Nm=0.08;stall_at_4_8V_Nm=$stall;standing_stall_ratio=$stall/$standingKnee;extended_horizontal_bound_Nm=$straightLeg;restriction='Bent-pose prototype only; no full-range or continuous-torque qualification'}
    budget_NZD=@{unit_servo_cap=@(25,35);quantity=12;servo_total=@(300,420);other_allowance=300;reserve=80;total=@(680,800);actual_prices_verified=$false}
    servo_mass_g=12*55
    physical_fit_verified=$false
}
$report | ConvertTo-Json -Depth 8 | Set-Content (Join-Path $PSScriptRoot 'hobby-servo-cradle-check.json') -Encoding UTF8
Write-Output 'PASS: three closed STL meshes on the print bed; torque and budget screens saved.'
