$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest
$repo=Split-Path $PSScriptRoot -Parent
$pack=Join-Path $repo 'manufacturing'
$archive=Join-Path $repo 'ARCHIVE/MFG-002-three-dof-bench-2'
$utf8=[Text.UTF8Encoding]::new($false)
function WriteJson($path,$value){[IO.File]::WriteAllText($path,($value|ConvertTo-Json -Depth 20)+"`n",$utf8)}
& (Join-Path $PSScriptRoot 'check-manufacturing-pack.ps1')
$old=Get-Content (Join-Path $pack 'release-manifest.json') -Raw|ConvertFrom-Json
if($old.revision -ne 'three-dof-bench-2'){throw 'Expected bench-2 checkpoint'}
if(Test-Path -LiteralPath $archive){throw 'Archive already exists; refusing overwrite'}
$root=[IO.Path]::GetFullPath($repo)+[IO.Path]::DirectorySeparatorChar
foreach($p in @($pack,$archive)){if(-not([IO.Path]::GetFullPath($p).StartsWith($root,[StringComparison]::OrdinalIgnoreCase))){throw 'Path outside repository'}}
$manifestHash=(Get-FileHash (Join-Path $pack 'release-manifest.json')).Hash
$rigid=Get-Content (Join-Path $repo 'mechanical/rigid-bench-check.json') -Raw|ConvertFrom-Json
if($rigid.proper_printed_poses -ne 29 -or $rigid.proper_servo_poses -ne 3 -or $rigid.physical_fit_verified){throw 'Invalid bench assembly validation'}
foreach($p in $rigid.parts){if((Get-FileHash (Join-Path $repo $p.file)).Hash -ne $p.sha256){throw 'Stale rigid bench STL'}}
Move-Item -LiteralPath $pack -Destination $archive
if((Get-FileHash (Join-Path $archive 'release-manifest.json')).Hash -ne $manifestHash){throw 'Archived manifest differs'}
foreach($p in $old.files){if((Get-FileHash (Join-Path $archive $p.file)).Hash -ne $p.sha256){throw 'Archived checkpoint differs'}}
foreach($dir in @('stl','coupons','cad','docs')){New-Item -ItemType Directory -Path (Join-Path $pack $dir) -Force|Out-Null}
foreach($p in $old.files){
 if($p.file.StartsWith('cad/') -or $p.file -in @('stl/prototype-j1-carrier.stl','stl/prototype-upper-leg-saddle.stl')){continue}
 Copy-Item -LiteralPath (Join-Path $archive $p.file) -Destination (Join-Path $pack $p.file)
}
$parts=@($old.parts)
foreach($spec in @(@('prototype-j1-carrier','carrier'),@('prototype-upper-leg-saddle','saddle'))){
 $part=@($parts|Where-Object {$_.file -eq "stl/$($spec[0]).stl"})
 if($part.Count -ne 1){throw 'Expected one handed-part entry'}
 $part[0].file="stl/$($spec[0])-mirrored.stl";$part[0].cad='cad/prototype-handed-parts.scad';$part[0].selector=$spec[1]
 $part[0].sha256=(Get-FileHash (Join-Path $repo "mechanical/$($spec[0])-mirrored.stl")).Hash
 Copy-Item -LiteralPath (Join-Path $repo "mechanical/$($spec[0])-mirrored.stl") -Destination (Join-Path $pack $part[0].file)
}
$queue=[Collections.Generic.Queue[string]]::new();$seen=@{}
$queue.Enqueue('prototype-rigid-bench-pack-assembly.scad');foreach($p in $parts){$queue.Enqueue((Split-Path $p.cad -Leaf))}
while($queue.Count){
 $name=$queue.Dequeue();if($seen.ContainsKey($name)){continue};$seen[$name]=$true
 $source=Join-Path $repo "mechanical/$name";Copy-Item -LiteralPath $source -Destination (Join-Path $pack "cad/$name")
 foreach($m in [regex]::Matches([IO.File]::ReadAllText($source),'(?:use|include)\s*<([^>]+)>')){$queue.Enqueue($m.Groups[1].Value)}
}
$print=Get-Content (Join-Path $repo 'mechanical/three-dof-print-manifest.json') -Raw|ConvertFrom-Json
$print.revision='three-dof-bench-3'
$print.parts=@($rigid.parts)
WriteJson (Join-Path $repo 'mechanical/three-dof-print-manifest.json') $print
$guide=[IO.File]::ReadAllText((Join-Path $repo 'docs/three-dof-prototype-build.md')).Replace('../mechanical/prototype-rigid-bench-assembly.png','assembly.png').Replace('using its guide','using [the pitch-leg reference guide](pitch-leg-assembly.md)')
[IO.File]::WriteAllText((Join-Path $pack 'docs/assembly.md'),$guide,$utf8)
Copy-Item -LiteralPath (Join-Path $repo 'mechanical/prototype-rigid-bench-assembly.png') -Destination (Join-Path $pack 'docs/assembly.png')
$list="# Print quantities — three-dof-bench-3`n`n18 unique assembly STLs/29 pieces; four coupons first. Use the mirrored carrier and saddle listed below.`n`n| File | Quantity | Type |`n| --- | ---: | --- |`n"
foreach($p in $parts){$type=if($p.fit_coupon){'Fit coupon'}elseif($p.fixture_only){'Bench adapter'}else{'Leg part'};$list+="| [$($p.file)](../$($p.file)) | $($p.quantity) | $type |`n"}
[IO.File]::WriteAllText((Join-Path $pack 'docs/print-list.md'),$list,$utf8)
$readme=[IO.File]::ReadAllText((Join-Path $pack 'README.md')).Replace('three-dof-bench-2','three-dof-bench-3').Replace('cad/prototype-three-dof-leg.scad','cad/prototype-rigid-bench-pack-assembly.scad')
$readme+="`nMEC-159 selects mirrored carrier/saddle prints and provides proper rigid printed-part`nplacements. Bench-2 is archived intact; its original carrier/saddle print selection`ndid not establish this physical assembly. Hardware and nominal geometry are unchanged.`nThe pitch-leg guide is a bearing/fastener reference: current print list and main`nassembly guide govern handed parts. Physical fit/powered operation remain untested.`n"
[IO.File]::WriteAllText((Join-Path $pack 'README.md'),$readme,$utf8)
$validation=Get-Content (Join-Path $pack 'validation.json') -Raw|ConvertFrom-Json
$validation.revision='three-dof-bench-3';$validation|Add-Member NoteProperty rigid_bench $rigid
WriteJson (Join-Path $pack 'validation.json') $validation
$old.revision='three-dof-bench-3';$old.date='2026-10-09';$old.parts=$parts
$old.files=@(Get-ChildItem $pack -Recurse -File|ForEach-Object{[pscustomobject]@{file=$_.FullName.Substring($pack.Length+1).Replace('\','/');sha256=(Get-FileHash -LiteralPath $_.FullName).Hash}})
WriteJson (Join-Path $pack 'release-manifest.json') $old
& (Join-Path $PSScriptRoot 'check-manufacturing-pack.ps1')
Write-Output 'Bench-3 created; bench-2 archived with exact bytes verified.'
