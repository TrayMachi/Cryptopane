use std::time::Duration;

use anyhow::{Context, Result};
use reqwest::Client;
use serde::de::IgnoredAny;
use serde::Deserialize;

use crate::model::Kline;

pub const DEFAULT_BINANCE_BASE_URL: &str = "https://data-api.binance.vision";
const KLINES_PATH: &str = "/api/v3/klines";

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
    base_url: &str,
    symbol: &str,
    interval: &str,
    limit: usize,
) -> Result<Vec<Kline>> {
    let klines_url = format!("{}{}", base_url.trim_end_matches('/'), KLINES_PATH);
    let payload = client
        .get(&klines_url)
        .query(&[
            ("symbol", symbol),
            ("interval", interval),
            ("limit", &limit.to_string()),
        ])
        .send()
        .await
        .with_context(|| format!("failed to reach Binance for {symbol} {interval} via {base_url}"))?
        .error_for_status()
        .with_context(|| format!("Binance returned an HTTP error via {base_url}"))?
        .json::<Vec<RawKline>>()
        .await
        .with_context(|| format!("failed to decode Binance klines response from {base_url}"))?;

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
