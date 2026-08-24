param([switch]$InstallAutostart)
$ErrorActionPreference = "Stop"
$helperDir = Split-Path -Parent $MyInvocation.MyCommand.Path
if (!(Test-Path (Join-Path $helperDir ".env"))) { Write-Error "helper\.env fehlt. Kopiere zuerst .env.example nach .env."; exit 1 }
if ($InstallAutostart) {
  $scriptPath = $MyInvocation.MyCommand.Path
  $argument = '-WindowStyle Hidden -ExecutionPolicy Bypass -File "' + $scriptPath + '"'
  $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument $argument
  $trigger = New-ScheduledTaskTrigger -AtLogOn
  Register-ScheduledTask -TaskName "Reddit Wallpaper Helper" -Action $action -Trigger $trigger -Description "Local helper for Reddit Wallpaper" -Force | Out-Null
  Write-Host "Autostart task installed."
  exit
}
Set-Location (Split-Path -Parent $helperDir)
node helper/src/server.js
