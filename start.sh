#!/bin/bash

# Set default port if PORT environment variable is not set
export PORT=${PORT:-8000}

# Start the application
exec uvicorn main:app --host 0.0.0.0 --port $PORT --workers 1
