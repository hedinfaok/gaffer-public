const { UserService } = require('@/api/userService.js');

describe('UserService', () => {
    let userService;

    beforeEach(() => {
        userService = new UserService();
    });

    describe('getAllUsers', () => {
        test('should return all users', () => {
            const users = userService.getAllUsers();
            expect(users).toHaveLength(2);
            expect(users[0]).toHaveProperty('name', 'Alice');
            expect(users[1]).toHaveProperty('name', 'Bob');
        });

        test('should return a copy of users array', () => {
            const users1 = userService.getAllUsers();
            const users2 = userService.getAllUsers();
            expect(users1).not.toBe(users2);
            expect(users1).toEqual(users2);
        });
    });

    describe('getUserById', () => {
        test('should return user with correct id', () => {
            const user = userService.getUserById(1);
            expect(user).toHaveProperty('name', 'Alice');
            expect(user).toHaveProperty('email', 'alice@example.com');
        });

        test('should handle string ids', () => {
            const user = userService.getUserById('2');
            expect(user).toHaveProperty('name', 'Bob');
        });

        test('should throw error for non-existent user', () => {
            expect(() => userService.getUserById(999)).toThrow('User not found');
        });

        test('should return a copy of user object', () => {
            const user = userService.getUserById(1);
            user.name = 'Modified';
            const user2 = userService.getUserById(1);
            expect(user2.name).toBe('Alice'); // Original should be unchanged
        });
    });

    describe('createUser', () => {
        test('should create user with valid data', () => {
            const userData = {
                name: 'Charlie',
                email: 'charlie@example.com',
                phone: '+1122334455'
            };
            
            const user = userService.createUser(userData);
            expect(user).toHaveProperty('id', 3);
            expect(user).toHaveProperty('name', 'Charlie');
            expect(user).toHaveProperty('email', 'charlie@example.com');
        });

        test('should create user without phone number', () => {
            const userData = {
                name: 'Dave',
                email: 'dave@example.com'
            };
            
            const user = userService.createUser(userData);
            expect(user).toHaveProperty('phone', null);
        });

        test('should sanitize user name', () => {
            const userData = {
                name: '  <script>Charlie</script>  ',
                email: 'charlie@example.com'
            };
            
            const user = userService.createUser(userData);
            expect(user.name).toBe('scriptCharlie/script');
        });

        test('should normalize email to lowercase', () => {
            const userData = {
                name: 'Charlie',
                email: 'CHARLIE@EXAMPLE.COM'
            };
            
            const user = userService.createUser(userData);
            expect(user.email).toBe('charlie@example.com');
        });

        test('should throw error for missing name', () => {
            const userData = {
                email: 'test@example.com'
            };
            
            expect(() => userService.createUser(userData)).toThrow('Name and email are required');
        });

        test('should throw error for missing email', () => {
            const userData = {
                name: 'Test User'
            };
            
            expect(() => userService.createUser(userData)).toThrow('Name and email are required');
        });

        test('should throw error for invalid email format', () => {
            const userData = {
                name: 'Test User',
                email: 'invalid-email'
            };
            
            expect(() => userService.createUser(userData)).toThrow('Invalid email format');
        });

        test('should throw error for invalid phone number', () => {
            const userData = {
                name: 'Test User',
                email: 'test@example.com',
                phone: '123' // Too short
            };
            
            expect(() => userService.createUser(userData)).toThrow('Invalid phone number format');
        });

        test('should throw error for duplicate email', () => {
            const userData = {
                name: 'Test User',
                email: 'alice@example.com' // Already exists
            };
            
            expect(() => userService.createUser(userData)).toThrow('Email already exists');
        });
    });

    describe('updateUser', () => {
        test('should update user successfully', () => {
            const updates = {
                name: 'Alice Updated',
                phone: '+9999999999'
            };
            
            const user = userService.updateUser(1, updates);
            expect(user).toHaveProperty('name', 'Alice Updated');
            expect(user).toHaveProperty('phone', '+9999999999');
            expect(user).toHaveProperty('email', 'alice@example.com'); // Unchanged
        });

        test('should validate email on update', () => {
            const updates = {
                email: 'invalid-email'
            };
            
            expect(() => userService.updateUser(1, updates)).toThrow('Invalid email format');
        });

        test('should validate phone on update', () => {
            const updates = {
                phone: '123invalid'
            };
            
            expect(() => userService.updateUser(1, updates)).toThrow('Invalid phone number format');
        });

        test('should throw error for non-existent user', () => {
            const updates = { name: 'Test' };
            expect(() => userService.updateUser(999, updates)).toThrow('User not found');
        });
    });

    describe('deleteUser', () => {
        test('should delete user successfully', () => {
            const deletedUser = userService.deleteUser(1);
            expect(deletedUser).toHaveProperty('name', 'Alice');
            
            // Verify user is deleted
            expect(() => userService.getUserById(1)).toThrow('User not found');
            expect(userService.getAllUsers()).toHaveLength(1);
        });

        test('should throw error for non-existent user', () => {
            expect(() => userService.deleteUser(999)).toThrow('User not found');
        });
    });
});