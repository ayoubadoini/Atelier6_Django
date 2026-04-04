#!/bin/bash
set -e

echo "🚀 Initialisation de l'application Django..."

# Attendre que la BD soit prête (max 30 secondes)
echo "⏳ En attente de la base de données..."
for i in {1..30}; do
    if python -c "import os, psycopg2; psycopg2.connect(os.environ.get('DATABASE_URL', ''))" 2>/dev/null; then
        echo "✅ Base de données prête!"
        break
    fi
    echo "Tentative $i/30..."
    sleep 1
done

# Appliquer les migrations
echo "📦 Applying migrations..."
python manage.py migrate --noinput || echo "⚠️  Migrations failed, continuing anyway..."

# Collecter les fichiers statiques
echo "📁 Collecting static files..."
python manage.py collectstatic --noinput --clear || echo "⚠️  Collectstatic failed, continuing anyway..."

# Créer un superuser si n'existe pas
echo "👤 Checking superuser..."
python manage.py shell << END
import os
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

