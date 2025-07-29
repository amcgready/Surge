# Setup WebUI Deployment Script
# This script builds and launches the Flask API backend and React frontend for the Surge setup tool.

# Exit on error
set -e

# Navigate to the setup-webui directory
cd "$(dirname "$0")/../setup-webui"

# Build/start backend (Flask)
echo "[1/3] Setting up Python backend..."
cd backend
python3 -m venv venv
. venv/bin/activate
pip install --upgrade pip
pip install flask flask-cors
# Optionally install other backend dependencies here
cd ..

# Build/start frontend (React)
echo "[2/3] Setting up React frontend..."
cd frontend
if [ ! -d "node_modules" ]; then
  npm install -g npm@latest
  npm install -g create-react-app
  npx create-react-app . --template cra-template-pwa-typescript
  npm install axios
  # Optionally install other frontend dependencies here
fi
cd ..

# Start both servers (backend in background, frontend in foreground)
echo "[3/3] Launching setup web UI..."
cd backend
. venv/bin/activate
FLASK_APP=app.py flask run --host=0.0.0.0 --port=5001 &
cd ../frontend
npm start

echo "Setup is running. Access it at http://localhost:3000"
