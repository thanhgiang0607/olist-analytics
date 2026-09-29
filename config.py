"""Shared paths for the pipeline, resolved from the repo root.

Override with environment variables when the data lives elsewhere:
    DUCKDB_PATH   – DuckDB file built by dbt (default: <repo>/dev.duckdb)
    OLIST_RAW_DIR – folder with the raw Olist CSVs (default: <repo>/data/raw)
"""
import os
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parent

DUCKDB_PATH = Path(os.environ.get("DUCKDB_PATH", PROJECT_ROOT / "dev.duckdb"))
RAW_DATA_DIR = Path(os.environ.get("OLIST_RAW_DIR", PROJECT_ROOT / "data" / "raw"))


def raw_csv(name: str) -> str:
    """Path to a raw Olist CSV, as a string usable inside DuckDB SQL."""
    return (RAW_DATA_DIR / name).as_posix()
