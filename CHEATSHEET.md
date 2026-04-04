# 📋 Fiche mémoire - TP Déploiement Django Docker Render

## 🎯 L'essentiel en 2 minutes

**Objectif**: Déployer une application Django de façon professionnelle avec Docker et Render.

**3 services Docker**:
1. **Nginx** (port 8080) ← Reverse proxy, sert les fichiers statiques
2. **Gunicorn** (port 8000) ← Serveur WSGI, exécute Django (3 workers en prod)
3. **PostgreSQL** (port 5432) ← Base de données (remplace SQLite)

**Flux d'une requête**: 
```
Navigateur → Nginx (8080) → Gunicorn (8000) → Django → PostgreSQL
```

---

## 🎬 Commandes de démarrage

### Développement
```bash
cd monprojet
docker-compose up --build                    # Terminal 1: Démarrer
docker-compose exec web python manage.py migrate          # Terminal 2: Init DB
docker-compose exec web python manage.py createsuperuser  # Terminal 2: Admin
docker-compose exec web python manage.py collectstatic --noinput  # Terminal 2: Static
```

Sites:
- App: http://localhost:8080
- Admin: http://localhost:8080/admin

### Production (Render)
```bash
# 1. Commit sur GitHub
git add .
git commit -m "Initial"
git push origin main

# 2. Render déploie automatiquement
# 3. Accès: https://votre-app-name.onrender.com
```

---

## 🐳 Fichiers Docker clés

| Fichier | Rôle |
|---------|------|
| `Dockerfile` | Construit l'image Python |
| `docker-compose.yml` | Orchestre (dev): gunicorn remplacé par runserver |
| `docker-compose.prod.yml` | Orchestre (prod): 3 workers Gunicorn |
| `requirements.txt` | Dépendances Python (pip install) |

---

## 📝 Configuration Django (settings.py)

```python
# Base de données PostgreSQL (pas SQLite !)
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'HOST': 'db',  # Nom du service Docker
        'PORT': '5432',
    }
}

# Middleware pour fichiers statiques
MIDDLEWARE = [
    'whitenoise.middleware.WhiteNoiseMiddleware',  # Important!
    ...
]

# Variables lues depuis .env
from decouple import config
SECRET_KEY = config('SECRET_KEY')
DEBUG = config('DEBUG', cast=bool)
```

---

## 🔐 Fichier .env (NE PAS COMMITER!)

```env
DEBUG=1                                    # 0 en production
SECRET_KEY=django-insecure-xxxxx           # Générer: python -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())"
ALLOWED_HOSTS=localhost,127.0.0.1
POSTGRES_DB=mydb
POSTGRES_USER=myuser
POSTGRES_PASSWORD=mypassword
CSRF_TRUSTED_ORIGINS=http://localhost:8080
```

**Important**: `.gitignore` le contient ✓

---

## 🌐 Nginx (reverse proxy)

```nginx
upstream django {
    server web:8000;  # Envoie vers Gunicorn
}

server {
    listen 80;
    
    # Sert les fichiers statiques SANS Python (rapide!)
    location /static/ {
        alias /app/staticfiles/;
    }
    
    # Proxy vers Django pour tout le reste
    location / {
        proxy_pass http://django;
    }
}
```

**Ports**:
- Dev: Nginx sur 8080 → localhost:8080
- Prod: Nginx sur 80/443 → https://app.onrender.com

---

## ⚙️ Gunicorn (serveur WSGI)

```bash
# Dev: runserver (hot-reload, mono-thread)
python manage.py runserver 0.0.0.0:8000

# Prod: Gunicorn (3 workers, prêt pour le trafic)
gunicorn monprojet.wsgi:application --bind 0.0.0.0:8000 --workers 3
```

**Avantage des 3 workers**: 3 requêtes simultanées au lieu de 1 avec runserver.

---

## 📊 Étapes du TP

| # | Étape | Commande |
|---|-------|----------|
| 1 | Fichiers Django | Déjà créés ✓ |
| 2 | Docker setup | `docker-compose up --build` |
| 3 | Init BD | `docker-compose exec web python manage.py migrate` |
| 4 | Admin | `docker-compose exec web python manage.py createsuperuser` |
| 5 | Static files | `docker-compose exec web python manage.py collectstatic` |
| 6 | Test local | http://localhost:8080 |
| 7 | Push GitHub | `git push origin main` |
| 8 | Deploy Render | Via dashboard Render |
| 9 | Test prod | https://votre-app.onrender.com |

---

## 🔧 Dépannage rapide

| Problème | Solution |
|----------|----------|
| "Connection refused" | `docker-compose down -v && docker-compose up --build` |
| Port 8080 utilisé | Tuer le process: `taskkill /PID xxx /F` |
| Static files manquants | `docker-compose exec web python manage.py collectstatic --clear` |
| "ModuleNotFoundError" | `docker-compose down -v && docker-compose up --build` |
| Logs incompréhensibles | `docker-compose logs -f web` |

---

## ✅ Checklist avant production

- [ ] `.env` dans `.gitignore` ✓
- [ ] `DEBUG=0` en production
- [ ] `SECRET_KEY` unique et forte (pas la valeur par défaut!)
- [ ] `ALLOWED_HOSTS` correct (`votre-domaine.onrender.com`)
- [ ] `CSRF_TRUSTED_ORIGINS` correct
- [ ] `collectstatic` exécuté
- [ ] Migrations appliquées
- [ ] Superuser créé
- [ ] Code pushé sur GitHub
- [ ] Déploiement Render réussi

---

## 📦 Dépendances (requirements.txt)

```
django>=5.0              # Framework web
gunicorn                 # Serveur WSGI
psycopg2-binary         # Driver PostgreSQL
whitenoise              # Serve static files
python-decouple         # Read .env variables
```

---

## 🚀 Déploiement Render en 5 étapes

1. **GitHub**: Push votre code
2. **Render**: Créer un Web Service Docker
3. **Variables**: Ajouter SECRET_KEY, POSTGRES_PASSWORD, etc.
4. **Deploy**: Cliquer "Create Web Service"
5. **Accès**: https://votre-app-name.onrender.com

---

## 🎓 Points à retenir absolument

✅ **Dev** = runserver + SQLite non, PostgreSQL oui
✅ **Prod** = Gunicorn + 3 workers + PostgreSQL  
✅ **Containers** = Nginx + Gunicorn + PostgreSQL  
✅ **Static files** = collectstatic AVANT la prod  
✅ **.env** = JAMAIS sur GitHub (secrets!)  
✅ **Ports**: 8080 (dev), 80/443 (prod), 8000 (Gunicorn interne)

---

## 🔗 Ressources

- [README.md](README.md) - Documentation complète
- [QUICK_START.md](QUICK_START.md) - Guide pas à pas
- [Django Docs](https://docs.djangoproject.com/)
- [Docker Docs](https://docs.docker.com/)
- [Render Docs](https://render.com/docs)

---

**Vous êtes prêt! 🎉**
