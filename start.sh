#! /usr/bin/env bash
set -eu
if [ ${MODE:-""} == "development" ]; then 
    if [ -f /app/requirements.txt ]; then pip install -r /app/requirements.txt; fi
    exec uvicorn web:app --reload  --reload-dir /app --host 0.0.0.0 --port 80
else 
    exec gunicorn -k uvicorn.workers.UvicornWorker -c "$GUNICORN_CONF" "$APP_MODULE"
fi