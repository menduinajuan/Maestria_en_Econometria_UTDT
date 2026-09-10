"""Arma la lista final de criptomonedas para el panel de la tesis.

Combina dos listas curadas A MANO (no se generan por codigo, ver motivo
de cada una abajo):

1. Mayores actuales: se eligieron inspeccionando una vez el top 80 por
   market_cap_rank de la API publica de CoinGecko (/coins/markets). No se
   filtra por codigo porque el top de CoinGecko en 2026 esta contaminado
   de stablecoins, tokens de oro/gold-backed y fondos tokenizados (RWA:
   BlackRock BUIDL, Janus Henderson, Superstate, etc.) que no son
   criptomonedas especulativas y no tienen dinamica de burbuja -- una
   blocklist por id no escala porque aparecen productos nuevos todo el
   tiempo. Si el ranking de CoinGecko cambia, esta lista NO se actualiza
   sola: hay que revisarla a mano de nuevo.

2. Colapsos historicos documentados: monedas que fueron grandes y
   colapsaron (por lo tanto casi seguro fuera del top actual), incluidas
   a mano con su precio/fecha de ATH verificados por busqueda web
   (no por API, que en el free tier no da historico >365 dias). Sirven
   para que el panel no sufra de survivorship bias.

Para cada moneda del universo final se verifica disponibilidad real de
datos en Yahoo Finance (la fuente que usa download_data.py), reportando
ticker, rango de fechas y cantidad de velas disponibles.
"""

import json
import urllib.request

import pandas as pd
import yfinance as yf

OUTPUT_PATH = "../data/universe/coin_universe_final.csv"
COINGECKO_MARKETS_URL = "https://api.coingecko.com/api/v3/coins/markets"

# Mayores actuales, curados a mano desde el top 80 de /coins/markets de
# CoinGecko (snapshot tomado el 2026-08-11, ver METODOLOGIA.md; el ranking
# cambia con el tiempo asi que esta lista no reproduce una consulta futura
# a la API, es fija). Excluye stablecoins, oro tokenizado, fondos RWA y
# tokens de exchange poco relevantes para el fenomeno de burbuja especulativa.
CURRENT_MAJORS = [
    # (symbol, coingecko_id, yahoo_ticker)
    ("BTC", "bitcoin", "BTC-USD"),
    ("ETH", "ethereum", "ETH-USD"),
    ("BNB", "binancecoin", "BNB-USD"),
    ("XRP", "ripple", "XRP-USD"),
    ("SOL", "solana", "SOL-USD"),
    ("TRX", "tron", "TRX-USD"),
    ("DOGE", "dogecoin", "DOGE-USD"),
    ("ZEC", "zcash", "ZEC-USD"),
    ("XMR", "monero", "XMR-USD"),
    ("ADA", "cardano", "ADA-USD"),
    ("LINK", "chainlink", "LINK-USD"),
    ("XLM", "stellar", "XLM-USD"),
    ("BCH", "bitcoin-cash", "BCH-USD"),
    ("TON", "the-open-network", "TON-USD"),
    ("LTC", "litecoin", "LTC-USD"),
    ("HBAR", "hedera-hashgraph", "HBAR-USD"),
    ("SUI", "sui", "SUI20947-USD"),
    ("AVAX", "avalanche-2", "AVAX-USD"),
    ("SHIB", "shiba-inu", "SHIB-USD"),
    ("UNI", "uniswap", "UNI7083-USD"),
    ("DOT", "polkadot", "DOT-USD"),
    ("ICP", "internet-computer", "ICP-USD"),
    ("NEAR", "near", "NEAR-USD"),
    ("ETC", "ethereum-classic", "ETC-USD"),
    ("ALGO", "algorand", "ALGO-USD"),
    ("ATOM", "cosmos", "ATOM-USD"),
]

