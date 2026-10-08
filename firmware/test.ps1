param([string]$Compiler=(Join-Path $PSScriptRoot 'tools\zig-windows-x86_64-0.13.0\zig.exe'),
      [string]$Python=(Join-Path $env:USERPROFILE '.platformio\penv\Scripts\python.exe'))
$ErrorActionPreference='Stop'
$benchOutput=Join-Path $PSScriptRoot 'test-output'
New-Item -ItemType Directory -Force $benchOutput | Out-Null
$env:ZIG_GLOBAL_CACHE_DIR=Join-Path $benchOutput 'zig-global-cache'
$env:ZIG_LOCAL_CACHE_DIR=Join-Path $benchOutput 'zig-local-cache'
$benchExe=Join-Path $benchOutput 'bench-test.exe'
& $Compiler c++ -std=c++17 -Wall -Wextra -Werror -I (Join-Path $PSScriptRoot 'include') (Join-Path $PSScriptRoot 'test\bench_test.cpp') -o $benchExe
if ($LASTEXITCODE -ne 0) { throw 'Host compilation failed' }
& $benchExe
if ($LASTEXITCODE -ne 0) { throw 'Controller tests failed' }
$benchCalibrationExe=Join-Path $benchOutput 'calibration-test.exe'
& $Compiler c++ -std=c++17 -Wall -Wextra -Werror -I (Join-Path $PSScriptRoot 'include') (Join-Path $PSScriptRoot 'test\calibration_test.cpp') -o $benchCalibrationExe
if ($LASTEXITCODE -ne 0) { throw 'Calibration compilation failed' }
& $benchCalibrationExe
if ($LASTEXITCODE -ne 0) { throw 'Calibration tests failed' }
foreach ($benchSource in @('geometry_test','geometry_cli')) {
 $benchGeometryExe=Join-Path $benchOutput ($benchSource+'.exe')
 & $Compiler c++ -std=c++17 -Wall -Wextra -Werror -I (Join-Path $PSScriptRoot 'include') (Join-Path $PSScriptRoot ('test\'+$benchSource+'.cpp')) -o $benchGeometryExe
 if ($LASTEXITCODE -ne 0) { throw 'Geometry compilation failed' }
 if ($benchSource -eq 'geometry_test') { & $benchGeometryExe; if ($LASTEXITCODE -ne 0) { throw 'Geometry tests failed' } }
}
# Keep the CLI name stable for the independent CAD comparison.
Copy-Item -LiteralPath (Join-Path $benchOutput 'geometry_cli.exe') -Destination (Join-Path $benchOutput 'geometry-cli.exe') -Force
& node --test (Join-Path $PSScriptRoot 'test\geometry-reference.test.mjs')
if ($LASTEXITCODE -ne 0) { throw 'CAD geometry comparison failed' }
$env:PYTHONDONTWRITEBYTECODE='1'
& $Python -m unittest discover -s (Join-Path $PSScriptRoot 'test') -p test_console.py -v
if ($LASTEXITCODE -ne 0) { throw 'Console tests failed' }
