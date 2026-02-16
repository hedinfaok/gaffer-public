import React, { useState, useEffect } from 'react';
import axios from 'axios';
import './App.css';

// Get API URL from environment or use default
const API_URL = process.env.REACT_APP_API_URL || `http://localhost:${process.env.REACT_APP_API_PORT || 3001}`;

function App() {
  const [tasks, setTasks] = useState([]);
  const [users, setUsers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [newTask, setNewTask] = useState({ title: '', description: '', status: 'pending' });
  const [showAddForm, setShowAddForm] = useState(false);
  const [apiHealth, setApiHealth] = useState(null);

  // Fetch tasks from API
  const fetchTasks = async () => {
    try {
      const response = await axios.get(`${API_URL}/api/tasks`);
      setTasks(response.data);
    } catch (err) {
      console.error('Error fetching tasks:', err);
      setError('Failed to fetch tasks');
    }
  };

  // Fetch users from API
  const fetchUsers = async () => {
    try {
      const response = await axios.get(`${API_URL}/api/users`);
      setUsers(response.data);
    } catch (err) {
      console.error('Error fetching users:', err);
    }
  };

  // Check API health
  const checkApiHealth = async () => {
    try {
      const response = await axios.get(`${API_URL}/health`);
      setApiHealth(response.data);
    } catch (err) {
      console.error('API health check failed:', err);
      setApiHealth({ status: 'ERROR', error: err.message });
    }
  };

  // Load initial data
  useEffect(() => {
    const loadData = async () => {
      setLoading(true);
      await Promise.all([
        fetchTasks(),
        fetchUsers(), 
        checkApiHealth()
      ]);
      setLoading(false);
    };
    loadData();
  }, []);

  // Add new task
  const handleAddTask = async (e) => {
    e.preventDefault();
    try {
      await axios.post(`${API_URL}/api/tasks`, newTask);
      setNewTask({ title: '', description: '', status: 'pending' });
      setShowAddForm(false);
      await fetchTasks(); // Refresh tasks
    } catch (err) {
      console.error('Error adding task:', err);
      setError('Failed to add task');
    }
  };

  // Update task status
  const handleUpdateTaskStatus = async (taskId, newStatus) => {
    try {
      await axios.put(`${API_URL}/api/tasks/${taskId}`, { status: newStatus });
      await fetchTasks(); // Refresh tasks
    } catch (err) {
      console.error('Error updating task:', err);
      setError('Failed to update task');
    }
  };

  // Delete task
  const handleDeleteTask = async (taskId) => {
    if (!window.confirm('Are you sure you want to delete this task?')) {
      return;
    }
    try {
      await axios.delete(`${API_URL}/api/tasks/${taskId}`);
      await fetchTasks(); // Refresh tasks
    } catch (err) {
      console.error('Error deleting task:', err);
      setError('Failed to delete task');
    }
  };

  const getStatusColor = (status) => {
    switch (status) {
      case 'completed': return '#4CAF50';
      case 'in_progress': return '#FF9800';
      case 'pending': return '#2196F3';
      default: return '#757575';
    }
  };

  if (loading) {
    return (
      <div className="App">
        <div className="container">
          <h1>Task Manager</h1>
          <div className="loading">Loading...</div>
        </div>
      </div>
    );
  }

  return (
    <div className="App">
      <header className="App-header">
        <div className="container">
          <h1>🚀 Task Manager</h1>
          <p className="subtitle">Local Development Environment Demo</p>
          
          {/* API Health Status */}
          {apiHealth && (
            <div className={`health-status ${apiHealth.status.toLowerCase()}`}>
              <strong>API Status:</strong> {apiHealth.status}
              {apiHealth.timestamp && (
                <span className="timestamp"> (Last checked: {new Date(apiHealth.timestamp).toLocaleTimeString()})</span>
              )}
            </div>
          )}
        </div>
      </header>

      <main className="container">
        {error && (
          <div className="error">
            {error}
            <button onClick={() => setError(null)}>×</button>
          </div>
        )}

        {/* Stats Section */}
        <div className="stats">
          <div className="stat-card">
            <h3>📋 Total Tasks</h3>
            <span className="stat-number">{tasks.length}</span>
          </div>
          <div className="stat-card">
            <h3>✅ Completed</h3>
            <span className="stat-number">{tasks.filter(t => t.status === 'completed').length}</span>
          </div>
          <div className="stat-card">
            <h3>⭏ In Progress</h3>
            <span className="stat-number">{tasks.filter(t => t.status === 'in_progress').length}</span>
          </div>
          <div className="stat-card">
            <h3>👥 Users</h3>
            <span className="stat-number">{users.length}</span>
          </div>
        </div>

        {/* Add Task Section */}
        <div className="add-task-section">
          <button 
            className="add-task-btn"
            onClick={() => setShowAddForm(!showAddForm)}
          >
            {showAddForm ? '✕ Cancel' : '+ Add New Task'}
          </button>
          
          {showAddForm && (
            <form onSubmit={handleAddTask} className="add-task-form">
              <input
                type="text"
                placeholder="Task title"
                value={newTask.title}
                onChange={(e) => setNewTask({...newTask, title: e.target.value})}
                required
              />
              <textarea
                placeholder="Task description"
                value={newTask.description}
                onChange={(e) => setNewTask({...newTask, description: e.target.value})}
                rows="3"
              />
              <select
                value={newTask.status}
                onChange={(e) => setNewTask({...newTask, status: e.target.value})}
              >
                <option value="pending">Pending</option>
                <option value="in_progress">In Progress</option>
                <option value="completed">Completed</option>
              </select>
              <button type="submit">Add Task</button>
            </form>
          )}
        </div>

        {/* Tasks List */}
        <div className="tasks-section">
          <h2>📋 Tasks</h2>
          
          {tasks.length === 0 ? (
            <div className="empty-state">
              <p>No tasks found. Add your first task above!</p>
            </div>
          ) : (
            <div className="tasks-grid">
              {tasks.map((task) => (
                <div key={task.id} className="task-card">
                  <div className="task-header">
                    <h3>{task.title}</h3>
                    <span 
                      className="task-status"
                      style={{ backgroundColor: getStatusColor(task.status) }}
                    >
                      {task.status.replace('_', ' ')}
                    </span>
                  </div>
                  
                  {task.description && (
                    <p className="task-description">{task.description}</p>
                  )}
                  
                  <div className="task-meta">
                    <span>Created: {new Date(task.created_at).toLocaleDateString()}</span>
                    {task.updated_at !== task.created_at && (
                      <span>Updated: {new Date(task.updated_at).toLocaleDateString()}</span>
                    )}
                  </div>
                  
                  <div className="task-actions">
                    <select
                      value={task.status}
                      onChange={(e) => handleUpdateTaskStatus(task.id, e.target.value)}
                    >
                      <option value="pending">Pending</option>
                      <option value="in_progress">In Progress</option>
                      <option value="completed">Completed</option>
                    </select>
                    <button 
                      onClick={() => handleDeleteTask(task.id)}
                      className="delete-btn"
                    >
                      Delete
                    </button>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>

        {/* Development Info */}
        <div className="dev-info">
          <h2>🛠️ Development Environment</h2>
          <div className="dev-stats">
            <div><strong>API URL:</strong> {API_URL}</div>
            <div><strong>Frontend Port:</strong> {window.location.port}</div>
            <div><strong>Users in System:</strong> {users.map(u => u.name).join(', ')}</div>
          </div>
        </div>
      </main>
    </div>
  );
}

export default App;