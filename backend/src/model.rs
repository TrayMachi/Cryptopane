use serde::{Deserialize, Serialize};

#[derive(Debug, Clone)]
pub struct Kline {
    pub close: f64,
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub struct WidgetData {
    pub symbol: String,
    pub interval: String,
    pub updated_at: i64,
    pub status: String,
    pub price: f64,
    pub change_points: f64,
    pub closes: Vec<f64>,
    pub ema20: Vec<Option<f64>>,
    pub bb_mid: Vec<Option<f64>>,
    pub bb_upper: Vec<Option<f64>>,
    pub bb_lower: Vec<Option<f64>>,
}

impl WidgetData {
    pub fn empty(
        symbol: impl Into<String>,
        interval: impl Into<String>,
        status: impl Into<String>,
    ) -> Self {
        Self {
            symbol: symbol.into(),
            interval: interval.into(),
            updated_at: 0,
            status: status.into(),
            price: 0.0,
            change_points: 0.0,
            closes: Vec::new(),
            ema20: Vec::new(),
            bb_mid: Vec::new(),
            bb_upper: Vec::new(),
            bb_lower: Vec::new(),
        }
    }
}
