# Selección del universo de criptomonedas

Documento de referencia para la sección de metodología de la tesis: explica cómo se llegó a las 30 criptomonedas de `coin_universe_final.csv` y por qué se descartaron otros caminos.

## Objetivo

Armar un panel de 25-30 criptomonedas que no sufra de **survivorship bias**: si se eligen solo las monedas más grandes *hoy*, el panel queda sesgado hacia "ganadoras" y pierde justo los casos más informativos para detectar burbujas — monedas que fueron grandes, formaron una burbuja y colapsaron.

## Intentos descartados (y por qué)

El plan original era rankear objetivamente por **capitalización de mercado histórica máxima (ATH)** de cada moneda, usando una API, para que la selección fuera 100% reproducible por código. No se pudo lograr con fuentes gratuitas:

1. **Aproximar cap. histórica como `precio_ATH × oferta_circulante_actual`** (CoinGecko `/coins/markets`, sin key): falla gravemente para monedas cuya oferta cambió mucho desde su pico. Ejemplo real encontrado: LUNA (Terra) emitió billones de tokens nuevos tras el colapso de mayo 2022 para paliar la crisis; multiplicar su precio ATH ($119,18) por la oferta *actual* (~5,5 billones de tokens) da una cap "histórica" de ~$658 billones de dólares, cuando la cifra real fue ~$40 mil millones. También distorsionaba tokens de baja liquidez con prints de precio ATH manipulados/erróneos.
2. **CoinGecko `/coins/{id}/history?date=...`** (market cap real en una fecha pasada, con API key Demo gratuita): el plan Demo **bloquea consultas de más de 365 días atrás** (error `10012`), justo el rango que importa para detectar burbujas de 2017-2018, 2021 y 2022.
3. **CoinPaprika** `/tickers/{id}/historical`: devuelve `402 Payment Required` en el tier gratuito.
4. **Yahoo Finance**: dan precio histórico, pero no oferta circulante histórica ni rankings pasados — no permite reconstruir cap. de mercado de años anteriores.

Conclusión: ninguna fuente gratuita da capitalización de mercado histórica confiable. No es una limitación de una API en particular, es una limitación real de los datos disponibles sin pagar (los planes pagos arrancan en ~$103/mes en CoinGecko).

## Método final (usado en `select_universe.py`)

Se combinaron dos listas **curadas a mano**, con su justificación documentada, en vez de un ranking 100% automático:

### 1. Mayores actuales (26 monedas)

Se inspeccionó una vez el top 80 de `/coins/markets` de CoinGecko (market cap actual, fuente confiable y sin restricciones) y se filtraron a mano las que no son criptomonedas especulativas: stablecoins, oro tokenizado (PAX Gold, Tether Gold) y fondos RWA tokenizados que aparecieron en el ranking 2026 (BlackRock BUIDL, Janus Henderson, Superstate, Spiko, etc.). Una blocklist por id no es viable porque aparecen productos nuevos de este tipo constantemente.

**Limitación**: esta lista no se regenera sola si el ranking de CoinGecko cambia — para actualizarla hay que volver a inspeccionar el top y ajustar `CURRENT_MAJORS` en el script a mano.

### 2. Colapsos históricos documentados (4 monedas)

Se identificaron a mano episodios de burbuja/colapso ampliamente documentados en fuentes públicas (no vía API), verificando precio y fecha de ATH por búsqueda web:

| Symbol | Moneda | ATH (USD) | Fecha ATH | Colapso |
|---|---|---|---|---|
| LUNA1 | Terra (LUNA Classic) | $119,18 | 2022-04-05 | Depeg de UST y colapso de LUNA, mayo 2022 |
| FTT | FTX Token | $84,70 | 2021-09-09 | Quiebra de FTX, noviembre 2022 |
| CEL | Celsius Network | $8,02 | 2021-06-03 | Pausa de retiros y quiebra, junio 2022 |
| XEM | NEM | $2,09 | 2018-01-04 | Top 5 por market cap en el pico de la manía ICO 2017-2018 |

Se evaluó también **BitConnect** (esquema Ponzi, colapso enero 2018, cap. ~$2,5-2,6 mil millones según prensa de la época) pero se descartó del panel final: no tiene datos disponibles en Yahoo Finance (operaba mayormente fuera de exchanges reales, consistente con su naturaleza fraudulenta).

Candidatos adicionales de la era ICO 2017-2018 que se consideraron pero no se incluyeron (para no inflar el panel con casos muy similares a NEM, y porque varios tienen menor confianza en sus cifras históricas exactas): Verge (XVG), BitShares (BTS), Waves, Steem, NXT, MaidSafeCoin. Quedan como candidatos de reserva si se quisiera ampliar el panel más allá de 30.

### 3. Verificación de disponibilidad de datos

Para cada una de las 30 monedas se verificó (`select_universe.py`, columnas `yahoo_disponible`, `yahoo_desde`, `yahoo_hasta`, `yahoo_velas`) que el ticker exista en Yahoo Finance —la fuente real que usa `download_data.py`— y se registró el rango de fechas disponible. Esto también sirvió como filtro de calidad adicional: monedas de baja liquidez o con market cap manipulado en CoinGecko típicamente no tienen ticker en Yahoo.

## Resultado final

- **30 de 31 candidatas** tienen datos utilizables en Yahoo Finance (`coin_universe_final.csv`).
- Descartada del panel: **BitConnect** (sin datos en Yahoo).

### Limitaciones a tener en cuenta en el análisis

- **SUI** (`SUI20947-USD`): historia recién desde 2023-05-03 (la red es de ese año), panel desbalanceado respecto al resto.
- **LUNA1** (`LUNA1-USD`): Yahoo deja de trackearlo el 2022-10-09, unos meses después del colapso. Cubre el episodio de burbuja completo (boom 2021 + crash mayo 2022) pero no tiene cola posterior.
- Los tickers de Yahoo para algunas monedas llevan sufijo numérico por colisión de símbolo (`UNI7083-USD` para Uniswap, `SUI20947-USD` para Sui) — ver columna `yahoo_ticker` en el CSV, no asumir que el ticker es siempre `SYMBOL-USD`.
- Los precios de mercado no reflejan necesariamente actividad en un solo exchange "spot" puro; Yahoo agrega/deriva su propio precio de referencia.

## Reproducibilidad

Correr `python scripts/select_universe.py` desde `scripts/` regenera `coin_universe_final.csv`, re-verificando disponibilidad en Yahoo Finance en el momento de la corrida (útil para detectar si algún ticker fue discontinuado). Las listas `CURRENT_MAJORS` y `HISTORIC_COLLAPSES` en ese script son la fuente de verdad de *qué* monedas entran — cualquier cambio al universo se hace ahí, no en este documento.
