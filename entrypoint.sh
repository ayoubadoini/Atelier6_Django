#!/bin/bash
set -e

echo "🚀 Démarrage de l'application Django..."

# Seulement sur Render (quand DATABASE_URL est défini)
if [ ! -z "$DATABASE_URL" ]; then
    echo "📦 Applying migrations..."
    python manage.py migrate --noinput 2>/dev/null || true
    
    echo "👤 Creating superuser if needed..."
    python manage.py shell << END 2>/dev/null || true
from django.contrib.auth.models import User
if not User.objects.filter(username='admin').exists():
    User.objects.create_superuser('admin', 'admin@example.com', 'Admin@12345')
    print("✅ Admin created: admin / Admin@12345")
END
fi

# Collecter les fichiers statiques
echo "📁 Collecting static files..."
python manage.py collectstatic --noinput --clear 2>/dev/null || true

echo "✅ Setup completed!"
echo "🎯 Starting Gunicorn..."

# Lancer Gunicorn
exec gunicorn monprojet.wsgi:application --bind 0.0.0.0:8000 --workers 3

