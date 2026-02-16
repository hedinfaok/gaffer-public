const { UserCard, UserList, FormValidator } = require('@/ui/components.js');

describe('UserCard', () => {
    const mockUser = {
        id: 1,
        name: 'John Doe',
        email: 'john@example.com',
        phone: '+1234567890'
    };

    test('should render user card with all information', () => {
        const card = new UserCard(mockUser);
        const html = card.render();
        
        expect(html).toContain('user-card');
        expect(html).toContain('user-1');
        expect(html).toContain('John Doe');
        expect(html).toContain('john@example.com');
        expect(html).toContain('+1234567890');
    });

    test('should render user card without phone', () => {
        const userWithoutPhone = { ...mockUser, phone: null };
        const card = new UserCard(userWithoutPhone);
        const html = card.render();
        
        expect(html).toContain('John Doe');
        expect(html).toContain('john@example.com');
        expect(html).not.toContain('Phone:');
    });

    test('should throw error for missing user', () => {
        expect(() => new UserCard(null).render()).toThrow('User is required for rendering');
        expect(() => new UserCard({}).render()).toThrow('User is required for rendering');
    });

    test('should get display name correctly', () => {
        const card = new UserCard(mockUser);
        expect(card.getDisplayName()).toBe('John Doe');
    });

    test('should handle missing name gracefully', () => {
        const userWithoutName = { ...mockUser, name: null };
        const card = new UserCard(userWithoutName);
        expect(card.getDisplayName()).toBe('Unknown User');
    });

    test('should get contact info correctly', () => {
        const card = new UserCard(mockUser);
        const contact = card.getContactInfo();
        
        expect(contact).toHaveLength(2);
        expect(contact[0]).toBe('Email: john@example.com');
        expect(contact[1]).toBe('Phone: +1234567890');
    });

    test('should get contact info without phone', () => {
        const userWithoutPhone = { ...mockUser, phone: null };
        const card = new UserCard(userWithoutPhone);
        const contact = card.getContactInfo();
        
        expect(contact).toHaveLength(1);
        expect(contact[0]).toBe('Email: john@example.com');
    });
});

describe('UserList', () => {
    let userList;
    const mockUsers = [
        { id: 1, name: 'Alice', email: 'alice@example.com' },
        { id: 2, name: 'Bob', email: 'bob@example.com' },
        { id: 3, name: 'Alicia', email: 'alicia@example.com' }
    ];

    beforeEach(() => {
        userList = new UserList();
    });

    test('should add users successfully', () => {
        userList.addUser(mockUsers[0]);
        expect(userList.getTotalUsers()).toBe(1);
    });

    test('should throw error for user without id', () => {
        const invalidUser = { name: 'Test' };
        expect(() => userList.addUser(invalidUser)).toThrow('User must have an id');
        expect(() => userList.addUser(null)).toThrow('User must have an id');
    });

    test('should throw error for duplicate user ids', () => {
        userList.addUser(mockUsers[0]);
        expect(() => userList.addUser(mockUsers[0])).toThrow('User with this id already exists');
    });

    test('should remove users successfully', () => {
        mockUsers.forEach(user => userList.addUser(user));
        
        const removedUser = userList.removeUser(2);
        expect(removedUser).toEqual(mockUsers[1]);
        expect(userList.getTotalUsers()).toBe(2);
    });

    test('should throw error when removing non-existent user', () => {
        expect(() => userList.removeUser(999)).toThrow('User not found');
    });

    test('should filter users correctly', () => {
        mockUsers.forEach(user => userList.addUser(user));
        
        userList.filterBy('name', 'ali');
        const filtered = userList.getFilteredUsers();
        
        expect(filtered).toHaveLength(2); // Alice and Alicia contain 'ali'
        expect(filtered.map(u => u.name)).toEqual(['Alice', 'Alicia']);
    });

    test('should handle empty filter', () => {
        mockUsers.forEach(user => userList.addUser(user));
        
        userList.filterBy('name', '');
        const filtered = userList.getFilteredUsers();
        
        expect(filtered).toHaveLength(3); // All users returned
    });

    test('should render empty list correctly', () => {
        const html = userList.render();
        expect(html).toContain('user-list empty');
        expect(html).toContain('No users found');
    });

    test('should render user list with users', () => {
        mockUsers.forEach(user => userList.addUser(user));
        
        const html = userList.render();
        expect(html).toContain('user-list');
        expect(html).toContain('Users (3)');
        expect(html).toContain('Alice');
        expect(html).toContain('Bob');
        expect(html).toContain('Alicia');
    });

    test('should render filtered user list', () => {
        mockUsers.forEach(user => userList.addUser(user));
        userList.filterBy('name', 'Bob');
        
        const html = userList.render();
        expect(html).toContain('Users (1)');
        expect(html).toContain('Bob');
        expect(html).not.toContain('Alice');
    });

    test('should get correct user counts', () => {
        mockUsers.forEach(user => userList.addUser(user));
        
        expect(userList.getTotalUsers()).toBe(3);
        expect(userList.getUserCount()).toBe(3);
        
        userList.filterBy('name', 'Alice');
        expect(userList.getTotalUsers()).toBe(3); // Total unchanged
        expect(userList.getUserCount()).toBe(1); // Filtered count
    });
});

