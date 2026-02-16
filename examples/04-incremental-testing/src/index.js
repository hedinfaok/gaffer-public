const express = require('express');
const cors = require('cors');
const { UserService } = require('./api/userService');
const { Calculator } = require('./lib/utils');

class App {
    constructor() {
        this.app = express();
        this.userService = new UserService();
        this.calculator = new Calculator();
        
        this.setupMiddleware();
        this.setupRoutes();
    }

    setupMiddleware() {
        this.app.use(cors());
        this.app.use(express.json());
        this.app.use(express.urlencoded({ extended: true }));
    }

    setupRoutes() {
        // Health check
        this.app.get('/health', (req, res) => {
            res.json({
                status: 'healthy',
                service: 'incremental-testing-api',
                version: '1.0.0',
                timestamp: new Date().toISOString(),
                built_with: 'gaffer-exec incremental testing'
            });
        });

        // Calculator routes
        this.app.post('/api/calculate/:operation', (req, res) => {
            try {
                const { operation } = req.params;
                const { a, b } = req.body;
                
                if (a === undefined || b === undefined) {
                    return res.status(400).json({ error: 'Both a and b are required' });
                }

                let result;
                switch (operation) {
                    case 'add':
                        result = this.calculator.add(parseFloat(a), parseFloat(b));
                        break;
                    case 'subtract':
                        result = this.calculator.subtract(parseFloat(a), parseFloat(b));
                        break;
                    case 'multiply':
                        result = this.calculator.multiply(parseFloat(a), parseFloat(b));
                        break;
                    case 'divide':
                        result = this.calculator.divide(parseFloat(a), parseFloat(b));
                        break;
                    default:
                        return res.status(400).json({ error: 'Invalid operation' });
                }

                res.json({ 
                    operation,
                    inputs: { a: parseFloat(a), b: parseFloat(b) },
                    result,
                    timestamp: new Date().toISOString()
                });
            } catch (error) {
                res.status(400).json({ error: error.message });
            }
        });

        // User routes
        this.app.get('/api/users', (req, res) => {
            try {
                const users = this.userService.getAllUsers();
                res.json({ 
                    users,
                    total: users.length,
                    timestamp: new Date().toISOString()
                });
            } catch (error) {
                res.status(500).json({ error: error.message });
            }
        });

        this.app.get('/api/users/:id', (req, res) => {
            try {
                const user = this.userService.getUserById(req.params.id);
                res.json({ user });
            } catch (error) {
                res.status(404).json({ error: error.message });
            }
        });

        this.app.post('/api/users', (req, res) => {
            try {
                const user = this.userService.createUser(req.body);
                res.status(201).json({ user, message: 'User created successfully' });
            } catch (error) {
                res.status(400).json({ error: error.message });
            }
        });

        this.app.put('/api/users/:id', (req, res) => {
            try {
                const user = this.userService.updateUser(req.params.id, req.body);
                res.json({ user, message: 'User updated successfully' });
            } catch (error) {
                res.status(400).json({ error: error.message });
            }
        });

        this.app.delete('/api/users/:id', (req, res) => {
            try {
                const user = this.userService.deleteUser(req.params.id);
                res.json({ user, message: 'User deleted successfully' });
            } catch (error) {
                res.status(404).json({ error: error.message });
            }
        });

        // Root route
        this.app.get('/', (req, res) => {
            res.json({
                message: 'Incremental Testing API',
                description: 'Demonstrates real testing with gaffer-exec orchestration',
                endpoints: {
                    health: 'GET /health',
                    calculator: 'POST /api/calculate/{add|subtract|multiply|divide}',
                    users: {
                        list: 'GET /api/users',
                        get: 'GET /api/users/:id',
                        create: 'POST /api/users',
                        update: 'PUT /api/users/:id',
                        delete: 'DELETE /api/users/:id'
                    }
                },
                built_with: 'gaffer-exec incremental testing',
                test_types: ['unit', 'integration', 'e2e']
            });
        });
    }

    start(port = 3000) {
        return new Promise((resolve) => {
            this.server = this.app.listen(port, () => {
                console.log(`🧪 Test API server running on port ${port}`);
                resolve();
            });
        });
    }

    stop() {
        return new Promise((resolve) => {
            if (this.server) {
                this.server.close(() => {
                    console.log('Test API server stopped');
                    resolve();
                });
            } else {
                resolve();
            }
        });
    }
}

module.exports = App;

// Start server if run directly
if (require.main === module) {
    const app = new App();
    app.start(process.env.PORT || 3000);
}