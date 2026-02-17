import React from 'react';
import { render, screen, waitFor } from '@testing-library/react';
import axios from 'axios';
import App from './App';

jest.mock('axios');

describe('App Component', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  test('renders dashboard title', () => {
    axios.get.mockResolvedValue({ 
      data: { status: 'healthy', predictions: [] } 
    });
    
    render(<App />);
    expect(screen.getByText(/Analytics Dashboard/i)).toBeInTheDocument();
  });

  test('displays API health status', async () => {
    axios.get.mockResolvedValue({
      data: { status: 'healthy', predictions: [] }
    });

    render(<App />);
    
    await waitFor(() => {
      expect(screen.getByText(/healthy/i)).toBeInTheDocument();
    });
  });

  test('displays predictions when loaded', async () => {
    axios.get.mockImplementation((url) => {
      if (url.includes('health')) {
        return Promise.resolve({ data: { status: 'healthy' } });
      }
      return Promise.resolve({
        data: {
          predictions: [
            { label: 'cats', confidence: 0.95 },
            { label: 'dogs', confidence: 0.87 }
          ]
        }
      });
    });

    render(<App />);

    await waitFor(() => {
      expect(screen.getByText(/cats: 0.95/i)).toBeInTheDocument();
      expect(screen.getByText(/dogs: 0.87/i)).toBeInTheDocument();
    });
  });

  test('handles API errors gracefully', async () => {
    axios.get.mockRejectedValue(new Error('Network error'));

    render(<App />);

    await waitFor(() => {
      expect(screen.getByText(/error/i)).toBeInTheDocument();
    });
  });
});