# Colapsos historicos documentados (precio/fecha ATH via busqueda web,
# citas en el mensaje al usuario). Se marcan aparte con su motivo.
HISTORIC_COLLAPSES = [
    # (symbol, coingecko_id, yahoo_ticker, ath_usd, ath_date, motivo)
    ("LUNA1", "terra-luna", "LUNA1-USD", 119.18, "2022-04-05",
     "Terra/LUNA Classic: colapso de UST y LUNA, mayo 2022"),
    ("FTT", "ftx-token", "FTT-USD", 84.70, "2021-09-09",
     "FTX Token: colapso de FTX, noviembre 2022"),
    ("CEL", "celsius-degree-token", "CEL-USD", 8.02, "2021-06-03",
     "Celsius Network: pausa de retiros y quiebra, junio 2022"),
    ("XEM", "nem", "XEM-USD", 2.09, "2018-01-04",
     "NEM: top 5 por market cap en el pico de la mania ICO 2017-2018"),
    ("BCC", "bitconnect", "BCC-USD", 471.0, "2017-12-18",
     "BitConnect: esquema Ponzi, colapso enero 2018 (caso clasico de burbuja)"),
]


def fetch_ath_by_id(coingecko_ids: list[str]) -> dict:
    ids_param = ",".join(coingecko_ids)
    url = f"{COINGECKO_MARKETS_URL}?vs_currency=usd&ids={ids_param}&per_page={len(coingecko_ids)}"
    req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
    with urllib.request.urlopen(req, timeout=20) as resp:
        entries = json.load(resp)
    return {
        e["id"]: {"ath_usd": e.get("ath"), "ath_date": (e.get("ath_date") or "")[:10]}
        for e in entries
    }


def check_yahoo(ticker: str) -> dict:
    h = yf.Ticker(ticker).history(period="max", interval="1d")
    if h.empty:
        return {"yahoo_disponible": False, "yahoo_desde": None, "yahoo_hasta": None, "yahoo_velas": 0}
    return {
        "yahoo_disponible": True,
        "yahoo_desde": h.index.min().date().isoformat(),
        "yahoo_hasta": h.index.max().date().isoformat(),
        "yahoo_velas": len(h),
    }


def main() -> None:
    rows = []

    print("Bajando ATH real de los mayores actuales (CoinGecko, 1 request)...")
    ath_by_id = fetch_ath_by_id([cg_id for _, cg_id, _ in CURRENT_MAJORS])

    for symbol, cg_id, yahoo_ticker in CURRENT_MAJORS:
        ath = ath_by_id.get(cg_id, {})
        row = {
            "symbol": symbol,
            "coingecko_id": cg_id,
            "yahoo_ticker": yahoo_ticker,
            "categoria": "mayor_actual",
            "motivo": "top por market cap actual (CoinGecko)",
            "ath_usd_documentado": ath.get("ath_usd"),
            "ath_date_documentado": ath.get("ath_date"),
            "fuente": "CoinGecko /coins/markets, snapshot 2026-08-11",
        }
        row.update(check_yahoo(yahoo_ticker))
        rows.append(row)
        print(f"{symbol}: {'OK' if row['yahoo_disponible'] else 'SIN DATOS'} en Yahoo")

    for symbol, cg_id, yahoo_ticker, ath_usd, ath_date, motivo in HISTORIC_COLLAPSES:
        row = {
            "symbol": symbol,
            "coingecko_id": cg_id,
            "yahoo_ticker": yahoo_ticker,
            "categoria": "colapso_historico",
            "motivo": motivo,
            "ath_usd_documentado": ath_usd,
            "ath_date_documentado": ath_date,
            "fuente": "busqueda web (ver METODOLOGIA.md)",
        }
        row.update(check_yahoo(yahoo_ticker))
        rows.append(row)
        print(f"{symbol}: {'OK' if row['yahoo_disponible'] else 'SIN DATOS'} en Yahoo")

    df = pd.DataFrame(rows)
    df.to_csv(OUTPUT_PATH, index=False)
    print(f"\nUniverso final ({len(df)} monedas, {df['yahoo_disponible'].sum()} con datos en Yahoo) -> {OUTPUT_PATH}")


if __name__ == "__main__":
    main()
