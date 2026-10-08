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
$env:PYTHONDONTWRITEBYTECODE='1'
& $Python -m unittest discover -s (Join-Path $PSScriptRoot 'test') -p test_console.py -v
if ($LASTEXITCODE -ne 0) { throw 'Console tests failed' }
