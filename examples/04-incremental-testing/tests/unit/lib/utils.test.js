const { Calculator, DataValidator } = require('@/lib/utils.js');

describe('Calculator', () => {
    let calculator;

    beforeEach(() => {
        calculator = new Calculator();
    });

    describe('add', () => {
        test('should add two positive numbers correctly', () => {
            expect(calculator.add(2, 3)).toBe(5);
        });

        test('should handle negative numbers', () => {
            expect(calculator.add(-2, 3)).toBe(1);
            expect(calculator.add(-2, -3)).toBe(-5);
        });

        test('should handle decimal numbers', () => {
            expect(calculator.add(2.5, 3.7)).toBeCloseTo(6.2);
        });

        test('should throw error for non-numeric inputs', () => {
            expect(() => calculator.add('2', 3)).toThrow('Both arguments must be numbers');
            expect(() => calculator.add(2, '3')).toThrow('Both arguments must be numbers');
            expect(() => calculator.add(null, 3)).toThrow('Both arguments must be numbers');
        });
    });

    describe('subtract', () => {
        test('should subtract numbers correctly', () => {
            expect(calculator.subtract(5, 3)).toBe(2);
        });

        test('should handle negative results', () => {
            expect(calculator.subtract(3, 5)).toBe(-2);
        });

        test('should throw error for non-numeric inputs', () => {
            expect(() => calculator.subtract('5', 3)).toThrow('Both arguments must be numbers');
        });
    });

    describe('multiply', () => {
        test('should multiply numbers correctly', () => {
            expect(calculator.multiply(4, 3)).toBe(12);
        });

        test('should handle zero multiplication', () => {
            expect(calculator.multiply(5, 0)).toBe(0);
            expect(calculator.multiply(0, 5)).toBe(0);
        });

        test('should handle negative multiplication', () => {
            expect(calculator.multiply(-3, 4)).toBe(-12);
            expect(calculator.multiply(-3, -4)).toBe(12);
        });
    });

    describe('divide', () => {
        test('should divide numbers correctly', () => {
            expect(calculator.divide(10, 2)).toBe(5);
        });

        test('should handle decimal results', () => {
            expect(calculator.divide(10, 3)).toBeCloseTo(3.333, 3);
        });

        test('should throw error on division by zero', () => {
            expect(() => calculator.divide(10, 0)).toThrow('Cannot divide by zero');
        });

        test('should throw error for non-numeric inputs', () => {
            expect(() => calculator.divide('10', 2)).toThrow('Both arguments must be numbers');
        });
    });
});

describe('DataValidator', () => {
    let validator;

    beforeEach(() => {
        validator = new DataValidator();
    });

    describe('isEmail', () => {
        test('should validate correct email addresses', () => {
            expect(validator.isEmail('user@example.com')).toBe(true);
            expect(validator.isEmail('test.email+tag@domain.co.uk')).toBe(true);
        });

        test('should reject invalid email addresses', () => {
            expect(validator.isEmail('invalid-email')).toBe(false);
            expect(validator.isEmail('@domain.com')).toBe(false);
            expect(validator.isEmail('user@')).toBe(false);
            expect(validator.isEmail('')).toBe(false);
        });
    });

    describe('isPhoneNumber', () => {
        test('should validate correct phone numbers', () => {
            expect(validator.isPhoneNumber('+1234567890')).toBe(true);
            expect(validator.isPhoneNumber('123-456-7890')).toBe(true);
            expect(validator.isPhoneNumber('(123) 456-7890')).toBe(true);
        });

        test('should reject invalid phone numbers', () => {
            expect(validator.isPhoneNumber('123')).toBe(false);
            expect(validator.isPhoneNumber('abc-def-ghij')).toBe(false);
            expect(validator.isPhoneNumber('')).toBe(false);
        });
    });

    describe('isUrl', () => {
        test('should validate correct URLs', () => {
            expect(validator.isUrl('https://example.com')).toBe(true);
            expect(validator.isUrl('http://localhost:3000')).toBe(true);
            expect(validator.isUrl('ftp://files.example.com')).toBe(true);
        });

        test('should reject invalid URLs', () => {
            expect(validator.isUrl('not-a-url')).toBe(false);
            expect(validator.isUrl('http://')).toBe(false);
            expect(validator.isUrl('')).toBe(false);
        });
    });

    describe('sanitizeString', () => {
        test('should remove dangerous characters', () => {
            expect(validator.sanitizeString('<script>alert("xss")</script>'))
                .toBe('scriptalert("xss")/script');
            expect(validator.sanitizeString('Normal string')).toBe('Normal string');
        });

        test('should trim whitespace', () => {
            expect(validator.sanitizeString('  trimmed  ')).toBe('trimmed');
        });

        test('should handle non-string inputs', () => {
            expect(validator.sanitizeString(123)).toBe('');
            expect(validator.sanitizeString(null)).toBe('');
            expect(validator.sanitizeString(undefined)).toBe('');
        });
    });
});