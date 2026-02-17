use serde::{Deserialize, Serialize};

#[derive(Debug, Deserialize)]
pub struct HealthResponse {
    pub status: String,
    pub timestamp: String,
    pub version: String,
}

#[derive(Debug, Deserialize)]
pub struct Prediction {
    pub label: String,
    pub confidence: f64,
}

#[derive(Debug, Deserialize)]
pub struct PredictionsResponse {
    pub predictions: Vec<Prediction>,
    pub count: usize,
    pub timestamp: String,
}

#[derive(Debug, Deserialize)]
pub struct MetricsResponse {
    pub uptime: String,
    pub requests_total: i64,
    pub memory_usage_mb: f64,
    pub goroutines: i32,
    pub cpu_cores: i32,
}

#[derive(Serialize)]
struct PredictRequest {
    features: Vec<f64>,
}

pub async fn check_health(base_url: &str) -> Result<HealthResponse, Box<dyn std::error::Error>> {
    let url = format!("{}/health", base_url);
    let response = reqwest::get(&url).await?;
    let health = response.json::<HealthResponse>().await?;
    Ok(health)
}

pub async fn get_predictions(
    base_url: &str,
) -> Result<PredictionsResponse, Box<dyn std::error::Error>> {
    let url = format!("{}/predictions", base_url);
    let response = reqwest::get(&url).await?;
    let predictions = response.json::<PredictionsResponse>().await?;
    Ok(predictions)
}

pub async fn make_prediction(
    base_url: &str,
    features: &[f64],
) -> Result<Prediction, Box<dyn std::error::Error>> {
    let url = format!("{}/predict", base_url);
    let client = reqwest::Client::new();
    let request_body = PredictRequest {
        features: features.to_vec(),
    };

    let response = client.post(&url).json(&request_body).send().await?;

    let prediction = response.json::<Prediction>().await?;
    Ok(prediction)
}

pub async fn get_metrics(base_url: &str) -> Result<MetricsResponse, Box<dyn std::error::Error>> {
    let url = format!("{}/metrics", base_url);
    let response = reqwest::get(&url).await?;
    let metrics = response.json::<MetricsResponse>().await?;
    Ok(metrics)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_predict_request_serialization() {
        let request = PredictRequest {
            features: vec![0.1, 0.2, 0.3],
        };
        let json = serde_json::to_string(&request).unwrap();
        assert!(json.contains("features"));
        assert!(json.contains("0.1"));
    }
}
