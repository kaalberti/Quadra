param([switch]$AllowLegacyPwm, [string]$PlatformIO=(Join-Path $env:USERPROFILE '.platformio\penv\Scripts\platformio.exe'))
$ErrorActionPreference='Stop'
if (-not $AllowLegacyPwm) { throw 'Legacy MG996R/PCA9685 firmware cannot control ST3215. Only use -AllowLegacyPwm for intentional legacy work.' }
$env:PLATFORMIO_CORE_DIR=Join-Path $PSScriptRoot '.pio-core'
$env:PLATFORMIO_SETTING_ENABLE_TELEMETRY='No'
$env:PLATFORMIO_SETTING_CHECK_PLATFORMIO_INTERVAL='0'
$env:PLATFORMIO_SETTING_CHECK_PLATFORMS_INTERVAL='0'
$env:PLATFORMIO_SETTING_CHECK_LIBRARIES_INTERVAL='0'
$env:PYTHONDONTWRITEBYTECODE='1'
& $PlatformIO run --project-dir $PSScriptRoot
if ($LASTEXITCODE -ne 0) { throw 'Embedded build failed' }
