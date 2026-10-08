param([Parameter(Mandatory=$true)][string]$Root)
$ErrorActionPreference = 'Stop'
$Root = (Resolve-Path -LiteralPath $Root).Path
$manifest = Get-Content -LiteralPath (Join-Path $Root 'MANIFEST.json') -Raw | ConvertFrom-Json
foreach ($entry in $manifest.files) {
  $path = Join-Path $Root $entry.path
  if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "Missing required file: $($entry.path). Extract the whole ZIP." }
  $got = (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash.ToLowerInvariant()
  if ($got -ne $entry.sha256) { throw "Changed or corrupt file: $($entry.path). Use a fresh complete extraction." }
}
Write-Host "Project 5 preflight passed: $($manifest.files.Count) files. Root: $Root"
