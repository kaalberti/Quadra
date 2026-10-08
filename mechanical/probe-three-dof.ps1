param([string]$Mode='carrier-collision',[double[]]$Angles=@(20,44.0486,55))
$ErrorActionPreference='Stop'
$cad=Join-Path $PSScriptRoot 'tools/openscad-2021.01/openscad.com'
$results=@()
foreach($angle in $Angles) {
 $id=($angle.ToString([Globalization.CultureInfo]::InvariantCulture)).Replace('.','p')
 $base=Join-Path $PSScriptRoot "three-dof-$Mode-$id"
 $def=if($Mode -eq 'fixed-collision'){"q1=$angle"}else{"q2=$angle"}
 $log=(& $cad -o "$base.stl" -D ('mode="'+$Mode+'"') -D $def (Join-Path $PSScriptRoot 'prototype-three-dof-leg.scad') 2>&1|Out-String)
 [IO.File]::WriteAllText("$base.log",$log)
 if($log -match 'ERROR:') {throw "Probe error $Mode $angle"}
 $volume=0.0
 $empty=$log -match 'top level object is empty'
 if(-not $empty) {
  if(-not(Test-Path "$base.stl")){throw 'No probe output'}
  $vertices=@([regex]::Matches([IO.File]::ReadAllText("$base.stl"),'vertex\s+([-+\d.eE]+)\s+([-+\d.eE]+)\s+([-+\d.eE]+)')|ForEach-Object {,@([double]$_.Groups[1].Value,[double]$_.Groups[2].Value,[double]$_.Groups[3].Value)})
  for($i=0;$i -lt $vertices.Count;$i+=3) {
   $a=$vertices[$i];$b=$vertices[$i+1];$c=$vertices[$i+2]
   $volume+=($a[0]*($b[1]*$c[2]-$b[2]*$c[1])+$a[1]*($b[2]*$c[0]-$b[0]*$c[2])+$a[2]*($b[0]*$c[1]-$b[1]*$c[0]))/6
  }
 }
 $results+=@{mode=$Mode;angle_deg=$angle;intersection_empty=$empty;intersection_volume_mm3=[math]::Abs($volume);acceptable=[math]::Abs($volume) -lt 0.01;note='Zero-volume mating faces permitted; full swept-volume and actual hardware/cables remain unverified'}
 $results|ConvertTo-Json -Depth 5|Set-Content (Join-Path $PSScriptRoot "three-dof-$Mode-results.json") -Encoding UTF8
 if([math]::Abs($volume) -ge 0.01){throw "Solid intersection at $Mode $angle : $volume mm3"}
 Write-Output "PASS: $Mode $angle; intersection volume $volume mm3"
}
