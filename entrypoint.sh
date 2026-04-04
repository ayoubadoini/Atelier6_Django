#!/bin/bash
set -e

echo "🚀 Initialisation de l'application Django..."

# Appliquer les migrations
echo "📦 Applying migrations..."
python manage.py migrate

# Collecter les fichiers statiques
echo "📁 Collecting static files..."
python manage.py collectstatic --noinput --clear

# Créer un superuser si n'existe pas
echo "👤 Creating superuser if needed..."
python manage.py shell << END
from django.contrib.auth.models import User
if not User.objects.filter(username='admin').exists():
    User.objects.create_superuser('admin', 'admin@example.com', 'admin123')
    print("✅ Superuser 'admin' created with password 'admin123'")
else:
    print("ℹ️  Superuser 'admin' already exists")
END

echo "✅ Setup completed!"
echo "🎯 Starting Gunicorn..."

# Lancer Gunicorn
exec gunicorn monprojet.wsgi:application --bind 0.0.0.0:8000 --workers 3
