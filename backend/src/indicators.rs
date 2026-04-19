#[derive(Debug, Clone, PartialEq)]
pub struct BollingerBands {
    pub mid: Vec<Option<f64>>,
    pub upper: Vec<Option<f64>>,
    pub lower: Vec<Option<f64>>,
}

pub fn ema(period: usize, values: &[f64]) -> Vec<Option<f64>> {
    let mut output = vec![None; values.len()];

    if period == 0 || values.len() < period {
        return output;
    }

    let seed = values[..period].iter().sum::<f64>() / period as f64;
    let multiplier = 2.0 / (period as f64 + 1.0);
    let mut previous = seed;

    output[period - 1] = Some(seed);

    for index in period..values.len() {
        previous = ((values[index] - previous) * multiplier) + previous;
        output[index] = Some(previous);
    }

    output
}

pub fn bollinger_bands(period: usize, sigma: f64, values: &[f64]) -> BollingerBands {
    let mut mid = vec![None; values.len()];
    let mut upper = vec![None; values.len()];
    let mut lower = vec![None; values.len()];

    if period == 0 || values.len() < period {
        return BollingerBands { mid, upper, lower };
    }

    for index in (period - 1)..values.len() {
        let window = &values[(index + 1 - period)..=index];
        let mean = window.iter().sum::<f64>() / period as f64;
        let variance = window
            .iter()
            .map(|value| {
                let diff = value - mean;
                diff * diff
            })
            .sum::<f64>()
            / period as f64;
        let deviation = variance.sqrt();

        mid[index] = Some(mean);
        upper[index] = Some(mean + sigma * deviation);
        lower[index] = Some(mean - sigma * deviation);
    }

    BollingerBands { mid, upper, lower }
}

#[cfg(test)]
mod tests {
    use super::{bollinger_bands, ema};

    fn almost_equal(left: f64, right: f64) {
        assert!(
            (left - right).abs() < 0.000001,
            "left={left}, right={right}"
        );
    }

    #[test]
    fn ema_uses_sma_seed_and_preserves_alignment() {
        let values = vec![10.0, 11.0, 12.0, 13.0, 14.0];
        let result = ema(3, &values);

        assert_eq!(result.len(), values.len());
        assert_eq!(result[0], None);
        assert_eq!(result[1], None);
        almost_equal(result[2].unwrap(), 11.0);
        almost_equal(result[3].unwrap(), 12.0);
        almost_equal(result[4].unwrap(), 13.0);
    }

    #[test]
    fn bollinger_bands_return_constant_output_for_flat_series() {
        let values = vec![42.0; 6];
        let result = bollinger_bands(3, 2.0, &values);

        assert_eq!(result.mid.len(), values.len());
        assert_eq!(result.upper.len(), values.len());
        assert_eq!(result.lower.len(), values.len());
        assert_eq!(result.mid[0], None);
        assert_eq!(result.mid[1], None);

        for index in 2..values.len() {
            almost_equal(result.mid[index].unwrap(), 42.0);
            almost_equal(result.upper[index].unwrap(), 42.0);
            almost_equal(result.lower[index].unwrap(), 42.0);
        }
    }
}
