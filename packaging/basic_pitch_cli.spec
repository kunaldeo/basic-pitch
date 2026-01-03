# -*- mode: python ; coding: utf-8 -*-
from pathlib import Path
import os

from PyInstaller.utils.hooks import collect_all

block_cipher = None

project_root = Path(os.environ.get("BASIC_PITCH_PROJECT_ROOT", os.getcwd())).resolve()

hiddenimports = []
_datas = []
_binaries = []


def _collect(pkg_name: str):
    try:
        return collect_all(pkg_name)
    except Exception:
        return [], [], []


for pkg in [
    "basic_pitch",
    "librosa",
    "pretty_midi",
    "resampy",
    "mir_eval",
    "numpy",
    "scipy",
    "sklearn",
    "soundfile",
    "audioread",
    "numba",
    "llvmlite",
]:
    datas, binaries, imports = _collect(pkg)
    _datas += datas
    _binaries += binaries
    hiddenimports += imports

for pkg in [
    "tflite_runtime",
    "tensorflow",
    "onnxruntime",
    "coremltools",
]:
    datas, binaries, imports = _collect(pkg)
    _datas += datas
    _binaries += binaries
    hiddenimports += imports

saved_models = project_root / "basic_pitch" / "saved_models"
if saved_models.exists():
    _datas.append((str(saved_models), "basic_pitch/saved_models"))

entry_script = project_root / "packaging" / "basic_pitch_cli.py"

analysis = Analysis(
    [str(entry_script)],
    pathex=[str(project_root)],
    binaries=_binaries,
    datas=_datas,
    hiddenimports=hiddenimports,
    hookspath=[],
    runtime_hooks=[],
    excludes=[],
    win_no_prefer_redirects=False,
    win_private_assemblies=False,
    cipher=block_cipher,
    noarchive=False,
)

pyz = PYZ(analysis.pure, analysis.zipped_data, cipher=block_cipher)

exe = EXE(
    pyz,
    analysis.scripts,
    analysis.binaries,
    analysis.zipfiles,
    analysis.datas,
    [],
    name="basic-pitch",
    debug=False,
    bootloader_ignore_signals=False,
    strip=False,
    upx=True,
    upx_exclude=[],
    runtime_tmpdir=None,
    console=True,
    disable_windowed_traceback=False,
    target_arch=None,
    codesign_identity=None,
    entitlements_file=None,
)
