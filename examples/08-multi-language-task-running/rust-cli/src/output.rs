use crate::api::{HealthResponse, MetricsResponse, Prediction, PredictionsResponse};
use colored::*;

pub fn print_health(health: &HealthResponse) {
    println!("{}", "=== API Health ===".green().bold());
    println!("{}: {}", "Status".bold(), health.status.green());
    println!("{}: {}", "Version".bold(), health.version);
    println!("{}: {}", "Timestamp".bold(), health.timestamp);
}

pub fn print_predictions(response: &PredictionsResponse) {
    println!("{}", "=== Recent Predictions ===".cyan().bold());
    println!("{}: {}", "Count".bold(), response.count);
    println!("{}: {}", "Timestamp".bold(), response.timestamp);
    println!();

    for (i, pred) in response.predictions.iter().enumerate() {
        println!(
            "{}. {} (confidence: {:.2}%)",
            i + 1,
            pred.label.yellow().bold(),
            pred.confidence * 100.0
        );
    }
}

pub fn print_prediction(prediction: &Prediction) {
    println!("{}", "=== Prediction Result ===".magenta().bold());
    println!("{}: {}", "Label".bold(), prediction.label.yellow());
    println!(
        "{}: {:.2}%",
        "Confidence".bold(),
        prediction.confidence * 100.0
    );
}

pub fn print_metrics(metrics: &MetricsResponse) {
    println!("{}", "=== API Metrics ===".blue().bold());
    println!("{}: {}", "Uptime".bold(), metrics.uptime);
    println!("{}: {}", "Total Requests".bold(), metrics.requests_total);
    println!(
        "{}: {:.2} MB",
        "Memory Usage".bold(),
        metrics.memory_usage_mb
    );
    println!("{}: {}", "Goroutines".bold(), metrics.goroutines);
    println!("{}: {}", "CPU Cores".bold(), metrics.cpu_cores);
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_output_functions_dont_panic() {
        let health = HealthResponse {
            status: "healthy".to_string(),
            timestamp: "2024-01-01".to_string(),
            version: "1.0.0".to_string(),
        };
        print_health(&health);

        let prediction = Prediction {
            label: "test".to_string(),
            confidence: 0.95,
        };
        print_prediction(&prediction);
    }
}
