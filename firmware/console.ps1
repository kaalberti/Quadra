param([switch]$AllowLegacyPwm, [Parameter(Mandatory=$true)][string]$Port,
      [string]$Python=(Join-Path $env:USERPROFILE '.platformio\penv\Scripts\python.exe'))
$ErrorActionPreference='Stop'
if (-not $AllowLegacyPwm) { throw 'Legacy PWM console cannot control ST3215. Only use -AllowLegacyPwm for intentional legacy work.' }
$env:PYTHONDONTWRITEBYTECODE='1'
& $Python (Join-Path $PSScriptRoot 'bench_console.py') --port $Port --allow-legacy-pwm
if ($LASTEXITCODE -ne 0) { throw 'Bench console failed' }
