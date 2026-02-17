import express from 'express';
import cors from 'cors';
import {
  User,
  createSuccessResponse,
  createErrorResponse,
  isValidEmail,
  generateId,
} from '../../../shared-lib/dist/index';

const app = express();
const PORT = 4000;

// Middleware
app.use(cors());
app.use(express.json());

// In-memory user storage
const users: User[] = [
  {
    id: '1',
    name: 'Alice Johnson',
    email: 'alice@example.com',
    createdAt: new Date('2024-01-15'),
  },
  {
    id: '2',
    name: 'Bob Smith',
    email: 'bob@example.com',
    createdAt: new Date('2024-02-20'),
  },
];

// Routes
app.get('/health', (req, res) => {
  res.json(createSuccessResponse({ status: 'healthy', service: 'api-service' }));
});

app.get('/api/users', (req, res) => {
  res.json(createSuccessResponse(users));
});

app.get('/api/users/:id', (req, res) => {
  const user = users.find((u) => u.id === req.params.id);
  if (!user) {
    return res.status(404).json(createErrorResponse('User not found'));
  }
  res.json(createSuccessResponse(user));
});

app.post('/api/users', (req, res) => {
  const { name, email } = req.body;

  if (!name || !email) {
    return res.status(400).json(createErrorResponse('Name and email are required'));
  }

  if (!isValidEmail(email)) {
    return res.status(400).json(createErrorResponse('Invalid email format'));
  }

  const newUser: User = {
    id: generateId(),
    name,
    email,
    createdAt: new Date(),
  };

  users.push(newUser);
  res.status(201).json(createSuccessResponse(newUser));
});

app.listen(PORT, () => {
  console.log(`🚀 API service running on http://localhost:${PORT}`);
  console.log(`📊 Health check: http://localhost:${PORT}/health`);
  console.log(`👥 Users endpoint: http://localhost:${PORT}/api/users`);
});
