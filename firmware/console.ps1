param([Parameter(Mandatory=$true)][string]$Port,
      [string]$Python=(Join-Path $env:USERPROFILE '.platformio\penv\Scripts\python.exe'))
$ErrorActionPreference='Stop'
$env:PYTHONDONTWRITEBYTECODE='1'
& $Python (Join-Path $PSScriptRoot 'bench_console.py') --port $Port
if ($LASTEXITCODE -ne 0) { throw 'Bench console failed' }
