#!/bin/bash
set -e

echo "Installing dependencies..."

source .env

# Install API dependencies
echo "Installing API dependencies..."
cd api
npm install
cd ..

# Install frontend dependencies
echo "Installing frontend dependencies..."
cd frontend  
npm install
cd ..

# Install root-level test dependencies
echo "Installing test dependencies..."
npm install

touch node_modules/.installed
echo "✓ All dependencies installed!"