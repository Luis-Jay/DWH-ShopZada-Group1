# Airflow Webserver Configuration
# This file configures the Flask webserver for Airflow

# Fix for Airflow 2.7.3 session issues - use basic Flask session
import os

# Use database session backend for Airflow 2.7.3 compatibility
SESSION_TYPE = 'database'
SESSION_PERMANENT = False
SESSION_USE_SIGNER = False

# Flask configuration
SECRET_KEY = 'airflow-webserver-secret-key-2025'
MAX_CONTENT_LENGTH = 100 * 1024 * 1024  # 100MB max file size

# Session configuration
SESSION_COOKIE_SECURE = False
SESSION_COOKIE_HTTPONLY = True
SESSION_COOKIE_SAMESITE = 'Lax'
