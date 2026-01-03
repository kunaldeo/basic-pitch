#!/usr/bin/env python3
"""Thin wrapper to make the Basic Pitch CLI self-contained in a bundle."""
from __future__ import annotations

from basic_pitch.predict import main as basic_pitch_main


def main() -> None:
    basic_pitch_main()


if __name__ == "__main__":
    main()
