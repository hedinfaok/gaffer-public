use serde::{Deserialize, Serialize};
use std::collections::HashMap;
use warp::Filter;

#[derive(Debug, Serialize, Deserialize)]
struct ApiResponse {
    success: bool,
    data: serde_json::Value,
    timestamp: u64,
    language: String,
}

#[derive(Debug, Serialize, Deserialize)]
struct HealthStatus {
    status: String,
    version: String,
    uptime: String,
    build_info: BuildInfo,
}

#[derive(Debug, Serialize, Deserialize)]
struct BuildInfo {
    built_with: String,
    orchestrator: String,
    languages: Vec<String>,
}

#[derive(Debug, Serialize, Deserialize)]
struct MetricsData {
    requests_served: u64,
    languages_integrated: u32,
    build_time_seconds: f32,
    components: Vec<String>,
}

#[tokio::main]
async fn main() {
    println!("🦀 Starting Rust Backend Server...");
    
    // Health endpoint
    let health = warp::path("health")
        .and(warp::get())
        .map(|| {
            let health = HealthStatus {
                status: "healthy".to_string(),
                version: "1.0.0".to_string(),
                uptime: "5m 32s".to_string(),
                build_info: BuildInfo {
                    built_with: "gaffer-exec multi-language build".to_string(),
                    orchestrator: "gaffer-exec".to_string(),
                    languages: vec![
                        "Rust".to_string(),
                        "Go".to_string(), 
                        "Node.js".to_string(),
                        "Python".to_string(),
                    ],
                },
            };
            
            warp::reply::json(&ApiResponse {
                success: true,
                data: serde_json::to_value(&health).unwrap(),
                timestamp: std::time::SystemTime::now()
                    .duration_since(std::time::UNIX_EPOCH)
                    .unwrap()
                    .as_secs(),
                language: "Rust".to_string(),
            })
        });

    // Metrics endpoint
    let metrics = warp::path("metrics")
        .and(warp::get())
        .map(|| {
            let metrics = MetricsData {
                requests_served: 1247,
                languages_integrated: 4,
                build_time_seconds: 12.34,
                components: vec![
                    "rust-backend".to_string(),
                    "go-cli".to_string(),
                    "node-frontend".to_string(),
                    "python-ml".to_string(),
                ],
            };
            
            warp::reply::json(&ApiResponse {
                success: true,
                data: serde_json::to_value(&metrics).unwrap(),
                timestamp: std::time::SystemTime::now()
                    .duration_since(std::time::UNIX_EPOCH)
                    .unwrap()
                    .as_secs(),
                language: "Rust".to_string(),
            })
        });

    // API info endpoint
    let api_info = warp::path("api")
        .and(warp::get())
        .map(|| {
            let mut info = HashMap::new();
            info.insert("name", "Multi-Language API");
            info.insert("description", "Rust backend for polyglot application");
            info.insert("version", "1.0.0");
            
            let mut endpoints = HashMap::new();
            endpoints.insert("health", "GET /health - Service health check");
            endpoints.insert("metrics", "GET /metrics - Application metrics");
            endpoints.insert("api", "GET /api - API information");
            
            info.insert("endpoints", serde_json::to_string(&endpoints).unwrap().as_str());
            
            warp::reply::json(&ApiResponse {
                success: true,
                data: serde_json::to_value(&info).unwrap(),
                timestamp: std::time::SystemTime::now()
                    .duration_since(std::time::UNIX_EPOCH)
                    .unwrap()
                    .as_secs(),
                language: "Rust".to_string(),
            })
        });

    // CORS headers
    let cors = warp::cors()
        .allow_any_origin()
        .allow_headers(vec!["content-type"])
        .allow_methods(vec!["GET", "POST"]);

    let routes = health
        .or(metrics)
        .or(api_info)
        .with(cors);

    println!("🚀 Rust backend running on http://localhost:8080");
    println!("📡 Available endpoints:");
    println!("   - GET /health");
    println!("   - GET /metrics");
    println!("   - GET /api");

    warp::serve(routes)
        .run(([127, 0, 0, 1], 8080))
        .await;
}