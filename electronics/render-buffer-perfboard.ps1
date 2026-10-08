param([switch]$VoltageAddon)
$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.Drawing
$data=Get-Content (Join-Path $PSScriptRoot 'buffer-perfboard-layout.json') -Raw|ConvertFrom-Json
if($VoltageAddon){
 $addon=Get-Content (Join-Path $PSScriptRoot 'voltage-perfboard-addon.json') -Raw|ConvertFrom-Json
 $data.components=@($data.components)+@($addon.components)
 $data.headers=@($data.headers)+@($addon.headers)
}
$picture=[Drawing.Bitmap]::new(1080,830)
$canvas=[Drawing.Graphics]::FromImage($picture)
$canvas.Clear([Drawing.Color]::White)
$canvas.SmoothingMode=[Drawing.Drawing2D.SmoothingMode]::AntiAlias
$font=[Drawing.Font]::new('Arial',8)
$titleFont=[Drawing.Font]::new('Arial',14)
$black=[Drawing.Brushes]::Black
$gridPen=[Drawing.Pen]::new([Drawing.Color]::LightGray,1)
$partPen=[Drawing.Pen]::new([Drawing.Color]::DarkSlateBlue,2)
$headerPen=[Drawing.Pen]::new([Drawing.Color]::DarkRed,2)
$canvas.DrawString('Buffer perfboard: TOP component view; notch toward row 0',$titleFont,$black,45,12)
for($col=0;$col -lt $data.grid.columns;$col++){$canvas.DrawString([string]$col,$font,$black,(75+$col*27-5),47)}
for($row=0;$row -lt $data.grid.rows;$row++){
 $canvas.DrawString([string]$row,$font,$black,48,(75+$row*27-6))
 for($col=0;$col -lt $data.grid.columns;$col++){$canvas.DrawEllipse($gridPen,(75+$col*27-2),(75+$row*27-2),4,4)}
}
foreach($part in $data.components){
 if($part.kind -and $part.kind.StartsWith('PDIP')){
  $left=($part.pins|Measure-Object column -Minimum).Minimum;$right=($part.pins|Measure-Object column -Maximum).Maximum
  $top=($part.pins|Measure-Object row -Minimum).Minimum;$bottom=($part.pins|Measure-Object row -Maximum).Maximum
  $canvas.FillRectangle([Drawing.Brushes]::LightSteelBlue,(75+($left-.4)*27),(75+($top-.4)*27),(($right-$left+.8)*27),(($bottom-$top+.8)*27))
  $canvas.DrawArc($partPen,(75+($left+1)*27),(75+($top-.4)*27),27,20,0,180)
  $canvas.DrawString($part.id,$titleFont,$black,(75+($left+.6)*27),(75+($top+2.8)*27))
 }else{
  $first=$part.pins[0];$last=$part.pins[1]
  $canvas.DrawLine($partPen,(75+$first.column*27),(75+$first.row*27),(75+$last.column*27),(75+$last.row*27))
  $canvas.DrawString($part.id,$font,$black,(75+($first.column+$last.column)*13.5-9),(75+($first.row+$last.row)*13.5-17))
 }
 foreach($pin in $part.pins){$canvas.FillEllipse([Drawing.Brushes]::DarkSlateBlue,(75+$pin.column*27-3),(75+$pin.row*27-3),6,6)}
}
foreach($header in $data.headers){
 foreach($pin in $header.pins){$canvas.DrawRectangle($headerPen,(75+$pin.column*27-4),(75+$pin.row*27-4),8,8)}
 $first=$header.pins[0];$canvas.DrawString($header.id,$font,[Drawing.Brushes]::DarkRed,(75+$first.column*27),(75+$first.row*27-20))
}
$canvas.DrawString('35 x25 isolated-pad grid,2.54mm pitch; signal-only outputs S1/S2/S3.',$titleFont,$black,45,752)
$canvas.DrawString('Wire same-name nets from JSON; this image shows placement, not underside jumper routes.',$font,$black,45,784)
$outputName=if($VoltageAddon){'voltage-perfboard-layout.png'}else{'buffer-perfboard-layout.png'}
$picture.Save((Join-Path $PSScriptRoot $outputName),[Drawing.Imaging.ImageFormat]::Png)
$canvas.Dispose();$picture.Dispose();$font.Dispose();$titleFont.Dispose();$gridPen.Dispose();$partPen.Dispose();$headerPen.Dispose()
Write-Output 'Rendered perfboard placement image.'