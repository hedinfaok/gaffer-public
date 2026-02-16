// Simple UI component class for demonstration
class UserCard {
    constructor(user) {
        this.user = user;
    }

    render() {
        if (!this.user || !this.user.name) {
            throw new Error('User is required for rendering');
        }

        return `
            <div class="user-card" id="user-${this.user.id}">
                <h3>${this.escapeHtml(this.user.name)}</h3>
                <p>Email: ${this.escapeHtml(this.user.email)}</p>
                ${this.user.phone ? `<p>Phone: ${this.escapeHtml(this.user.phone)}</p>` : ''}
            </div>
        `;
    }

    escapeHtml(text) {
        if (typeof text !== 'string') text = String(text);
        return text
            .replace(/&/g, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;')
            .replace(/"/g, '&quot;')
            .replace(/'/g, '&#x27;');
    }

    getDisplayName() {
        return this.user.name || 'Unknown User';
    }

    getContactInfo() {
        const contact = [];
        if (this.user.email) contact.push(`Email: ${this.user.email}`);
        if (this.user.phone) contact.push(`Phone: ${this.user.phone}`);
        return contact;
    }
}

class UserList {
    constructor() {
        this.users = [];
        this.filters = {};
    }

    addUser(user) {
        if (!user || !user.id) {
            throw new Error('User must have an id');
        }
        
        // Check for duplicates
        if (this.users.find(u => u.id === user.id)) {
            throw new Error('User with this id already exists');
        }
        
        this.users.push(user);
    }

    removeUser(userId) {
        const index = this.users.findIndex(u => u.id === userId);
        if (index === -1) {
            throw new Error('User not found');
        }
        
        return this.users.splice(index, 1)[0];
    }

    filterBy(field, value) {
        this.filters[field] = value;
    }

    getFilteredUsers() {
        let filtered = [...this.users];
        
        Object.entries(this.filters).forEach(([field, value]) => {
            if (value) {
                filtered = filtered.filter(user => 
                    user[field] && user[field].toLowerCase().includes(value.toLowerCase())
                );
            }
        });
        
        return filtered;
    }

    render() {
        const filteredUsers = this.getFilteredUsers();
        
        if (filteredUsers.length === 0) {
            return '<div class="user-list empty">No users found</div>';
        }

        const userCards = filteredUsers
            .map(user => new UserCard(user).render())
            .join('\n');

        return `
            <div class="user-list">
                <h2>Users (${filteredUsers.length})</h2>
                ${userCards}
            </div>
        `;
    }

    getUserCount() {
        return this.getFilteredUsers().length;
    }

    getTotalUsers() {
        return this.users.length;
    }
}

class FormValidator {
    constructor() {
        this.rules = {};
        this.errors = {};
    }

    addRule(field, validator, message) {
        if (!this.rules[field]) {
            this.rules[field] = [];
        }
        this.rules[field].push({ validator, message });
    }

    validate(data) {
        this.errors = {};
        
        Object.entries(this.rules).forEach(([field, rules]) => {
            const value = data[field];
            
            rules.forEach(({ validator, message }) => {
                if (!validator(value)) {
                    if (!this.errors[field]) {
                        this.errors[field] = [];
                    }
                    this.errors[field].push(message);
                }
            });
        });
        
        return Object.keys(this.errors).length === 0;
    }

    getErrors() {
        return { ...this.errors };
    }

    hasErrors() {
        return Object.keys(this.errors).length > 0;
    }

    getErrorsFor(field) {
        return this.errors[field] || [];
    }
}

module.exports = {
    UserCard,
    UserList,
    FormValidator
};