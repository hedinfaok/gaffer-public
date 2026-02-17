import React, { useState, useEffect } from 'react';
import {
  User,
  ApiResponse,
  formatTimestamp,
} from '../../../shared-lib/dist/index';

const API_BASE = 'http://localhost:4000';

const App: React.FC = () => {
  const [users, setUsers] = useState<User[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    fetchUsers();
  }, []);

  const fetchUsers = async () => {
    try {
      setLoading(true);
      setError(null);
      const response = await fetch(`${API_BASE}/api/users`);
      const json: ApiResponse<User[]> = await response.json();

      if (json.success && json.data) {
        setUsers(json.data);
      } else {
        setError(json.error || 'Failed to fetch users');
      }
    } catch (err) {
      setError('Failed to connect to API service');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div style={{ padding: '20px' }}>
      <h1>👥 User Management</h1>
      <p style={{ color: '#666' }}>
        Frontend built with React, using shared-lib utilities
      </p>

      {loading && <p>Loading users...</p>}
      {error && <p style={{ color: 'red' }}>Error: {error}</p>}

      {!loading && !error && (
        <div>
          <h2>Users ({users.length})</h2>
          {users.map((user) => (
            <div
              key={user.id}
              style={{
                background: 'white',
                padding: '15px',
                marginBottom: '10px',
                borderRadius: '8px',
                boxShadow: '0 2px 4px rgba(0,0,0,0.1)',
              }}
            >
              <h3 style={{ margin: '0 0 10px 0' }}>{user.name}</h3>
              <p style={{ margin: '5px 0', color: '#666' }}>
                📧 {user.email}
              </p>
              <p style={{ margin: '5px 0', color: '#999', fontSize: '0.9em' }}>
                🕐 Created: {formatTimestamp(new Date(user.createdAt).getTime())}
              </p>
            </div>
          ))}
        </div>
      )}

      <button
        onClick={fetchUsers}
        style={{
          marginTop: '20px',
          padding: '10px 20px',
          background: '#007bff',
          color: 'white',
          border: 'none',
          borderRadius: '4px',
          cursor: 'pointer',
        }}
      >
        🔄 Refresh
      </button>
    </div>
  );
};

export default App;
