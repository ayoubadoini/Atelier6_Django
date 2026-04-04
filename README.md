# Boutique Django - Guide de déploiement complet

## 📋 Aperçu du projet

Application e-commerce complète avec:
- **Django** : Framework Python web
- **PostgreSQL** : Base de données robuste
- **Nginx** : Reverse proxy et serveur web statique
- **Gunicorn** : Serveur applicatif WSGI
- **Docker Compose** : Orchestration des conteneurs
- **Render** : Déploiement en production

## 🏗️ Architecture

```
┌─────────────┐
│  Utilisateur │
└──────┬──────┘
       │ HTTP:8080
       ↓
┌─────────────────┐
│  Nginx (Proxy)  │  ← Point d'entrée
├─────────────────┤
│  Static Files   │  ← CSS, JS, images
│  Request Route  │  ← Vers Gunicorn
└────────┬────────┘
         │ HTTP:8000
         ↓
┌──────────────────────┐
│ Gunicorn (3 workers) │  ← Serveur applicatif
│   Django            │
└──────────┬───────────┘
           │ SQL
           ↓
    ┌──────────────┐
    │  PostgreSQL  │  ← Base de données
    └──────────────┘
```

## 📂 Structure du projet

```
monprojet/
├── boutique/                    # App Django
│   ├── __init__.py
│   ├── apps.py
│   ├── admin.py
│   ├── models.py               # Modèle Product
│   ├── views.py
│   ├── urls.py
│   ├── tests.py
│   └── migrations/
├── monprojet/                   # Configuration Django
│   ├── __init__.py
│   ├── settings.py             # Configuration Django
│   ├── urls.py                 # URLs principales
│   ├── wsgi.py                 # WSGI application
│   └── asgi.py
├── templates/                   # Templates HTML
│   ├── base.html
│   └── boutique/
│       ├── home.html
│       └── product_detail.html
├── static/                      # Fichiers statiques (dev)
├── staticfiles/                 # Fichiers statiques collectés (prod)
├── nginx/
│   └── nginx.conf              # Configuration Nginx
├── manage.py                    # Django management
├── Dockerfile                   # Image Docker
├── docker-compose.yml           # Dev
├── docker-compose.prod.yml      # Production
├── requirements.txt             # Dépendances Python
├── .env                         # Secrets (NE PAS COMMITER)
├── .gitignore
└── README.md
```

## 🚀 Démarrage rapide

### Prérequis
- Docker & Docker Compose installés
- Git installé
- Compte Render (pour production)

### 1️⃣ Développement local

```bash
cd monprojet

# Lancer tous les services
docker-compose up --build

# Dans un autre terminal, initialiser la BD
docker-compose exec web python manage.py migrate
docker-compose exec web python manage.py createsuperuser
docker-compose exec web python manage.py collectstatic --noinput
```

Accès:
- Site: http://localhost:8080
- Admin: http://localhost:8080/admin
- API Django: http://localhost:8000 (direct Gunicorn)

### 2️⃣ Production locale (simulation)

```bash
# Générer une SECRET_KEY forte
python -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())"

# Éditer .env avec des valeurs sécurisées
# Puis lancer:
docker-compose -f docker-compose.prod.yml up --build -d

# Vérifier les services
docker-compose -f docker-compose.prod.yml logs -f web
```

## 📝 Fichiers clés expliqués

### `requirements.txt`
```
django>=5.0        # Framework web Python
gunicorn           # Serveur WSGI production
psycopg2-binary    # Connecteur PostgreSQL
whitenoise         # Sert les fichiers statiques
python-decouple    # Lit les variables d'environnement
```

### `.env` (Secrets - NE PAS COMMITER)
```env
DEBUG=1
SECRET_KEY=votre-clé-secrète-ici
ALLOWED_HOSTS=localhost,127.0.0.1
POSTGRES_DB=mydb
POSTGRES_USER=myuser
POSTGRES_PASSWORD=mypassword
CSRF_TRUSTED_ORIGINS=http://localhost:8080
```

### `Dockerfile`
- Utilise Python 3.12-slim (léger)
- Installe les dépendances système (libpq-dev pour PostgreSQL)
- Copie le code
- Lance Gunicorn avec 3 workers

### `docker-compose.yml` (Développement)
- **web**: Django avec `python manage.py runserver` (hot-reload)
- **db**: PostgreSQL
- **nginx**: Reverse proxy sur port 8080
- Volumes: `.:/app` pour les changements en temps réel

### `docker-compose.prod.yml` (Production)
- **web**: Gunicorn avec 3 workers (sans hot-reload)
- **db**: PostgreSQL avec volume persistant
- **nginx**: Sur ports 80/443
- `restart: unless-stopped` : Relance automatique des services

