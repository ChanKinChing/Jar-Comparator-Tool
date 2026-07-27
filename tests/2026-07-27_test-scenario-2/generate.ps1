param([string]$OutDir = "$PSScriptRoot")

Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

function New-Jar {
  param([string]$Path, [object[]]$Entries)
  $dir = Split-Path $Path -Parent
  if (!(Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
  if (Test-Path $Path) { Remove-Item $Path -Force }
  $zip = [System.IO.Compression.ZipFile]::Open($Path, [System.IO.Compression.ZipArchiveMode]::Create)
  try {
    foreach ($e in $Entries) {
      $entry = $zip.CreateEntry($e.Name, [System.IO.Compression.CompressionLevel]::Optimal)
      $stream = $entry.Open()
      if ($e.Text -ne $null) {
        $sw = New-Object System.IO.StreamWriter($stream, [System.Text.Encoding]::UTF8)
        $sw.Write($e.Text)
        $sw.Flush()
      } elseif ($e.Bytes -ne $null) {
        $stream.Write($e.Bytes, 0, $e.Bytes.Length)
      }
      $stream.Close()
    }
  } finally { $zip.Dispose() }
}

$dirA = "$OutDir\folderA"
$dirB = "$OutDir\folderB"

# ── 1. identical ──
New-Jar "$dirA\identical.jar" @(
  @{Name="hello.txt"; Text="Hello World`n"}
  @{Name="config.properties"; Text="key=value`napp.version=1.0`n"}
  @{Name="META-INF/MANIFEST.MF"; Text="Manifest-Version: 1.0`n"}
)
New-Jar "$dirB\identical.jar" @(
  @{Name="hello.txt"; Text="Hello World`n"}
  @{Name="config.properties"; Text="key=value`napp.version=1.0`n"}
  @{Name="META-INF/MANIFEST.MF"; Text="Manifest-Version: 1.0`n"}
)
Write-Host "1/22 identical.jar"

# ── 2. empty ──
$null -eq (New-Jar "$dirA\empty.jar" @())
$null -eq (New-Jar "$dirB\empty.jar" @())
Write-Host "2/22 empty.jar"

# ── 3. single ──
New-Jar "$dirA\single.jar" @(@{Name="readme.txt"; Text="This is a single file jar.`n"})
New-Jar "$dirB\single.jar" @(@{Name="readme.txt"; Text="This is a single file jar.`n"})
Write-Host "3/22 single.jar"

# ── 4. many-files (60) ──
$mf = @()
for ($i = 1; $i -le 60; $i++) {
  $n = "{0:D3}.txt" -f $i
  $mf += @{Name=$n; Text="Line 1 of file $i`nLine 2 of file $i`n"}
}
New-Jar "$dirA\many-files.jar" $mf
New-Jar "$dirB\many-files.jar" $mf
Write-Host "4/22 many-files.jar"

# ── 5. diff-size ──
New-Jar "$dirA\diff-size.jar" @(@{Name="data.bin"; Text="Hello World`n"})
New-Jar "$dirB\diff-size.jar" @(@{Name="data.bin"; Text="Hello World!!`n"})
Write-Host "5/22 diff-size.jar"

# ── 6. diff-content (same size, diff CRC) ──
New-Jar "$dirA\diff-content.jar" @(@{Name="data.txt"; Text="ABCDEFGH"})
New-Jar "$dirB\diff-content.jar" @(@{Name="data.txt"; Text="ABCDEFGG"})
Write-Host "6/22 diff-content.jar"

# ── 7. added-file ──
New-Jar "$dirA\added-file.jar" @(
  @{Name="a.txt"; Text="File A`n"}
  @{Name="b.txt"; Text="File B`n"}
)
New-Jar "$dirB\added-file.jar" @(
  @{Name="a.txt"; Text="File A`n"}
  @{Name="b.txt"; Text="File B`n"}
  @{Name="c.txt"; Text="File C (extra)`n"}
)
Write-Host "7/22 added-file.jar"

# ── 8. removed-file ──
New-Jar "$dirA\removed-file.jar" @(
  @{Name="a.txt"; Text="File A`n"}
  @{Name="b.txt"; Text="File B`n"}
  @{Name="c.txt"; Text="File C`n"}
)
New-Jar "$dirB\removed-file.jar" @(
  @{Name="a.txt"; Text="File A`n"}
  @{Name="b.txt"; Text="File B`n"}
)
Write-Host "8/22 removed-file.jar"

# ── 9. mod-content (side-by-side diff) ──
New-Jar "$dirA\mod-content.jar" @(
  @{Name="greeting.txt"; Text="Hello`nWorld`nFoo`n"}
  @{Name="meta.txt"; Text="unchanged`n"}
)
New-Jar "$dirB\mod-content.jar" @(
  @{Name="greeting.txt"; Text="Hello`nUniverse`nFoo`n"}
  @{Name="meta.txt"; Text="unchanged`n"}
)
Write-Host "9/22 mod-content.jar"

# ── 10. shift-content (smart alignment) ──
New-Jar "$dirA\shift-content.jar" @(@{Name="poem.txt"; Text="A`nB`nC`nD`nE`n"})
New-Jar "$dirB\shift-content.jar" @(@{Name="poem.txt"; Text="B`nC`nD`nE`nF`n"})
Write-Host "10/22 shift-content.jar"

# ── 11. multi-mod (5 files, 3 modified) ──
$mma = @()
$mmb = @()
for ($i = 1; $i -le 5; $i++) {
  $mma += @{Name="file$i.txt"; Text="File $i version A`nLine 2`nLine 3`n"}
}
$mmb = @(
  @{Name="file1.txt"; Text="File 1 version B (modified)`nLine 2`nLine 3`n"}
  @{Name="file2.txt"; Text="File 2 version A`nLine 2`nLine 3`n"}
  @{Name="file3.txt"; Text="File 3 version B - changed`nLine 2 changed`nLine 3`n"}
  @{Name="file4.txt"; Text="File 4 version A`nLine 2`nLine 3`n"}
  @{Name="file5.txt"; Text="File 5 version B`nLine 2`nLine 3 modified`n"}
)
New-Jar "$dirA\multi-mod.jar" $mma
New-Jar "$dirB\multi-mod.jar" $mmb
Write-Host "11/22 multi-mod.jar"

# ── 12. deep-path ──
New-Jar "$dirA\deep-path.jar" @(@{Name="a/b/c/d/e/f.txt"; Text="version1`n"})
New-Jar "$dirB\deep-path.jar" @(@{Name="a/b/c/d/e/f.txt"; Text="version2`n"})
Write-Host "12/22 deep-path.jar"

# ── 13. special-chars ──
New-Jar "$dirA\special-chars.jar" @(@{Name="[test] (1) & special$.txt"; Text="Version A content`n"})
New-Jar "$dirB\special-chars.jar" @(@{Name="[test] (1) & special$.txt"; Text="Version B content (modified)`n"})
Write-Host "13/22 special-chars.jar"

# ── 14. binary-diff (.class with proper magic header, <512KB → tests null-byte detection) ──
$headerA = [byte[]]@(0xCA, 0xFE, 0xBA, 0xBE, 0x00, 0x00, 0x00, 0x34)  # Java class magic + version
$padA = [byte[]]@(0) * 50000   # null padding (~50KB)
$binA = $headerA + $padA
$headerB = [byte[]]@(0xCA, 0xFE, 0xBA, 0xBE, 0x00, 0x00, 0x00, 0x35)  # Different version
$padB = [byte[]]@(0) * 50000
$binB = $headerB + $padB
New-Jar "$dirA\binary-diff.jar" @(@{Name="classes/App.class"; Bytes=$binA})
New-Jar "$dirB\binary-diff.jar" @(@{Name="classes/App.class"; Bytes=$binB})
Write-Host "14/22 binary-diff.jar"

# ── 15. large-file (text ~120KB, under 512KB limit → triggers content diff) ──
$lines = @()
for ($i = 1; $i -le 2000; $i++) {
  $lines += "This is line $i of the large text file for testing purposes."
}
$textA = $lines -join "`n"
$textB = $textA -replace "line 1000 of the", "line 1000 **MODIFIED** of the"
New-Jar "$dirA\large-file.jar" @(@{Name="bigdata.txt"; Text=$textA})
New-Jar "$dirB\large-file.jar" @(@{Name="bigdata.txt"; Text=$textB})
Write-Host "15/22 large-file.jar"

# ── 16. zero-byte ──
$zf = @()
for ($i = 1; $i -le 5; $i++) { $zf += @{Name="empty$i.txt"; Text=""} }
New-Jar "$dirA\zero-byte.jar" $zf
New-Jar "$dirB\zero-byte.jar" $zf
Write-Host "16/22 zero-byte.jar"

# ── 17. mixed (add/remove/modify/same) ──
New-Jar "$dirA\mixed.jar" @(
  @{Name="only-a.txt"; Text="Only in A`n"}
  @{Name="both-same.txt"; Text="Same in both`n"}
  @{Name="modified-a.txt"; Text="A version of this file`n"}
)
New-Jar "$dirB\mixed.jar" @(
  @{Name="both-same.txt"; Text="Same in both`n"}
  @{Name="modified-a.txt"; Text="B version of this file (changed)`n"}
  @{Name="only-b.txt"; Text="Only in B`n"}
)
Write-Host "17/22 mixed.jar"

# ── 18. same-lines-diff-order ──
New-Jar "$dirA\same-lines-diff-order.jar" @(@{Name="lines.txt"; Text="line1`nline2`nline3`nline4`nline5`n"})
New-Jar "$dirB\same-lines-diff-order.jar" @(@{Name="lines.txt"; Text="line5`nline4`nline3`nline2`nline1`n"})
Write-Host "18/22 same-lines-diff-order.jar"

# ── 19. only-a ──
New-Jar "$dirA\only-a.jar" @(@{Name="only.txt"; Text="This jar is only in A`n"})
Write-Host "19/22 only-a.jar"

# ── 20. only-b ──
New-Jar "$dirB\only-b.jar" @(@{Name="only.txt"; Text="This jar is only in B`n"})
Write-Host "20/22 only-b.jar"

# ── 21. multi-loc (same jar, diff subfolder) ──
New-Jar "$dirA\sub\multi-loc.jar" @(@{Name="common.txt"; Text="Same content, different location`n"})
New-Jar "$dirB\multi-loc.jar" @(@{Name="common.txt"; Text="Same content, different location`n"})
Write-Host "21/22 multi-loc.jar"

# ── 22. lib-common (same jar, diff subfolder depth) ──
New-Jar "$dirA\lib\sub\lib-common.jar" @(@{Name="data.txt"; Text="lib common`n"})
New-Jar "$dirB\lib\lib-common.jar" @(@{Name="data.txt"; Text="lib common`n"})
Write-Host "22/22 lib-common.jar"

Write-Host "`n=== All done ==="
Get-ChildItem $dirA -Recurse *.jar | ForEach-Object { Write-Host "A: $($_.Name) [$($_.Length) bytes]" }
Get-ChildItem $dirB -Recurse *.jar | ForEach-Object { Write-Host "B: $($_.Name) [$($_.Length) bytes]" }
