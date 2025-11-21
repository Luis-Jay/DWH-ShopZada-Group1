"""
Utility helpers that load raw ShopZada CSV files into Postgres staging tables.

The Airflow DAG `workflows/airflow_dags/shopzada_pipeline_dag.py` expects a
`ShopZadaIngestion` class exposing a `run_all_ingestions(data_root)` method.
This module implements that contract so orchestration can simply instantiate the
class and call `run_all_ingestions`.
"""

from __future__ import annotations

import csv
import logging
import os
from dataclasses import dataclass, field
from pathlib import Path
from typing import Dict, Iterable, List, Optional

try:  # psycopg2 is the lightest dependency for COPY performance
    import psycopg2
except ImportError:  # pragma: no cover - handled at runtime
    psycopg2 = None  # type: ignore

# Optional per-project overrides. config.py can define DB_CONFIG or INGESTION_JOBS.
try:  # pragma: no cover - best-effort import
    from . import config as ingest_config  # type: ignore
except ImportError:  # pragma: no cover
    ingest_config = None  # type: ignore

RAW_DATA_ROOT = Path(os.environ.get("SHOPZADA_DATA_ROOT", "sql/data/raw"))


@dataclass
class IngestionJob:
    """Describes how to load a single CSV file into Postgres."""

    name: str
    filename: str
    target_table: str
    columns: List[str]
    delimiter: str = ","
    has_header: bool = True
    extra_copy_options: Dict[str, str] = field(default_factory=dict)

    @property
    def source_path(self) -> Path:
        return RAW_DATA_ROOT / self.filename


DEFAULT_JOBS: List[IngestionJob] = [
    IngestionJob(
        name="customers",
        filename="customers.csv",
        target_table="staging.customers_raw",
        columns=[
            "customer_id",
            "first_name",
            "last_name",
            "email",
            "phone",
            "signup_date",
            "country",
        ],
    ),
    IngestionJob(
        name="products",
        filename="products.csv",
        target_table="staging.products_raw",
        columns=[
            "product_id",
            "sku",
            "name",
            "category",
            "merchant_id",
            "price",
        ],
    ),
    IngestionJob(
        name="merchants",
        filename="merchants.csv",
        target_table="staging.merchants_raw",
        columns=["merchant_id", "name", "vertical", "country"],
    ),
    IngestionJob(
        name="campaigns",
        filename="campaigns.csv",
        target_table="staging.campaigns_raw",
        columns=[
            "campaign_id",
            "name",
            "start_date",
            "end_date",
            "budget",
        ],
    ),
    IngestionJob(
        name="orders",
        filename="orders.csv",
        target_table="staging.orders_raw",
        columns=[
            "order_id",
            "order_date",
            "customer_id",
            "product_id",
            "quantity",
            "unit_price",
            "discount",
            "campaign_id",
        ],
    ),
]


def _from_config(name: str, default):
    if ingest_config and hasattr(ingest_config, name):
        return getattr(ingest_config, name)
    return default


class ShopZadaIngestion:
    """
    Handles loading raw CSVs into staging tables.

    Example:
        ingestion = ShopZadaIngestion()
        ingestion.run_all_ingestions()
    """

    def __init__(self, jobs: Optional[Iterable[IngestionJob]] = None, db_config: Optional[Dict[str, str]] = None):
        if psycopg2 is None:  # pragma: no cover
            raise RuntimeError(
                "psycopg2 is required for ingestion. Install it via `pip install psycopg2-binary`."
            )
        self.jobs = list(_from_config("INGESTION_JOBS", jobs) or jobs or DEFAULT_JOBS)
        self.db_config = _from_config("DB_CONFIG", db_config) or db_config or self._load_db_config_from_env()
        logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")

    @staticmethod
    def _load_db_config_from_env() -> Dict[str, str]:
        return {
            "host": os.environ.get("SHOPZADA_DB_HOST", "localhost"),
            "port": os.environ.get("SHOPZADA_DB_PORT", "5432"),
            "dbname": os.environ.get("SHOPZADA_DB_NAME", "shopzada"),
            "user": os.environ.get("SHOPZADA_DB_USER", "postgres"),
            "password": os.environ.get("SHOPZADA_DB_PASSWORD", "postgres"),
        }

    def run_all_ingestions(self, data_root: Optional[str] = None) -> Dict[str, str]:
        """
        Executes every configured ingestion job.

        Args:
            data_root: Optional override for the raw data directory.

        Returns:
            Mapping of job name to status string.
        """
        if data_root:
            global RAW_DATA_ROOT
            RAW_DATA_ROOT = Path(data_root)

        summary: Dict[str, str] = {}
        for job in self.jobs:
            try:
                inserted = self._ingest_single_job(job)
                summary[job.name] = f"loaded {inserted} rows"
                logging.info("Job %s finished successfully (%s rows)", job.name, inserted)
            except FileNotFoundError as missing_file:
                summary[job.name] = f"missing source: {missing_file}"
                logging.warning("Skipping %s: %s", job.name, missing_file)
            except Exception as exc:  # pragma: no cover - defensive logging
                summary[job.name] = f"error: {exc}"
                logging.exception("Job %s failed", job.name)
        return summary

    def _ingest_single_job(self, job: IngestionJob) -> int:
        path = job.source_path
        if not path.exists():
            raise FileNotFoundError(path)

        with psycopg2.connect(**self.db_config) as conn, conn.cursor() as cur:  # type: ignore[arg-type]
            copy_sql = self._build_copy_sql(job)
            with path.open("r", encoding="utf-8", newline="") as csv_file:
                cur.copy_expert(copy_sql, csv_file)
        # Estimate row count by counting lines (minus header if present)
        with path.open("r", encoding="utf-8") as csv_file:
            row_count = sum(1 for _ in csv_file)
            if job.has_header:
                row_count = max(row_count - 1, 0)
        return row_count

    @staticmethod
    def _quote_identifier(identifier: str) -> str:
        schema, _, table = identifier.partition(".")
        if table:
            return f'"{schema}"."{table}"'
        return f'"{identifier}"'

    def _build_copy_sql(self, job: IngestionJob) -> str:
        columns = ", ".join(f'"{col}"' for col in job.columns)
        options = [f"DELIMITER '{job.delimiter}'", "FORMAT csv"]
        if job.has_header:
            options.append("HEADER")
        for key, value in job.extra_copy_options.items():
            options.append(f"{key} {value}")
        options_clause = " ".join(options)
        return f"COPY {self._quote_identifier(job.target_table)} ({columns}) FROM STDIN WITH {options_clause};"


__all__ = ["ShopZadaIngestion", "IngestionJob"]

