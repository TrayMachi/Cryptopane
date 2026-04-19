use std::time::Duration;

use anyhow::{Context, Result};
use reqwest::Client;
use serde::de::IgnoredAny;
use serde::Deserialize;

use crate::model::Kline;

const BINANCE_KLINES_URL: &str = "https://data-api.binance.vision/api/v3/klines";

#[derive(Debug, Deserialize)]
struct RawKline(
    IgnoredAny,
    IgnoredAny,
    IgnoredAny,
    IgnoredAny,
    String,
    IgnoredAny,
    IgnoredAny,
    IgnoredAny,
    IgnoredAny,
    IgnoredAny,
    IgnoredAny,
    IgnoredAny,
);

pub fn build_client() -> Result<Client> {
    Client::builder()
        .timeout(Duration::from_secs(8))
        .user_agent("cryptopane-backend/0.1")
        .build()
        .context("failed to build HTTP client")
}

pub async fn fetch_klines(
    client: &Client,
    symbol: &str,
    interval: &str,
    limit: usize,
) -> Result<Vec<Kline>> {
    let payload = client
        .get(BINANCE_KLINES_URL)
        .query(&[
            ("symbol", symbol),
            ("interval", interval),
            ("limit", &limit.to_string()),
        ])
        .send()
        .await
        .with_context(|| format!("failed to reach Binance for {symbol} {interval}"))?
        .error_for_status()
        .context("Binance returned an HTTP error")?
        .json::<Vec<RawKline>>()
        .await
        .context("failed to decode Binance klines response")?;

    payload
        .into_iter()
        .map(|raw| {
            let close = raw
                .4
                .parse::<f64>()
                .with_context(|| format!("invalid close value returned by Binance: {}", raw.4))?;

            Ok(Kline { close })
        })
        .collect()
}
