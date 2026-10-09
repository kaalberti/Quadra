$ErrorActionPreference='Stop'
$firmwareRoot=Split-Path $PSScriptRoot -Parent
$compiler=Join-Path $firmwareRoot 'tools/zig-windows-x86_64-0.13.0/zig.exe'
$outputRoot=Join-Path $firmwareRoot 'test-output'
New-Item -ItemType Directory -Force $outputRoot | Out-Null
$env:ZIG_GLOBAL_CACHE_DIR=Join-Path $outputRoot 'zig-global-cache'
$env:ZIG_LOCAL_CACHE_DIR=Join-Path $outputRoot 'zig-local-cache'
foreach($name in @('bench','console')){
 $exe=Join-Path $outputRoot "st3215-$name-test.exe"
 & $compiler c++ -std=c++17 -Wall -Wextra -Werror -I (Join-Path $PSScriptRoot 'include') -I (Join-Path $PSScriptRoot 'test') (Join-Path $PSScriptRoot "test/$name`_test.cpp") -o $exe
 if($LASTEXITCODE -ne 0){throw "$name host compile failed"}
 & $exe
 if($LASTEXITCODE -ne 0){throw "$name host checks failed"}
}
