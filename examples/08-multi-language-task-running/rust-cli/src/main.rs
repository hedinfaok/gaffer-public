use clap::{Parser, Subcommand};
use colored::*;
use serde::{Deserialize, Serialize};

mod api;
mod output;

#[derive(Parser)]
#[command(name = "prediction-cli")]
#[command(about = "CLI tool for interacting with prediction API", long_about = None)]
struct Cli {
    #[command(subcommand)]
    command: Commands,
}

#[derive(Subcommand)]
enum Commands {
    /// Check API health status
    Health {
        /// API base URL
        #[arg(short, long, default_value = "http://localhost:8080")]
        url: String,
    },
    /// Get recent predictions
    List {
        /// API base URL
        #[arg(short, long, default_value = "http://localhost:8080")]
        url: String,
    },
    /// Make a new prediction
    Predict {
        /// Features as comma-separated values
        #[arg(short, long)]
        features: String,
        /// API base URL
        #[arg(short = 'u', long, default_value = "http://localhost:8080")]
        url: String,
    },
    /// Show API metrics
    Metrics {
        /// API base URL
        #[arg(short, long, default_value = "http://localhost:8080")]
        url: String,
    },
}

#[tokio::main]
async fn main() {
    let cli = Cli::parse();

    match &cli.command {
        Commands::Health { url } => match api::check_health(url).await {
            Ok(health) => output::print_health(&health),
            Err(e) => {
                eprintln!("{} {}", "Error:".red().bold(), e);
                std::process::exit(1);
            }
        },
        Commands::List { url } => match api::get_predictions(url).await {
            Ok(predictions) => output::print_predictions(&predictions),
            Err(e) => {
                eprintln!("{} {}", "Error:".red().bold(), e);
                std::process::exit(1);
            }
        },
        Commands::Predict { features, url } => {
            let feature_vec: Vec<f64> = features
                .split(',')
                .filter_map(|s| s.trim().parse().ok())
                .collect();

            if feature_vec.is_empty() {
                eprintln!("{} Invalid features format", "Error:".red().bold());
                std::process::exit(1);
            }

            match api::make_prediction(url, &feature_vec).await {
                Ok(prediction) => output::print_prediction(&prediction),
                Err(e) => {
                    eprintln!("{} {}", "Error:".red().bold(), e);
                    std::process::exit(1);
                }
            }
        }
        Commands::Metrics { url } => match api::get_metrics(url).await {
            Ok(metrics) => output::print_metrics(&metrics),
            Err(e) => {
                eprintln!("{} {}", "Error:".red().bold(), e);
                std::process::exit(1);
            }
        },
    }
}
