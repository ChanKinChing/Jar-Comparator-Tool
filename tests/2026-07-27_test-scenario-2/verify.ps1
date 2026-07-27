$A = "C:\MY_PROJECTS_\__temp__\2026-07-27_test-scenario-2\folderA"
$B = "C:\MY_PROJECTS_\__temp__\2026-07-27_test-scenario-2\folderB"

function Show-Jar($p) {
  $t = "$env:TEMP\_jarverify"
  if (Test-Path $t) { Remove-Item $t -Recurse -Force }
  Expand-Archive -LiteralPath $p -DestinationPath $t -Force
  $files = Get-ChildItem $t -Recurse | Where-Object { !$_.PSIsContainer }
  $files | ForEach-Object { Write-Host "    $($_.FullName.Substring($t.Length+1)) [$($_.Length) bytes]" }
  Remove-Item $t -Recurse -Force
  $files.Count
}

# Count A jars
$ajars = Get-ChildItem $A -Recurse *.jar
$bjars = Get-ChildItem $B -Recurse *.jar
Write-Host "=== SUMMARY ==="
Write-Host "folderA: $($ajars.Count) jars"
Write-Host "folderB: $($bjars.Count) jars"

# Match by filename
$bNames = @{}
$bjars | ForEach-Object { $bNames[$_.Name] = $_.FullName }

$matched = 0; $onlyA = 0; $onlyB = 0
$ajars | ForEach-Object {
  if ($bNames.ContainsKey($_.Name)) { $matched++ }
  else { $onlyA++ }
}
$bjars | ForEach-Object {
  if ($ajars.Name -notcontains $_.Name) { $onlyB++ }
}

Write-Host "--- Match stats ---"
Write-Host "Matched pairs: $matched"
Write-Host "Only in A: $onlyA"
Write-Host "Only in B: $onlyB"

# Verify specific jars
Write-Host "`n=== SPOT CHECKS ==="
Write-Host "`nidentical.jar (A): $(Show-Jar "$A\identical.jar") entries"
Write-Host "empty.jar (A): $(Show-Jar "$A\empty.jar") entries"
Write-Host "deep-path.jar (A): $(Show-Jar "$A\deep-path.jar") entries"
Write-Host "special-chars.jar (A): $(Show-Jar "$A\special-chars.jar") entries"
Write-Host "binary-diff.jar (A): $(Show-Jar "$A\binary-diff.jar") entries"
Write-Host "large-file.jar (A): $(Show-Jar "$A\large-file.jar") entries"
Write-Host "mult-mod.jar (A): $(Show-Jar "$A\multi-mod.jar") entries"
Write-Host "many-files.jar (A): $(Show-Jar "$A\many-files.jar") entries"

# Check subfolder jars
Write-Host "`n=== SUBFOLDER JARS ==="
Write-Host "A sub/multi-loc.jar: $(if (Test-Path "$A\sub\multi-loc.jar") { 'Exists' } else { 'MISSING!' })"
Write-Host "B multi-loc.jar: $(if (Test-Path "$B\multi-loc.jar") { 'Exists' } else { 'MISSING!' })"
Write-Host "A lib/sub/lib-common.jar: $(if (Test-Path "$A\lib\sub\lib-common.jar") { 'Exists' } else { 'MISSING!' })"
Write-Host "B lib/lib-common.jar: $(if (Test-Path "$B\lib\lib-common.jar") { 'Exists' } else { 'MISSING!' })"

Write-Host "`n=== DONE ==="
