const { DataValidator } = require('../lib/utils');

class UserService {
    constructor() {
        this.users = [
            { id: 1, name: 'Alice', email: 'alice@example.com', phone: '+1234567890' },
            { id: 2, name: 'Bob', email: 'bob@example.com', phone: '+0987654321' }
        ];
        this.validator = new DataValidator();
    }

    getAllUsers() {
        return [...this.users]; // Return a copy
    }

    getUserById(id) {
        const user = this.users.find(u => u.id === parseInt(id));
        if (!user) {
            throw new Error('User not found');
        }
        return { ...user };
    }

    createUser(userData) {
        const { name, email, phone } = userData;
        
        if (!name || !email) {
            throw new Error('Name and email are required');
        }

        if (!this.validator.isEmail(email)) {
            throw new Error('Invalid email format');
        }

        if (phone && !this.validator.isPhoneNumber(phone)) {
            throw new Error('Invalid phone number format');
        }

        // Check if email already exists
        if (this.users.some(u => u.email === email)) {
            throw new Error('Email already exists');
        }

        const newUser = {
            id: this.users.length + 1,
            name: this.validator.sanitizeString(name),
            email: email.toLowerCase(),
            phone: phone || null
        };

        this.users.push(newUser);
        return { ...newUser };
    }

    updateUser(id, updates) {
        const userIndex = this.users.findIndex(u => u.id === parseInt(id));
        if (userIndex === -1) {
            throw new Error('User not found');
        }

        const user = this.users[userIndex];
        const updatedUser = { ...user, ...updates };

        if (updates.email && !this.validator.isEmail(updates.email)) {
            throw new Error('Invalid email format');
        }

        if (updates.phone && !this.validator.isPhoneNumber(updates.phone)) {
            throw new Error('Invalid phone number format');
        }

        this.users[userIndex] = updatedUser;
        return { ...updatedUser };
    }

    deleteUser(id) {
        const userIndex = this.users.findIndex(u => u.id === parseInt(id));
        if (userIndex === -1) {
            throw new Error('User not found');
        }

        const deletedUser = this.users.splice(userIndex, 1)[0];
        return { ...deletedUser };
    }
}

module.exports = {
    UserService
};