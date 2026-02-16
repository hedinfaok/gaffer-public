const request = require('supertest');
const App = require('../../src/index');

describe('API Integration Tests', () => {
    let app;
    let server;

    beforeAll(async () => {
        app = new App();
        server = app.app;
    });

    afterAll(async () => {
        if (app.server) {
            await app.stop();
        }
    });

    describe('Health Check', () => {
        test('GET /health should return healthy status', async () => {
            const response = await request(server)
                .get('/health')
                .expect(200);

            expect(response.body).toMatchObject({
                status: 'healthy',
                service: 'incremental-testing-api',
                version: '1.0.0'
            });
            expect(response.body).toHaveProperty('timestamp');
        });
    });

    describe('Calculator API Integration', () => {
        test('POST /api/calculate/add should add numbers', async () => {
            const response = await request(server)
                .post('/api/calculate/add')
                .send({ a: 10, b: 5 })
                .expect(200);

            expect(response.body).toMatchObject({
                operation: 'add',
                inputs: { a: 10, b: 5 },
                result: 15
            });
            expect(response.body).toHaveProperty('timestamp');
        });

        test('POST /api/calculate/subtract should subtract numbers', async () => {
            const response = await request(server)
                .post('/api/calculate/subtract')
                .send({ a: 10, b: 3 })
                .expect(200);

            expect(response.body).toMatchObject({
                operation: 'subtract',
                result: 7
            });
        });

        test('POST /api/calculate/multiply should multiply numbers', async () => {
            const response = await request(server)
                .post('/api/calculate/multiply')
                .send({ a: 4, b: 6 })
                .expect(200);

            expect(response.body.result).toBe(24);
        });

        test('POST /api/calculate/divide should divide numbers', async () => {
            const response = await request(server)
                .post('/api/calculate/divide')
                .send({ a: 15, b: 3 })
                .expect(200);

            expect(response.body.result).toBe(5);
        });

        test('should handle division by zero error', async () => {
            const response = await request(server)
                .post('/api/calculate/divide')
                .send({ a: 10, b: 0 })
                .expect(400);

            expect(response.body).toHaveProperty('error', 'Cannot divide by zero');
        });

        test('should handle invalid operation', async () => {
            const response = await request(server)
                .post('/api/calculate/power')
                .send({ a: 2, b: 3 })
                .expect(400);

            expect(response.body).toHaveProperty('error', 'Invalid operation');
        });

        test('should handle missing parameters', async () => {
            const response = await request(server)
                .post('/api/calculate/add')
                .send({ a: 5 }) // Missing 'b'
                .expect(400);

            expect(response.body).toHaveProperty('error', 'Both a and b are required');
        });
    });

    describe('User API Integration', () => {
        test('GET /api/users should return user list', async () => {
            const response = await request(server)
                .get('/api/users')
                .expect(200);

            expect(response.body).toHaveProperty('users');
            expect(response.body).toHaveProperty('total', 2);
            expect(response.body.users).toHaveLength(2);
            expect(response.body.users[0]).toHaveProperty('name', 'Alice');
        });

        test('GET /api/users/:id should return specific user', async () => {
            const response = await request(server)
                .get('/api/users/1')
                .expect(200);

            expect(response.body.user).toMatchObject({
                id: 1,
                name: 'Alice',
                email: 'alice@example.com'
            });
        });

        test('GET /api/users/:id should return 404 for non-existent user', async () => {
            const response = await request(server)
                .get('/api/users/999')
                .expect(404);

            expect(response.body).toHaveProperty('error', 'User not found');
        });

        test('POST /api/users should create new user', async () => {
            const newUser = {
                name: 'Integration Test User',
                email: 'integration@test.com',
                phone: '+1111111111'
            };

            const response = await request(server)
                .post('/api/users')
                .send(newUser)
                .expect(201);

            expect(response.body.user).toMatchObject({
                name: 'Integration Test User',
                email: 'integration@test.com',
                phone: '+1111111111'
            });
            expect(response.body.user).toHaveProperty('id');
            expect(response.body).toHaveProperty('message', 'User created successfully');
        });

        test('POST /api/users should validate required fields', async () => {
            const invalidUser = {
                name: 'Test User'
                // Missing email
            };

            const response = await request(server)
                .post('/api/users')
                .send(invalidUser)
                .expect(400);

            expect(response.body).toHaveProperty('error', 'Name and email are required');
        });

        test('POST /api/users should validate email format', async () => {
            const invalidUser = {
                name: 'Test User',
                email: 'invalid-email'
            };

            const response = await request(server)
                .post('/api/users')
                .send(invalidUser)
                .expect(400);

            expect(response.body).toHaveProperty('error', 'Invalid email format');
        });

        test('PUT /api/users/:id should update user', async () => {
            const updates = {
                name: 'Alice Updated',
                phone: '+9999999999'
            };

            const response = await request(server)
                .put('/api/users/1')
                .send(updates)
                .expect(200);

            expect(response.body.user).toMatchObject({
                id: 1,
                name: 'Alice Updated',
                phone: '+9999999999',
                email: 'alice@example.com' // Should remain unchanged
            });
            expect(response.body).toHaveProperty('message', 'User updated successfully');
        });

        test('PUT /api/users/:id should return 400 for non-existent user', async () => {
            const updates = { name: 'Test' };

            const response = await request(server)
                .put('/api/users/999')
                .send(updates)
                .expect(400);

            expect(response.body).toHaveProperty('error', 'User not found');
        });

        test('DELETE /api/users/:id should delete user', async () => {
            // First create a user to delete
            const createResponse = await request(server)
                .post('/api/users')
                .send({
                    name: 'To Be Deleted',
                    email: 'delete@test.com'
                });

            const userId = createResponse.body.user.id;

            // Now delete the user
            const response = await request(server)
                .delete(`/api/users/${userId}`)
                .expect(200);

            expect(response.body.user).toMatchObject({
                id: userId,
                name: 'To Be Deleted',
                email: 'delete@test.com'
            });
            expect(response.body).toHaveProperty('message', 'User deleted successfully');

            // Verify user is deleted
            await request(server)
                .get(`/api/users/${userId}`)
                .expect(404);
        });
    });

    describe('Root Endpoint Integration', () => {
        test('GET / should return API information', async () => {
            const response = await request(server)
                .get('/')
                .expect(200);

            expect(response.body).toMatchObject({
                message: 'Incremental Testing API',
                description: 'Demonstrates real testing with gaffer-exec orchestration'
            });
            expect(response.body).toHaveProperty('endpoints');
            expect(response.body).toHaveProperty('built_with', 'gaffer-exec incremental testing');
        });
    });

    describe('Cross-Component Integration', () => {
        test('should demonstrate full workflow: create, read, update, calculate', async () => {
            // 1. Create a user
            const createResponse = await request(server)
                .post('/api/users')
                .send({
                    name: 'Workflow Test User',
                    email: 'workflow@test.com'
                });

            const userId = createResponse.body.user.id;
            expect(createResponse.status).toBe(201);

            // 2. Read the user back
            const readResponse = await request(server)
                .get(`/api/users/${userId}`)
                .expect(200);

            expect(readResponse.body.user.name).toBe('Workflow Test User');

            // 3. Perform calculations (demonstrating calculator integration)
            const calcResponse = await request(server)
                .post('/api/calculate/multiply')
                .send({ a: userId, b: 10 }) // Use user ID in calculation
                .expect(200);

            expect(calcResponse.body.result).toBe(userId * 10);

            // 4. Update user with calculated information (ensure valid phone format)
            const phoneNumber = `+1555${String(calcResponse.body.result).padStart(6, '0')}`;
            await request(server)
                .put(`/api/users/${userId}`)
                .send({
                    phone: phoneNumber // Use calc result as part of phone number
                })
                .expect(200);

            // 5. Verify final state
            const finalResponse = await request(server)
                .get(`/api/users/${userId}`)
                .expect(200);

            expect(finalResponse.body.user).toMatchObject({
                name: 'Workflow Test User',
                email: 'workflow@test.com',
                phone: phoneNumber
            });
        });
    });
});