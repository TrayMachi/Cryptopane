mod binance;
mod indicators;
mod model;
mod output;

use std::path::{Path, PathBuf};
use std::time::{Duration, SystemTime, UNIX_EPOCH};

use anyhow::{bail, Context, Result};
use clap::Parser;
use reqwest::Client;
use tokio::time::{self, MissedTickBehavior};

use crate::indicators::{bollinger_bands, ema, rsi};
use crate::model::{Kline, WidgetData};

const DEFAULT_SYMBOL: &str = "BTCUSDT";
const DEFAULT_INTERVAL: &str = "5m";
const DEFAULT_LIMIT: usize = 500;
const DEFAULT_REFRESH_SECS: u64 = 10;

#[derive(Debug, Clone, Parser)]
#[command(name = "cryptopane-backend")]
#[command(about = "Fetch Binance data and write Cryptopane widget JSON")]
struct Cli {
    #[arg(long, env = "CRYPTOPANE_SYMBOL", default_value = DEFAULT_SYMBOL)]
    symbol: String,

    #[arg(long, env = "CRYPTOPANE_INTERVAL", default_value = DEFAULT_INTERVAL)]
    interval: String,

    #[arg(long, env = "CRYPTOPANE_LIMIT", default_value_t = DEFAULT_LIMIT)]
    limit: usize,

    #[arg(long, env = "CRYPTOPANE_REFRESH_SECS", default_value_t = DEFAULT_REFRESH_SECS)]
    refresh_secs: u64,

    #[arg(long, env = "CRYPTOPANE_OUTPUT_PATH")]
    output_path: Option<PathBuf>,

    #[arg(long, env = "CRYPTOPANE_ONCE", default_value_t = false)]
    once: bool,
}

#[derive(Debug, Clone)]
struct AppConfig {
    symbol: String,
    interval: String,
    limit: usize,
    refresh_secs: u64,
    output_path: PathBuf,
    once: bool,
}

#[tokio::main]
async fn main() -> Result<()> {
    let cli = Cli::parse();
    let config = AppConfig::from_cli(cli)?;
    let client = binance::build_client()?;
    let mut last_ok = load_cached_snapshot(&config.output_path)?;

    let mut ticker = time::interval(Duration::from_secs(config.refresh_secs));
    ticker.set_missed_tick_behavior(MissedTickBehavior::Skip);

    loop {
        ticker.tick().await;

        match refresh_widget(&client, &config).await {
            Ok(snapshot) => {
                last_ok = Some(snapshot.clone());
                let outcome = output::write_widget_data(&config.output_path, &snapshot)?;
                eprintln!(
                    "updated {} {} -> {:?}",
                    config.symbol, config.interval, outcome
                );
            }
            Err(error) => {
                eprintln!("refresh failed: {error:#}");

                let error_snapshot = error_snapshot_for(&config, last_ok.as_ref());
                let outcome = output::write_widget_data(&config.output_path, &error_snapshot)?;
                eprintln!(
                    "wrote fallback {} {} -> {:?}",
                    config.symbol, config.interval, outcome
                );
            }
        }

        if config.once {
            break;
        }
    }

    Ok(())
}

impl AppConfig {
    fn from_cli(cli: Cli) -> Result<Self> {
        if cli.limit < 200 {
            bail!("--limit must be at least 200 so EMA 200 can warm up");
        }

        if cli.refresh_secs == 0 {
            bail!("--refresh-secs must be greater than zero");
        }

        let output_path = cli
            .output_path
            .unwrap_or_else(|| default_output_path(&cli.symbol, &cli.interval));

        Ok(Self {
            symbol: cli.symbol,
            interval: cli.interval,
            limit: cli.limit,
            refresh_secs: cli.refresh_secs,
            output_path,
            once: cli.once,
        })
    }
}

async fn refresh_widget(client: &Client, config: &AppConfig) -> Result<WidgetData> {
    let klines =
        binance::fetch_klines(client, &config.symbol, &config.interval, config.limit).await?;
    build_widget_data(config, &klines)
}

fn build_widget_data(config: &AppConfig, klines: &[Kline]) -> Result<WidgetData> {
    if klines.is_empty() {
        bail!("Binance returned no klines");
    }

    let closes = klines.iter().map(|kline| kline.close).collect::<Vec<_>>();
    let ema9 = ema(9, &closes);
    let ema21 = ema(21, &closes);
    let ema200 = ema(200, &closes);
    let bands = bollinger_bands(20, 2.0, &closes);
    let rsi14 = rsi(14, &closes);
    let price = *closes
        .last()
        .context("close series was unexpectedly empty")?;
    let first = *closes
        .first()
        .context("close series was unexpectedly empty")?;

    Ok(WidgetData {
        symbol: config.symbol.clone(),
        interval: config.interval.clone(),
        updated_at: now_unix_millis()?,
        status: String::from("ok"),
        price,
        change_points: price - first,
        closes,
        ema9,
        ema21,
        ema200,
        rsi14,
        bb_mid: bands.mid,
        bb_upper: bands.upper,
        bb_lower: bands.lower,
    })
}

fn error_snapshot_for(config: &AppConfig, previous: Option<&WidgetData>) -> WidgetData {
    if let Some(snapshot) = previous {
        let mut output = snapshot.clone();
        output.status = String::from("error");
        return output;
    }

    WidgetData::empty(config.symbol.clone(), config.interval.clone(), "error")
}

fn load_cached_snapshot(path: &Path) -> Result<Option<WidgetData>> {
    match output::read_widget_data(path) {
        Ok(Some(snapshot)) if !snapshot.closes.is_empty() => Ok(Some(snapshot)),
        Ok(Some(_)) => Ok(None),
        Ok(None) => Ok(None),
        Err(error) => {
            eprintln!("ignoring unreadable cached snapshot: {error:#}");
            Ok(None)
        }
    }
}

fn default_output_path(symbol: &str, interval: &str) -> PathBuf {
    Path::new(env!("CARGO_MANIFEST_DIR"))
        .join("../data")
        .join(format!(
            "{}_{}.json",
            normalize_for_path(symbol),
            normalize_for_path(interval)
        ))
}

fn normalize_for_path(value: &str) -> String {
    value
        .chars()
        .map(|character| {
            if character.is_ascii_alphanumeric() {
                character.to_ascii_lowercase()
            } else {
                '_'
            }
        })
        .collect()
}

fn now_unix_millis() -> Result<i64> {
    Ok(SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .context("system clock is before UNIX_EPOCH")?
        .as_millis() as i64)
}
