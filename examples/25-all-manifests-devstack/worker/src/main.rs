use std::env;
use std::thread;
use std::time::Duration;

fn main() {
    let port = env::var("PORT").unwrap_or_else(|_| "3000".to_string());
    println!("worker started, reporting on port {}", port);
    for tick in 1..=3 {
        println!("worker tick {}", tick);
        thread::sleep(Duration::from_millis(200));
    }
    println!("worker done");
}
