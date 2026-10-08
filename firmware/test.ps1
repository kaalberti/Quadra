param([string]$Compiler=(Join-Path $PSScriptRoot 'tools\zig-windows-x86_64-0.13.0\zig.exe'))
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
