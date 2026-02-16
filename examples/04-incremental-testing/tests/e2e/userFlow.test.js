/**
 * End-to-End Tests
 * 
 * These tests simulate real user interactions with the application.
 * In a real project, these would use tools like Playwright, Puppeteer, or Selenium.
 * For this example, we'll simulate e2e behavior with HTTP requests and component integration.
 */

const request = require('supertest');
const App = require('../../src/index');
const { UserCard, UserList, FormValidator } = require('../../src/ui/components');

describe('E2E User Management Workflow', () => {
    let app;
    let server;

    beforeAll(async () => {
        app = new App();
        server = app.app;
        
        // Simulate starting the server for e2e testing
        console.log('🧪 Starting E2E test environment...');
    });

    afterAll(async () => {
        if (app.server) {
            await app.stop();
        }
        console.log('🧪 E2E test environment cleaned up');
    });

    describe('Complete User Journey', () => {
        let createdUserId;

        test('E2E: User Registration Flow', async () => {
            // Simulate form validation on frontend
            const validator = new FormValidator();
            validator.addRule('name', value => value && value.length > 0, 'Name required');
            validator.addRule('email', value => value && value.includes('@'), 'Valid email required');
            validator.addRule('phone', value => !value || value.length >= 10, 'Phone must be 10+ digits');

            const userInput = {
                name: 'E2E Test User',
                email: 'e2e@test.com',
                phone: '+1555123456'
            };

            // Frontend validation passes
            expect(validator.validate(userInput)).toBe(true);

            // Submit to backend API
            const response = await request(server)
                .post('/api/users')
                .send(userInput)
                .expect(201);

            createdUserId = response.body.user.id;
            expect(response.body.user).toMatchObject(userInput);

            console.log(`✅ E2E: User created with ID ${createdUserId}`);
        });

        test('E2E: User Profile Display', async () => {
            // Fetch user data (as frontend would)
            const response = await request(server)
                .get(`/api/users/${createdUserId}`)
                .expect(200);

            const userData = response.body.user;

            // Render user card (UI component)
            const userCard = new UserCard(userData);
            const cardHtml = userCard.render();

            // Verify rendering contains expected data
            expect(cardHtml).toContain('E2E Test User');
            expect(cardHtml).toContain('e2e@test.com');
            expect(cardHtml).toContain('+1555123456');
            expect(cardHtml).toContain(`user-${createdUserId}`);

            console.log('✅ E2E: User profile rendered successfully');
        });

        test('E2E: User List Management', async () => {
            // Get all users (as admin panel would)
            const response = await request(server)
                .get('/api/users')
                .expect(200);

            const users = response.body.users;

            // Create user list component
            const userList = new UserList();
            users.forEach(user => userList.addUser(user));

            // Test filtering functionality
            userList.filterBy('name', 'E2E');
            const filteredUsers = userList.getFilteredUsers();
            
            expect(filteredUsers).toHaveLength(1);
            expect(filteredUsers[0].name).toBe('E2E Test User');

            // Render list
            const listHtml = userList.render();
            expect(listHtml).toContain('Users (1)');
            expect(listHtml).toContain('E2E Test User');

            console.log('✅ E2E: User list filtering works');
        });

        test('E2E: User Profile Update', async () => {
            // Simulate form validation for update
            const validator = new FormValidator();
            validator.addRule('phone', value => !value || value.length >= 10, 'Valid phone required');

            const updateData = {
                phone: '+1555987654'
            };

            // Validate update data
            expect(validator.validate(updateData)).toBe(true);

            // Submit update
            const updateResponse = await request(server)
                .put(`/api/users/${createdUserId}`)
                .send(updateData)
                .expect(200);

            expect(updateResponse.body.user.phone).toBe('+1555987654');

            // Verify update by fetching again
            const fetchResponse = await request(server)
                .get(`/api/users/${createdUserId}`)
                .expect(200);

            expect(fetchResponse.body.user.phone).toBe('+1555987654');

            console.log('✅ E2E: User update completed');
        });

        test('E2E: Calculator Integration', async () => {
            // User interacts with calculator feature
            const calculation = await request(server)
                .post('/api/calculate/add')
                .send({ a: 100, b: 50 })
                .expect(200);

            expect(calculation.body.result).toBe(150);

            // Use calculation result in user context (e.g., scoring)
            const userScore = calculation.body.result;
            
            // This could be stored or used in user profile
            expect(userScore).toBeGreaterThan(0);

            console.log(`✅ E2E: Calculator integration (result: ${userScore})`);
        });

        test('E2E: Error Handling', async () => {
            // Test form validation errors
            const validator = new FormValidator();
            validator.addRule('email', value => value && value.includes('@'), 'Valid email required');

            const invalidData = { email: 'invalid-email' };
            expect(validator.validate(invalidData)).toBe(false);
            
            const errors = validator.getErrors();
            expect(errors.email).toContain('Valid email required');

            // Test API error handling
            const apiError = await request(server)
                .get('/api/users/99999')
                .expect(404);

            expect(apiError.body.error).toBe('User not found');

            console.log('✅ E2E: Error handling works correctly');
        });

        test('E2E: User Deletion (Cleanup)', async () => {
            // Delete the test user
            const deleteResponse = await request(server)
                .delete(`/api/users/${createdUserId}`)
                .expect(200);

            expect(deleteResponse.body.user.id).toBe(createdUserId);

            // Verify deletion
            await request(server)
                .get(`/api/users/${createdUserId}`)
                .expect(404);

            console.log(`✅ E2E: User ${createdUserId} cleaned up`);
        });
    });

    describe('Cross-Component E2E Scenarios', () => {
        test('E2E: Full Application Smoke Test', async () => {
            // Test all major endpoints are working
            const healthCheck = await request(server).get('/health').expect(200);
            expect(healthCheck.body.status).toBe('healthy');

            const apiInfo = await request(server).get('/').expect(200);
            expect(apiInfo.body.message).toContain('Incremental Testing API');

            const usersList = await request(server).get('/api/users').expect(200);
            expect(usersList.body).toHaveProperty('users');

            const calculation = await request(server)
                .post('/api/calculate/multiply')
                .send({ a: 6, b: 7 })
                .expect(200);
            expect(calculation.body.result).toBe(42);

            console.log('✅ E2E: Full application smoke test passed');
        });

        test('E2E: Performance and Load Simulation', async () => {
            // Simulate multiple concurrent requests
            const promises = [];
            
            for (let i = 0; i < 10; i++) {
                promises.push(
                    request(server)
                        .post('/api/calculate/add')
                        .send({ a: i, b: i * 2 })
                );
            }

            const results = await Promise.all(promises);
            
            results.forEach((response, index) => {
                expect(response.status).toBe(200);
                expect(response.body.result).toBe(index + (index * 2)); // i + i*2
            });

            console.log('✅ E2E: Concurrent request handling works');
        });

        test('E2E: Data Flow Integration', async () => {
            // Test data flow between all components
            
            // 1. Create user through API
            const user = await request(server)
                .post('/api/users')
                .send({
                    name: 'Data Flow Test',
                    email: 'dataflow@test.com'
                });

            const userId = user.body.user.id;

            // 2. Use UI components to process user data
            const userCard = new UserCard(user.body.user);
            const contactInfo = userCard.getContactInfo();
            expect(contactInfo.length).toBeGreaterThan(0);

            // 3. Perform calculations with user data
            const calc = await request(server)
                .post('/api/calculate/multiply')
                .send({ a: userId, b: 2 });

            expect(calc.body.result).toBe(userId * 2);

            // 4. Update user with calculated data (ensure valid phone format)
            const phoneNumber = `+1555${String(calc.body.result).padStart(6, '0')}`;
            await request(server)
                .put(`/api/users/${userId}`)
                .send({ phone: phoneNumber });

            // 5. Verify end-to-end data flow
            const finalUser = await request(server).get(`/api/users/${userId}`);
            expect(finalUser.body.user.phone).toBe(phoneNumber);

            // Clean up
            await request(server).delete(`/api/users/${userId}`);

            console.log('✅ E2E: Complete data flow integration verified');
        });
    });
});