describe('FormValidator', () => {
    let validator;

    beforeEach(() => {
        validator = new FormValidator();
    });

    test('should add validation rules', () => {
        validator.addRule('name', value => value && value.length > 0, 'Name is required');
        validator.addRule('email', value => value && value.includes('@'), 'Valid email required');
        
        expect(validator.rules).toHaveProperty('name');
        expect(validator.rules).toHaveProperty('email');
    });

    test('should validate data successfully', () => {
        validator.addRule('name', value => value && value.length > 0, 'Name is required');
        validator.addRule('email', value => value && value.includes('@'), 'Valid email required');
        
        const validData = { name: 'John', email: 'john@example.com' };
        const isValid = validator.validate(validData);
        
        expect(isValid).toBe(true);
        expect(validator.hasErrors()).toBe(false);
    });

    test('should collect validation errors', () => {
        validator.addRule('name', value => value && value.length > 0, 'Name is required');
        validator.addRule('email', value => value && value.includes('@'), 'Valid email required');
        
        const invalidData = { name: '', email: 'invalid-email' };
        const isValid = validator.validate(invalidData);
        
        expect(isValid).toBe(false);
        expect(validator.hasErrors()).toBe(true);
        
        const errors = validator.getErrors();
        expect(errors.name).toContain('Name is required');
        expect(errors.email).toContain('Valid email required');
    });

    test('should handle multiple rules per field', () => {
        validator.addRule('password', value => value && value.length >= 8, 'Password must be at least 8 characters');
        validator.addRule('password', value => /[A-Z]/.test(value), 'Password must contain uppercase letter');
        validator.addRule('password', value => /[0-9]/.test(value), 'Password must contain number');
        
        const invalidData = { password: 'short' };
        validator.validate(invalidData);
        
        const passwordErrors = validator.getErrorsFor('password');
        expect(passwordErrors).toHaveLength(3);
        expect(passwordErrors).toContain('Password must be at least 8 characters');
        expect(passwordErrors).toContain('Password must contain uppercase letter');
        expect(passwordErrors).toContain('Password must contain number');
    });

    test('should get errors for specific field', () => {
        validator.addRule('email', value => value && value.includes('@'), 'Valid email required');
        
        validator.validate({ email: 'invalid' });
        
        expect(validator.getErrorsFor('email')).toContain('Valid email required');
        expect(validator.getErrorsFor('nonexistent')).toEqual([]);
    });

    test('should reset errors on new validation', () => {
        validator.addRule('name', value => value && value.length > 0, 'Name is required');
        
        // First validation with error
        validator.validate({ name: '' });
        expect(validator.hasErrors()).toBe(true);
        
        // Second validation without error
        validator.validate({ name: 'John' });
        expect(validator.hasErrors()).toBe(false);
    });
});