### `nginx/nginx.conf`
```nginx
# Proxy les requêtes vers Gunicorn
location / {
    proxy_pass http://django;
}

# Sert les fichiers statiques directement (sans Python)
location /static/ {
    alias /app/staticfiles/;
}
```

## 🔄 Commandes courantes

### Développement

```bash
# Démarrer/arrêter les services
docker-compose up
docker-compose down

# Voir les logs
docker-compose logs -f web
docker-compose logs -f db

# Exécuter des commandes Django
docker-compose exec web python manage.py migrate
docker-compose exec web python manage.py createsuperuser
docker-compose exec web python manage.py shell

# Collecte des fichiers statiques
docker-compose exec web python manage.py collectstatic --noinput
```

### Production

```bash
# Démarrer en mode production
docker-compose -f docker-compose.prod.yml up --build -d

# Arrêter les services
docker-compose -f docker-compose.prod.yml down

# Exécuter des migrations
docker-compose -f docker-compose.prod.yml exec web python manage.py migrate

# Voir les logs
docker-compose -f docker-compose.prod.yml logs -f web
```

### Gestion de la base de données

```bash
# Créer les tables
docker-compose exec web python manage.py migrate

# Créer un super-utilisateur (admin)
docker-compose exec web python manage.py createsuperuser

# Accéder à la console Django
docker-compose exec web python manage.py shell

# Vider la base de données
docker-compose exec web python manage.py flush --no-input
```

## 📦 Déploiement sur Render

### Étapes

1. **Mettre le code sur GitHub**
   ```bash
   git init
   git add .
   git commit -m "Initial Django Docker project"
   git push origin main
   ```

2. **Créer un compte Render**
   - Aller sur [render.com](https://render.com)
   - Se connecter avec GitHub

3. **Créer un nouveau Web Service**
   - Cliquer sur "+ New" → "Web Service"
   - Sélectionner le repository
   - Choisir "Docker" comme Environment
   - Plan: Free (512MB RAM, 0.1 CPU) ou Pro

4. **Configurer les variables d'environnement**
   - Dans Render Dashboard: Environment
   - Ajouter les variables (SECRET_KEY, DATABASE_URL, etc.)

5. **Déployer**
   - Render construit l'image Docker automatiquement
   - Accès via: `https://monprojet-xxxxx.onrender.com`

### Variables d'environnement pour Render

```
DEBUG=0
SECRET_KEY=votre-clé-générée
ALLOWED_HOSTS=monprojet-xxxxx.onrender.com
POSTGRES_DB=mydb
POSTGRES_USER=myuser
POSTGRES_PASSWORD=votre-mot-de-passe
CSRF_TRUSTED_ORIGINS=https://monprojet-xxxxx.onrender.com
```

## 🔑 Points à retenir

| Aspect | Détails |
|--------|---------|
| **Flux requête** | Navigateur → Nginx (8080) → Gunicorn (8000) → Django → PostgreSQL |
| **Dev vs Prod** | Dev: runserver, Prod: 3 workers Gunicorn |
| **.env** | JAMAIS commiter sur Git (secrets sensibles) |
| **collectstatic** | OBLIGATOIRE avant prod (CSS/JS) |
| **Workers Gunicorn** | 3 = 3 requêtes simultanées |
| **Port 8080** | Uniquement en développement local |
| **Volumes** | Dev: hot-reload, Prod: volume persistant BD |
| **Nginx** | Point d'entrée, proxy + static files |
| **PostgreSQL** | Remplace SQLite pour concurrence + persistence |

## 🐛 Dépannage

### "Connection refused" à la base de données
```bash
docker-compose down -v
docker-compose up --build
```

### Port déjà utilisé
```bash
# Trouver le processus qui utilise le port 8080
netstat -ano | findstr :8080
taskkill /PID <PID> /F
```

### Fichiers statiques non chargés
```bash
docker-compose exec web python manage.py collectstatic --noinput --clear
```

### "No such file or directory: manage.py"
Assurez-vous de lancer les commandes depuis le bon répertoire (celui contenant docker-compose.yml)

## 📚 Ressources

- [Django Documentation](https://docs.djangoproject.com/)
- [Docker Compose](https://docs.docker.com/compose/)
- [Gunicorn Documentation](https://gunicorn.org/)
- [Nginx Documentation](https://nginx.org/en/docs/)
- [Render Documentation](https://render.com/docs)

## 👨‍💼 Support

Pour toute question sur ce TP, consultez le guide fourni ou posez une question en classe.

---

**Créé pour le TP 6 - Framework côté serveur**
