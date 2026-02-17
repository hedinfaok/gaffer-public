import React, { useState, useEffect } from 'react';
import axios from 'axios';

/**
 * Dashboard component that displays ML predictions and API health
 */
function App() {
  const [predictions, setPredictions] = useState([]);
  const [apiHealth, setApiHealth] = useState('unknown');
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchData();
    const interval = setInterval(fetchData, 5000);
    return () => clearInterval(interval);
  }, []);

  const fetchData = async () => {
    try {
      const [healthRes, predictionsRes] = await Promise.all([
        axios.get('http://localhost:8080/health'),
        axios.get('http://localhost:8080/predictions')
      ]);
      
      setApiHealth(healthRes.data.status);
      setPredictions(predictionsRes.data.predictions);
      setLoading(false);
    } catch (error) {
      console.error('Failed to fetch data:', error);
      setApiHealth('error');
      setLoading(false);
    }
  };

  return (
    <div className="dashboard">
      <h1>Analytics Dashboard</h1>
      <div className="status">
        API Status: <span className={apiHealth}>{apiHealth}</span>
      </div>
      <div className="predictions">
        <h2>Latest Predictions</h2>
        {loading ? (
          <p>Loading...</p>
        ) : (
          <ul>
            {predictions.map((pred, idx) => (
              <li key={idx}>
                {pred.label}: {pred.confidence.toFixed(2)}
              </li>
            ))}
          </ul>
        )}
      </div>
    </div>
  );
}

export default App;
