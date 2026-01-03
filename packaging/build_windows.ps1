$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$RootDir = Resolve-Path (Join-Path $ScriptDir "..")

$Python = $env:PYTHON
if (-not $Python) { $Python = "python" }

$VenvDir = $env:VENV_DIR
if (-not $VenvDir) {
  if (Test-Path ".venv") { $VenvDir = ".venv" } else { $VenvDir = ".venv-build" }
}

$UseExistingVenv = $env:USE_EXISTING_VENV
if (-not $UseExistingVenv) { $UseExistingVenv = "0" }

$PythonVersion = $env:PYTHON_VERSION
if (-not $PythonVersion) { $PythonVersion = "3.10.14" }

$PyInstallerOpts = $env:PYINSTALLER_OPTS
if (-not $PyInstallerOpts) { $PyInstallerOpts = "--clean --noconfirm" }

if ($UseExistingVenv -eq "1") {
  $VenvPython = Join-Path $VenvDir "Scripts\python.exe"
  if (-not (Test-Path $VenvPython)) {
    Write-Host "Venv not found at $VenvDir. Set VENV_DIR or create it first."
    exit 1
  }
  $Python = $VenvPython
} else {
  if (-not (Get-Command uv -ErrorAction SilentlyContinue)) {
    Write-Host "uv is required to create a pinned Python $PythonVersion venv."
    Write-Host "Install uv, or set USE_EXISTING_VENV=1 to use an existing venv."
    exit 1
  }
  & uv venv --clear --python $PythonVersion $VenvDir
  $Python = Join-Path $VenvDir "Scripts\python.exe"
}

& "$VenvDir\Scripts\Activate.ps1"

python -m pip --version | Out-Null
if ($LASTEXITCODE -ne 0) {
  python -m ensurepip --upgrade
}

python -m pip install --upgrade pip
python -m pip install -c (Join-Path $RootDir "packaging\constraints.txt") -r (Join-Path $RootDir "packaging\requirements_packaging.txt")
python -m pip install -c (Join-Path $RootDir "packaging\constraints.txt") $RootDir

$env:BASIC_PITCH_PROJECT_ROOT = $RootDir
pyinstaller (Join-Path $RootDir "packaging\basic_pitch_cli.spec") $PyInstallerOpts

Write-Host "`nBuilt CLI at dist\basic-pitch`n"
