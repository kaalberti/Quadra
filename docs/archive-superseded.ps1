$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest
$repo=[IO.Path]::GetFullPath((Split-Path $PSScriptRoot -Parent))
$prefix=$repo+[IO.Path]::DirectorySeparatorChar
$archive='ARCHIVE/2026-10-08-superseded-design'
if(Test-Path -LiteralPath (Join-Path $repo "$archive/manifest.json")) {throw 'Archive already exists; this one-time migration must not be rerun.'}
$utf8=[Text.UTF8Encoding]::new($false)
$template=[IO.File]::ReadAllText((Join-Path $repo 'TASK_TEMPLATE.md'))
$task=$template+@'

# ARCHIVE-001: Archive the deferred precision-servo design

Scope: repository housekeeping only; do not advance mechanical design.
Output: superseded XC330 knee/coupling files and MEC-001–121 records moved
under ARCHIVE, preserving relative paths; SHA256 move manifest and archive guide.
Retain current hobby/prototype CAD, checks, BOM, tools, kinematics and inventory.
Validation: destination containment, no collisions, all moved hashes unchanged,
current print manifest intact, active SCAD dependencies present and active checks pass.
TASK_TEMPLATE.md is empty; its contents are used as the task prefix.
Stop after archiving and updating STATUS; J1 design remains the next engineering task.
'@
[IO.File]::WriteAllText((Join-Path $repo 'NEXT_TASK.md'),$task,$utf8)
$selected=@()
foreach($dir in @('mechanical','docs','docs/tasks','tmp/pdfs')) {
 foreach($file in Get-ChildItem -LiteralPath (Join-Path $repo $dir) -File) {
  $name=$file.Name
  $reason=$null
  if($dir -eq 'mechanical' -and ($name -match '^(check[_-])?(knee[_-]|key[23]-)' -or $name -match '^run_mec\d+\.ps1$' -or $name -match '^(horn|metal-horn)-task-workflow\.ps1$' -or $name -match '^(xc330|fpx330|hnx330|bearing-axial)' -or $name -eq 'check_bearing_axial_evidence.ps1' -or $name -eq 'check_xc330_interface.py' -or $name -eq 'single-leg-packaging.svg' -or $name -match '^packaging[_-]')) {$reason='Deferred XC330 precision knee/coupling and packaging investigation'}
  if($dir -eq 'docs' -and ($name -match '^(knee-|key3-|mec-0(2[2-9]|3[01])\.|xc330-|bearing-axial)' -or $name -in @('manufacturer-inquiries.md','jst-eh-reference.pdf','single-leg-packaging.md','provisional-actuator.md','actuator-candidates.md','actuator-protection-evidence.md','actuator-attachment.md'))) {$reason='Superseded premium-servo design documentation'}
  if($dir -eq 'docs/tasks' -and $name -match '^MEC-(\d+)\.md$' -and [int]$Matches[1] -le 121) {$reason='Completed task record for deferred design; current direction begins MEC-122'}
  if($dir -eq 'tmp/pdfs') {$reason='Extracted previews of deferred manufacturer/design documents'}
  if($reason) {
   $source=[IO.Path]::GetFullPath($file.FullName)
   $relative=$source.Substring($prefix.Length).Replace('\','/')
   $destination=[IO.Path]::GetFullPath((Join-Path $repo "$archive/$relative"))
   if(-not $source.StartsWith($prefix,[StringComparison]::OrdinalIgnoreCase) -or -not $destination.StartsWith($prefix,[StringComparison]::OrdinalIgnoreCase)) {throw 'Path outside repository'}
   if(Test-Path -LiteralPath $destination) {throw "Archive collision: $destination"}
   $selected+= [pscustomobject]@{original=$relative;archived="$archive/$relative";reason=$reason;sha256=(Get-FileHash -LiteralPath $source -Algorithm SHA256).Hash}
  }
 }
}
if($selected.Count -eq 0) {throw 'No archive candidates'}
$archiveRoot=Join-Path $repo $archive
New-Item -ItemType Directory -Path $archiveRoot -Force | Out-Null
[IO.File]::WriteAllText((Join-Path $archiveRoot 'manifest.json'),(($selected|ConvertTo-Json -Depth 5)+"`n"),$utf8)
foreach($entry in $selected) {
 $source=Join-Path $repo $entry.original
 $destination=Join-Path $repo $entry.archived
 New-Item -ItemType Directory -Path (Split-Path $destination -Parent) -Force | Out-Null
 Move-Item -LiteralPath $source -Destination $destination
 if((Get-FileHash -LiteralPath $destination -Algorithm SHA256).Hash -ne $entry.sha256 -or (Test-Path -LiteralPath $source)) {throw "Move verification failed: $($entry.original)"}
}
# Rewrite references in retained Markdown only; preserve archived originals byte-for-byte.
$markdown=@(Get-ChildItem -LiteralPath $repo -File -Filter '*.md')+@(Get-ChildItem -LiteralPath (Join-Path $repo 'docs') -Recurse -File -Filter '*.md')+@(Get-ChildItem -LiteralPath (Join-Path $repo 'decisions') -File -Filter '*.md')
foreach($file in $markdown) {
 $text=[IO.File]::ReadAllText($file.FullName);$old=$text
 foreach($entry in $selected) {
  $text=$text.Replace($entry.original,$entry.archived)
  if((Split-Path $file.FullName -Parent) -eq (Join-Path $repo 'docs') -and $entry.original.StartsWith('docs/')) {
   $base=Split-Path $entry.original -Leaf
   $text=$text.Replace("]($base)","](../$($entry.archived))")
  }
 }
 if($text -ne $old) {[IO.File]::WriteAllText($file.FullName,$text,$utf8)}
}
$guide=@"
# Superseded design archive

Archived $($selected.Count) files on 2026-10-08. No files were deleted.
This contains the deferred XC330 precision knee/coupling route, its historical
MEC-001–121 task records, manufacturer references and extracted previews.
The active hobby-servo direction starts at MEC-122 and remains in the main tree.

manifest.json lists every original path, archive path, reason and SHA256.
Original relative directory layout and file contents are preserved.
Historical scripts are not maintained or guaranteed runnable in the archive:
they assume their original repository paths and may share retained baseline files.
Restore selected files to their manifest original paths before reproducing old checks;
review any task runner before execution because it can rewrite project records.

Current entry points: ../../docs/prototype-pitch-leg-build.md,
../../docs/purchasing-bom.md and ../../mechanical/prototype-pitch-leg.scad.
Current kinematics, inventory, hobby/prototype sources and local compiler are retained.
Archiving does not validate physical fit or advance the two-DOF leg to three DOF.
"@
[IO.File]::WriteAllText((Join-Path $archiveRoot 'README.md'),$guide,$utf8)
[IO.File]::WriteAllText((Join-Path $repo 'ARCHIVE/README.md'),"# Project archive`n`nSee [superseded design](2026-10-08-superseded-design/README.md) and its SHA256 manifest. Active build sources and BOM remain in mechanical/ and docs/.`n",$utf8)
Write-Output "Archived and hash-verified $($selected.Count) files."
