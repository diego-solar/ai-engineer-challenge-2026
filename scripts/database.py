"""Leer consultas SQL y ejecutar la extraccion, escritura y resumen."""

from contextlib import closing
from pathlib import Path
import sqlite3

import pandas as pd


def read_sql(sql_path: Path) -> str:
    """Leer una consulta desde un archivo del repositorio."""
    return sql_path.read_text(encoding="utf-8-sig")


def extract_reviews(db_path: Path, query: str) -> pd.DataFrame:
    """Ejecutar la extraccion en modo solo lectura y validar el resultado."""
    db_uri = f"{db_path.resolve().as_uri()}?mode=ro"

    with closing(sqlite3.connect(db_uri, uri=True)) as conn:
        reviews_df = pd.read_sql_query(query, conn)

    if reviews_df.empty:
        raise ValueError("Part 1 returned no reviews. Check extraction first.")

    assert reviews_df["review_id"].notna().all(), "Missing review IDs."
    assert reviews_df["review_id"].is_unique, "Duplicate review IDs."
    assert reviews_df["published_date"].between(
        "2023-05-01", "2023-10-31"
    ).all(), "Reviews outside the required date interval."
    assert reviews_df["seat_type"].isin(
        ["Economy Class", "Premium Economy"]
    ).all(), "Unexpected seat type."
    assert reviews_df["overall_rating"].notna().all()
    assert reviews_df["overall_rating"].le(2).all()
    assert reviews_df["value_for_money"].notna().all()
    assert reviews_df["value_for_money"].le(2).all()
    assert reviews_df["published_date"].is_monotonic_decreasing

    return reviews_df


def save_classifications(
    db_path: Path,
    records: list[tuple[int, str, str]],
    create_sql: str,
    save_sql: str,
) -> None:
    """Guardar resultados validados en una transaccion corta."""
    db_uri = f"{db_path.resolve().as_uri()}?mode=rw"

    with closing(sqlite3.connect(db_uri, uri=True)) as conn:
        conn.execute("PRAGMA foreign_keys = ON")

        with conn:
            conn.execute(create_sql)
            conn.executemany(save_sql, records)


def summarize_classifications(
    db_path: Path,
    summary_sql: str,
    current_ids: list[int],
) -> pd.DataFrame:
    """Ejecutar el resumen SQL con los IDs como parametros."""
    db_uri = f"{db_path.resolve().as_uri()}?mode=ro"

    with closing(sqlite3.connect(db_uri, uri=True)) as conn:
        summary_df = pd.read_sql_query(summary_sql, conn, params=current_ids)

    assert summary_df["review_count"].sum() == len(current_ids), (
        "The summary does not cover all selected reviews."
    )
    return summary_df