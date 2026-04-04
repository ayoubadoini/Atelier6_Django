#!/bin/bash
set -e

echo "🚀 Démarrage de l'application Django..."

# Sur Render - attendre la BD et appliquer les migrations
if [ ! -z "$DATABASE_URL" ]; then
    echo "⏳ Attente de PostgreSQL..."
    python wait_for_db.py || {
        echo "⚠️  BD non disponible immédiatement, mais on continue..."
    }
    
    echo "📦 Application des migrations..."
    python manage.py migrate --noinput --verbosity 2 || {
        echo "❌ Migrations failed! Database may not be ready yet."
    }
    
    echo "👤 Création superuser si nécessaire..."
    python << 'END' || true
import os
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'monprojet.settings')
import django
django.setup()

from django.contrib.auth.models import User
try:
    if not User.objects.filter(username='admin').exists():
        User.objects.create_superuser('admin', 'admin@example.com', 'Admin@12345')
        print("✅ Admin créé: admin / Admin@12345")
    else:
        print("✅ Admin existe déjà")
except Exception as e:
    print(f"⚠️ Superuser error: {e}")
END
fi

echo "📁 Collecte des fichiers statiques..."
python manage.py collectstatic --noinput --clear --verbosity 0 2>&1 | tail -3 || true

echo "✅ Setup terminé!"
echo "🎯 Démarrage de Gunicorn sur 0.0.0.0:8000..."

# Lancer Gunicorn avec logs actifs
exec gunicorn monprojet.wsgi:application \
    --bind 0.0.0.0:8000 \
    --workers 3 \
    --worker-class sync \
    --timeout 60 \
    --access-logfile - \
    --error-logfile -



