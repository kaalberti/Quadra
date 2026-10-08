param([string]$PlatformIO="C:\Users\Kyle\.platformio\penv\Scripts\platformio.exe")
$ErrorActionPreference='Stop'
$env:PLATFORMIO_CORE_DIR=Join-Path $PSScriptRoot '.pio-core'
$env:PLATFORMIO_SETTING_ENABLE_TELEMETRY='No'
$env:PLATFORMIO_SETTING_CHECK_PLATFORMIO_INTERVAL='0'
$env:PLATFORMIO_SETTING_CHECK_PLATFORMS_INTERVAL='0'
$env:PLATFORMIO_SETTING_CHECK_LIBRARIES_INTERVAL='0'
$env:PYTHONDONTWRITEBYTECODE='1'
& $PlatformIO run --project-dir $PSScriptRoot
if ($LASTEXITCODE -ne 0) { throw 'Embedded build failed' }
