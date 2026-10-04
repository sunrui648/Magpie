#Requires -Version 7.0
$ErrorActionPreference = 'Stop'
Set-Location (Split-Path $PSScriptRoot -Parent)
if ($env:GITHUB_ACTIONS -ne 'true') { throw 'Run this script on GitHub Actions, not the user computer.' }
$deps = Join-Path $env:RUNNER_TEMP 'magpie-native-deps'
New-Item -ItemType Directory -Path $deps -Force | Out-Null
function Clone-Sdk($url, $folder, $revision) {
    git clone --depth 1 $url $folder
    if ($LASTEXITCODE) { throw "SDK clone failed: $url" }
    if ($revision) {
        git -C $folder fetch --depth 1 origin $revision
        if ($LASTEXITCODE) { throw 'SDK revision fetch failed' }
        git -C $folder checkout --detach FETCH_HEAD
        if ($LASTEXITCODE) { throw 'SDK checkout failed' }
    }
    git -C $folder rev-parse HEAD
}
$xess = Join-Path $deps 'xess'
$vfx = Join-Path $deps 'vfx'
Clone-Sdk 'https://github.com/intel/xess.git' $xess '207b703ad215da5b86dde04819a16277a96980aa'
Clone-Sdk 'https://github.com/NVIDIA-Maxine/Maxine-VFX-SDK.git' $vfx ''
$originalZip = Join-Path $deps 'original.zip'
Invoke-WebRequest 'https://github.com/SAOG0721/Magpie/releases/download/v0.6.9-experimental/Magpie-Experimental-x64.zip' -OutFile $originalZip
if ((Get-FileHash $originalZip -Algorithm SHA256).Hash -ine 'f4233fc34b26db6f9bcb5e8fb4a527266806a949b35f5d8feb3c0e53058dfead') { throw 'Original package checksum mismatch' }
Expand-Archive -LiteralPath $originalZip -DestinationPath (Join-Path $deps 'original')
$original = (Get-ChildItem (Join-Path $deps 'original') -Filter Magpie.exe -Recurse | Select-Object -First 1).Directory.FullName
if (!$original) { throw 'Original executable missing' }
$licenses = Join-Path $original 'NVIDIA-VFX-Licenses'
# This diagnostic build retains XeSS SR/FG and RTX Video. Other native AI backends
# are deliberately disabled and are recorded as disabled in its manifest.
@"
<Project xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
 <PropertyGroup>
  <EnableXeSSZeroMV>true</EnableXeSSZeroMV>
  <EnableXeSSFrameGeneration>true</EnableXeSSFrameGeneration>
  <XeSSSdkDir>$xess</XeSSSdkDir>
  <EnableRTXVideoDenoise>true</EnableRTXVideoDenoise>
  <VFXSdkDir>$vfx</VFXSdkDir>
  <VFXRuntimeDir>$original</VFXRuntimeDir>
  <VFXLicenseDir>$licenses</VFXLicenseDir>
 </PropertyGroup>
</Project>
"@ | Set-Content src/BuildOptions.props.user -Encoding utf8
python scripts/publish.py --compiler=MSVC --platform=x64 --version-major=0 --version-minor=6 --version-patch=9 --version-string=0.6.9-native-cursor-test
if ($LASTEXITCODE) { throw 'Magpie compilation failed' }
$package = Join-Path $PWD 'publish/x64'
# Preserve only runtime libraries and their notices; never replace rebuilt app files.
foreach ($file in Get-ChildItem $original -File) {
    if ($file.Name -match '^(nvngx_|nvVideo|nvCV|NVVideo|NVCV)' -or $file.Name -eq 'Magpie.RtxVideo.dll' -or $file.Name -match '^NVIDIA.*(LICENSE|THIRD)') {
        if (!(Test-Path (Join-Path $package $file.Name))) { Copy-Item $file.FullName $package }
    }
}
Copy-Item scripts/Start-NativeCursor.cmd $package
Copy-Item docs/NATIVE-CURSOR-TEST.md $package
$manifest = [ordered]@{
    version='0.6.9-native-cursor-test'; baseCommit='27c5df91177a29b33be612e98274169f3d2fca49'; commit=$env:GITHUB_SHA
    enabledBackends=@('XeSS SR','XeSS FG','RTX Video')
    disabledBackends=@('DLSS SR','DLSS FG','DLSSNR','FSR2','FSR3','AMD Optical Flow','NVIDIA Optical Flow')
    xeSSCommit=(git -C $xess rev-parse HEAD); vfxCommit=(git -C $vfx rev-parse HEAD)
    files=@(Get-ChildItem $package -Recurse -File | ForEach-Object { @{path=[IO.Path]::GetRelativePath($package,$_.FullName); sha256=(Get-FileHash $_.FullName -Algorithm SHA256).Hash} })
}
$manifest | ConvertTo-Json -Depth 6 | Set-Content (Join-Path $package 'native-cursor-build-manifest.json') -Encoding utf8
foreach ($required in @('Magpie.exe','libxess_fg.dll','libxell.dll')) {
    if (!(Test-Path (Join-Path $package $required))) { throw "Missing build output: $required" }
}
