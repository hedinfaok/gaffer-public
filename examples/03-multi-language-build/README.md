# Multi-Language Project Builds

This example demonstrates orchestrating **real builds** across Rust, Go, Node.js, and Python in a single project, similar to patterns used in major open source projects.

## Real Open Source Project Pattern

This follows multi-language patterns used by:
- **Kubernetes** (Go + Node.js dashboard + Python tools)
- **TensorFlow** (Python + C++ + JavaScript bindings)
- **VS Code** (TypeScript + C++ extensions + Python language servers)
- **Tauri** (Rust backend + JavaScript frontend)

## Project Structure

```
03-multi-language-build/
├── rust-backend/           # Rust API server
│   ├── Cargo.toml
│   └── src/main.rs
├── go-cli/                 # Go command-line tool
│   ├── go.mod
│   └── main.go
├── node-frontend/          # Node.js/React frontend
│   ├── package.json
│   └── src/App.js
├── python-ml/              # Python ML analysis
│   ├── requirements.txt
│   ├── setup.py
│   └── analyze.py
├── graph.json              # gaffer-exec build orchestration
└── docker-compose.yml      # Container orchestration
```

## Language Dependencies

```
rust-deps ────────────────────────────┐
go-deps ──────────────────────────────┤
node-deps → node-build ───────────────┼──> multi-language-build → start-all
python-deps → python-build ───────────┘
```

**Key Features:**
- Each language builds independently where possible
- Real compilation/bundling with actual artifacts
- Demonstrates polyglot orchestration patterns
- Integration testing across all languages

## How to Run

```bash
# Build all languages
gaffer-exec run multi-language-build --graph graph.json

# Build individual languages
gaffer-exec run rust-backend --graph graph.json
gaffer-exec run go-cli --graph graph.json
gaffer-exec run node-frontend --graph graph.json
gaffer-exec run python-ml --graph graph.json

# Start integrated application
gaffer-exec run start-all --graph graph.json
```

## Expected Output

**All language builds run in parallel:**
- Rust backend compiles (release mode)
- Go CLI tool builds
- Node.js frontend bundles
- Python ML package installs
- Integration layer connects all components

## Prerequisites

Install the required language toolchains:

```bash
# Rust (install from https://rustup.rs/)
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Go (install from https://golang.org/dl/)
# brew install go  # macOS
# sudo apt install golang-go  # Ubuntu

# Node.js (install from https://nodejs.org/)
# brew install node  # macOS  
# sudo apt install nodejs npm  # Ubuntu

# Python 3 (usually pre-installed)
python3 --version
pip3 --version
```

## Real Implementation

Each component is fully functional:

- **🦀 Rust Backend**: HTTP API server with JSON responses
- **🐹 Go CLI**: Command-line tool that calls the Rust API
- **⚛️ Node Frontend**: React app that displays API data
- **🐍 Python ML**: Data analysis tool that processes API responses

## Integration Flow

1. Rust backend starts on port 8080
2. Node frontend starts on port 3000
3. Go CLI tool fetches data from backend
4. Python script analyzes the results
5. All components work together in a polyglot system
  "npm-build": { "command": "npm run build" },
  "python-build": { "command": "python -m build" }
}
```
