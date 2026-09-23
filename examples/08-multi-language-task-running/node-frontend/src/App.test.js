import React from 'react';
import { renderToString } from 'react-dom/server';
import App from './App';

describe('App component', () => {
  test('renders the dashboard title', () => {
    const html = renderToString(<App />);
    expect(html).toContain('Analytics Dashboard');
  });

  test('shows the loading state before data arrives', () => {
    const html = renderToString(<App />);
    expect(html).toContain('Loading...');
  });

  test('renders the predictions section heading', () => {
    const html = renderToString(<App />);
    expect(html).toContain('Latest Predictions');
  });
});
