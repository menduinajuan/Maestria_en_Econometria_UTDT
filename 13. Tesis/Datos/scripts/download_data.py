"""Descarga velas OHLCV desde Yahoo Finance para varios intervalos.

El universo de monedas a descargar no esta hardcodeado: se lee de
data/universe/coin_universe_final.csv (generado por select_universe.py),
tomando solo las filas marcadas con yahoo_disponible=True.
"""

import os

import pandas as pd
import yfinance as yf

UNIVERSE_PATH = "../data/universe/coin_universe_final.csv"
START_DATE = "2016-01-01"
END_DATE = "2026-01-01"  # exclusivo: incluye hasta 2025-12-31
OUTPUT_ROOT = "../data/historicalCandles"


def load_universe() -> pd.DataFrame:
    df = pd.read_csv(UNIVERSE_PATH)
    return df[df["yahoo_disponible"]]


def fetch(ticker: str, interval: str, start: str = START_DATE, end: str = END_DATE) -> pd.DataFrame:
    df = yf.Ticker(ticker).history(start=start, end=end, interval=interval, auto_adjust=False)
    df.index.name = "Date"
    return df.drop(columns=["Adj Close", "Dividends", "Stock Splits"], errors="ignore")


def save(df: pd.DataFrame, ticker: str, symbol: str, folder: str) -> None:
    out_dir = f"{OUTPUT_ROOT}/{folder}"
    os.makedirs(out_dir, exist_ok=True)
    out_path = f"{out_dir}/{symbol.lower()}_{folder}.csv"
    df.to_csv(out_path)
    print(f"{ticker} [{folder}]: {len(df)} velas, {df.index.min().date()} a {df.index.max().date()} -> {out_path}")


def main() -> None:
    universe = load_universe()
    for _, row in universe.iterrows():
        ticker, symbol = row["yahoo_ticker"], row["symbol"]
        save(fetch(ticker, "1d"), ticker, symbol, "1d")
        save(fetch(ticker, "1wk"), ticker, symbol, "1w")


if __name__ == "__main__":
    main()
