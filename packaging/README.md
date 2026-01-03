# Basic Pitch portable bundle build

This folder builds a standalone Basic Pitch CLI bundle that you can ship with a
C++ desktop app. The bundle includes:

- Basic Pitch + dependencies (PyInstaller)
- Default model weights (icassp_2022)

The build is per-OS. Run the matching script on each OS you want to ship.

## Prereqs

- Python 3.8-3.11
- `uv` for creating a pinned Python venv (unless you use an existing venv)
- A C/C++ toolchain suitable for PyInstaller on that OS

## Build (Linux)

```
./packaging/build_linux.sh
```

Use an existing project venv (e.g. `.venv`) instead of creating a new one:

```
USE_EXISTING_VENV=1 VENV_DIR=.venv ./packaging/build_linux.sh
```

## Build (macOS)

```
./packaging/build_macos.sh
```

Use an existing project venv (e.g. `.venv`) instead of creating a new one:

```
USE_EXISTING_VENV=1 VENV_DIR=.venv ./packaging/build_macos.sh
```

## Build (Windows PowerShell)

```
./packaging/build_windows.ps1
```

Use an existing project venv (e.g. `.venv`) instead of creating a new one:

```
$env:USE_EXISTING_VENV = "1"
$env:VENV_DIR = ".venv"
.\packaging\build_windows.ps1
```

## Controlling Python version

By default the scripts create a venv pinned to Python 3.10.14 via `uv`. You can
override that with:

```
PYTHON_VERSION=3.9.18 ./packaging/build_linux.sh
```

## Output

PyInstaller produces `dist/basic-pitch/` with an executable named `basic-pitch`
(or `basic-pitch.exe` on Windows). Ship that folder with your app.

## Usage (from C++)

```
basic-pitch <output-dir> <input-audio-path>
```

Example:

```
basic-pitch tip-midi tip/vocals.wav
```

## Notes

- The bundle includes the `icassp_2022` saved models under `basic_pitch/saved_models`.
- You can override the model path with `--model-path` if needed.
- The build pins NumPy to `1.25.2` to avoid runtime ABI issues with TFLite wheels.
