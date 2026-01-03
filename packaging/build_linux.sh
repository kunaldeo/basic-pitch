#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

PYTHON=${PYTHON:-python3}
if [[ -z "${VENV_DIR:-}" ]]; then
  if [[ -d ".venv" ]]; then
    VENV_DIR=".venv"
  else
    VENV_DIR=".venv-build"
  fi
fi
USE_EXISTING_VENV=${USE_EXISTING_VENV:-0}
PYTHON_VERSION=${PYTHON_VERSION:-3.10.14}
PYINSTALLER_OPTS=${PYINSTALLER_OPTS:-"--clean --noconfirm"}

if [[ "$USE_EXISTING_VENV" == "1" ]]; then
  if [[ ! -x "$VENV_DIR/bin/python" ]]; then
    echo "Venv not found at $VENV_DIR. Set VENV_DIR or create it first."
    exit 1
  fi
else
  if ! command -v uv >/dev/null 2>&1; then
    echo "uv is required to create a pinned Python ${PYTHON_VERSION} venv."
    echo "Install uv, or set USE_EXISTING_VENV=1 to use an existing venv."
    exit 1
  fi
  uv venv --clear --python "${PYTHON_VERSION}" "$VENV_DIR"
fi

PYTHON="$VENV_DIR/bin/python"
# shellcheck disable=SC1090
source "$VENV_DIR/bin/activate"

if ! python -m pip --version >/dev/null 2>&1; then
  python -m ensurepip --upgrade
fi

python -m pip install --upgrade pip
python -m pip install -c "$ROOT_DIR/packaging/constraints.txt" -r "$ROOT_DIR/packaging/requirements_packaging.txt"
python -m pip install -c "$ROOT_DIR/packaging/constraints.txt" "$ROOT_DIR"

export BASIC_PITCH_PROJECT_ROOT="$ROOT_DIR"
pyinstaller "$ROOT_DIR/packaging/basic_pitch_cli.spec" ${PYINSTALLER_OPTS}

printf '\nBuilt CLI at dist/basic-pitch\n'
