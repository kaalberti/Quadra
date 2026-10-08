param([string]$ExistingCore=(Join-Path $env:USERPROFILE '.platformio'))
$ErrorActionPreference='Stop'
# Read existing tools; never run a global install. Copy only into this project.
$benchPlatform=Join-Path $ExistingCore 'platforms\espressif32'
$benchVersion=(Get-Content (Join-Path $benchPlatform 'platform.json') -Raw|ConvertFrom-Json).version
if ($benchVersion -ne '7.0.1') { throw 'Expected existing Espressif platform7.0.1; do not silently change build versions' }
$benchPackages=@('framework-arduinoespressif32','toolchain-xtensa-esp32s3','toolchain-riscv32-esp','tool-esptoolpy','tool-scons')
foreach ($benchPackage in $benchPackages) {
 if (-not(Test-Path -LiteralPath (Join-Path $ExistingCore "packages\$benchPackage"))) { throw "Missing existing package: $benchPackage" }
}
$benchLocal=Join-Path $PSScriptRoot '.pio-core'
New-Item -ItemType Directory -Force (Join-Path $benchLocal 'platforms'),(Join-Path $benchLocal 'packages') | Out-Null
Copy-Item -LiteralPath $benchPlatform -Destination (Join-Path $benchLocal 'platforms') -Recurse -Force
foreach ($benchPackage in $benchPackages) {
 Copy-Item -LiteralPath (Join-Path $ExistingCore "packages\$benchPackage") -Destination (Join-Path $benchLocal 'packages') -Recurse -Force
}
$benchTools=Join-Path $PSScriptRoot 'tools'
New-Item -ItemType Directory -Force $benchTools | Out-Null
$benchArchive=Join-Path $benchTools 'zig-0.13.0.zip'
if (-not(Test-Path -LiteralPath $benchArchive)) {
 Invoke-WebRequest -Uri 'https://ziglang.org/download/0.13.0/zig-windows-x86_64-0.13.0.zip' -OutFile $benchArchive
}
$benchExpected='d859994725ef9402381e557c60bb57497215682e355204d754ee3df75ee3c158'
if ((Get-FileHash -LiteralPath $benchArchive -Algorithm SHA256).Hash.ToLowerInvariant() -ne $benchExpected) { throw 'Compiler archive hash mismatch' }
$benchCompiler=Join-Path $benchTools 'zig-windows-x86_64-0.13.0\zig.exe'
if (-not(Test-Path -LiteralPath $benchCompiler)) { Expand-Archive -LiteralPath $benchArchive -DestinationPath $benchTools }
Write-Output 'Project-local build/test tools prepared; no global packages installed.'
