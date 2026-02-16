// Library utilities that other components depend on
class Calculator {
    add(a, b) {
        if (typeof a !== 'number' || typeof b !== 'number') {
            throw new Error('Both arguments must be numbers');
        }
        return a + b;
    }

    subtract(a, b) {
        if (typeof a !== 'number' || typeof b !== 'number') {
            throw new Error('Both arguments must be numbers');
        }
        return a - b;
    }

    multiply(a, b) {
        if (typeof a !== 'number' || typeof b !== 'number') {
            throw new Error('Both arguments must be numbers');
        }
        return a * b;
    }

    divide(a, b) {
        if (typeof a !== 'number' || typeof b !== 'number') {
            throw new Error('Both arguments must be numbers');
        }
        if (b === 0) {
            throw new Error('Cannot divide by zero');
        }
        return a / b;
    }
}

class DataValidator {
    isEmail(email) {
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        return emailRegex.test(email);
    }

    isPhoneNumber(phone) {
        const phoneRegex = /^\+?[\d\s\-\(\)]{10,}$/;
        return phoneRegex.test(phone);
    }

    isUrl(url) {
        try {
            new URL(url);
            return true;
        } catch {
            return false;
        }
    }

    sanitizeString(str) {
        if (typeof str !== 'string') {
            return '';
        }
        return str.trim().replace(/[<>]/g, '');
    }
}

module.exports = {
    Calculator,
    DataValidator
};