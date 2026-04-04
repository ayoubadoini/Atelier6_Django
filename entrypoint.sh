#!/bin/bash
set -e

echo "🚀 Démarrage de l'application Django..."

# Collecter les fichiers statiques
echo "📁 Collecting static files..."
python manage.py collectstatic --noinput --clear 2>/dev/null || true

echo "✅ Setup completed!"
echo "🎯 Starting Gunicorn..."

# Lancer Gunicorn
exec gunicorn monprojet.wsgi:application --bind 0.0.0.0:8000 --workers 3

