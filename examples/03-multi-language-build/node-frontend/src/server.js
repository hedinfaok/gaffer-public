const express = require('express');
const cors = require('cors');
const axios = require('axios');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3000;
const BACKEND_URL = 'http://localhost:8080';

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.static('public'));

// Health check
app.get('/health', (req, res) => {
    res.json({
        success: true,
        service: 'node-frontend',
        status: 'healthy',
        version: '1.0.0',
        timestamp: new Date().toISOString(),
        backend_url: BACKEND_URL
    });
});

// Proxy to Rust backend
app.get('/api/backend/:endpoint', async (req, res) => {
    try {
        const endpoint = req.params.endpoint;
        console.log(`⚛️  Node.js proxying to Rust backend: /${endpoint}`);
        
        const response = await axios.get(`${BACKEND_URL}/${endpoint}`);
        
        res.json({
            success: true,
            source: 'rust-backend',
            proxied_by: 'node-frontend',
            data: response.data,
            timestamp: new Date().toISOString()
        });
    } catch (error) {
        console.error('Backend connection error:', error.message);
        res.status(500).json({
            success: false,
            error: 'Backend connection failed',
            message: error.message,
            backend_url: BACKEND_URL
        });
    }
});

// Dashboard data aggregation
app.get('/dashboard', async (req, res) => {
    try {
        console.log('⚛️  Node.js aggregating dashboard data...');
        
        // Fetch from multiple sources
        const [healthResp, metricsResp] = await Promise.all([
            axios.get(`${BACKEND_URL}/health`).catch(err => ({ data: { error: err.message } })),
            axios.get(`${BACKEND_URL}/metrics`).catch(err => ({ data: { error: err.message } }))
        ]);

        const dashboard = {
            title: 'Multi-Language Application Dashboard',
            built_with: 'gaffer-exec orchestration',
            timestamp: new Date().toISOString(),
            components: {
                main: 'Node.js Frontend (this service)',
                backend: 'Rust API Server',
                cli: 'Go Command Line Tool',
                ml: 'Python Machine Learning'
            },
            backend_health: healthResp.data,
            metrics: metricsResp.data,
            integration_status: {
                rust_backend: healthResp.data.success !== false ? 'connected' : 'disconnected',
                languages_active: ['JavaScript/Node.js', 'Rust', 'Go', 'Python'],
                build_orchestration: 'gaffer-exec'
            }
        };

        res.json({
            success: true,
            data: dashboard
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            error: 'Dashboard aggregation failed',
            message: error.message
        });
    }
});

// Simple HTML frontend
app.get('/', (req, res) => {
    const html = `
    <!DOCTYPE html>
    <html>
    <head>
        <title>Multi-Language App</title>
        <style>
            body { font-family: Arial, sans-serif; margin: 40px; background: #f5f5f5; }
            .container { max-width: 800px; margin: 0 auto; background: white; padding: 30px; border-radius: 8px; }
            .header { color: #2c3e50; border-bottom: 2px solid #3498db; padding-bottom: 10px; }
            .component { margin: 20px 0; padding: 15px; background: #ecf0f1; border-radius: 5px; }
            .status { padding: 5px 10px; border-radius: 3px; color: white; font-weight: bold; }
            .healthy { background: #27ae60; }
            .error { background: #e74c3c; }
            pre { background: #2c3e50; color: #ecf0f1; padding: 15px; border-radius: 5px; overflow-x: auto; }
            button { background: #3498db; color: white; border: none; padding: 10px 20px; margin: 5px; border-radius: 5px; cursor: pointer; }
            button:hover { background: #2980b9; }
        </style>
    </head>
    <body>
        <div class="container">
            <h1 class="header">🚀 Multi-Language Application</h1>
            <p>This application demonstrates <strong>gaffer-exec</strong> orchestrating builds across multiple languages.</p>
            
            <div class="component">
                <h3>🧩 Components</h3>
                <ul>
                    <li><strong>⚛️ Node.js Frontend</strong> - This web interface (Express.js)</li>
                    <li><strong>🦀 Rust Backend</strong> - API server on port 8080</li>
                    <li><strong>🐹 Go CLI</strong> - Command-line interface</li>
                    <li><strong>🐍 Python ML</strong> - Data analysis tools</li>
                </ul>
            </div>

            <div class="component">
                <h3>📊 Live Data</h3>
                <button onclick="loadHealth()">Check Backend Health</button>
                <button onclick="loadMetrics()">Load Metrics</button>
                <button onclick="loadDashboard()">Full Dashboard</button>
                <div id="output"></div>
            </div>

            <div class="component">
                <h3>🔧 Build Information</h3>
                <p><strong>Orchestrator:</strong> gaffer-exec</p>
                <p><strong>Build Pattern:</strong> Multi-language parallel builds</p>
                <p><strong>Languages:</strong> Rust, Go, JavaScript/Node.js, Python</p>
            </div>
        </div>

        <script>
            function loadHealth() {
                fetch('/api/backend/health')
                    .then(response => response.json())
                    .then(data => {
                        document.getElementById('output').innerHTML = 
                            '<h4>🔍 Backend Health</h4><pre>' + JSON.stringify(data, null, 2) + '</pre>';
                    })
                    .catch(error => {
                        document.getElementById('output').innerHTML = 
                            '<h4 class="error">❌ Error</h4><pre>' + error.message + '</pre>';
                    });
            }

            function loadMetrics() {
                fetch('/api/backend/metrics')
                    .then(response => response.json())
                    .then(data => {
                        document.getElementById('output').innerHTML = 
                            '<h4>📊 System Metrics</h4><pre>' + JSON.stringify(data, null, 2) + '</pre>';
                    })
                    .catch(error => {
                        document.getElementById('output').innerHTML = 
                            '<h4 class="error">❌ Error</h4><pre>' + error.message + '</pre>';
                    });
            }

            function loadDashboard() {
                fetch('/dashboard')
                    .then(response => response.json())
                    .then(data => {
                        document.getElementById('output').innerHTML = 
                            '<h4>🎛️ Full Dashboard</h4><pre>' + JSON.stringify(data, null, 2) + '</pre>';
                    })
                    .catch(error => {
                        document.getElementById('output').innerHTML = 
                            '<h4 class="error">❌ Error</h4><pre>' + error.message + '</pre>';
                    });
            }
        </script>
    </body>
    </html>
    `;
    
    res.send(html);
});

// Start server
app.listen(PORT, () => {
    console.log(`⚛️  Node.js frontend server running on port ${PORT}`);
    console.log(`🔗 Frontend: http://localhost:${PORT}`);
    console.log(`🔗 Backend proxy: http://localhost:${PORT}/api/backend/health`);
    console.log(`🎛️  Dashboard: http://localhost:${PORT}/dashboard`);
    console.log(`🦀 Rust backend: ${BACKEND_URL}`);
});