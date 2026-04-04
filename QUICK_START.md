# 🚀 Guide de démarrage - Déploiement Django avec Docker et Render

## ✅ Prérequis
- Docker Desktop installé et en cours d'exécution
- Docker Compose installé (généralement inclus dans Docker Desktop)
- Git installé
- Connexion internet
- Compte Render (gratuit sur https://render.com)

Pour vérifier:
```bash
docker --version
docker-compose --version
git --version
```

---

## 📝 ÉTAPE 1: Configuration locales
### 1.1 Éditer le fichier `.env`

Le fichier `.env` contient vos secrets. **NE PAS LE COMMITER** sur GitHub.

```bash
# Éditer avec votre éditeur préféré
# Les variables par défaut conviendront pour le développement
```

Valeurs actuelles (conviennent pour le dev):
```
DEBUG=1
SECRET_KEY=django-insecure-changeme-123456
ALLOWED_HOSTS=localhost,127.0.0.1
POSTGRES_DB=mydb
POSTGRES_USER=myuser
POSTGRES_PASSWORD=mypassword
CSRF_TRUSTED_ORIGINS=http://localhost:8080,http://127.0.0.1:8080
```

---

## 🐳 ÉTAPE 2: Démarrage en développement

### 2.1 Construire et lancer les containers

```bash
cd c:\Users\ayoub\Desktop\S2\Framework\ coté\ serveur\TP6\monprojet

# Lancer tous les services (nécessite Docker Desktop actif)
docker-compose up --build
```

Attendez que vous voyiez:
```
web_1   | Starting development server at http://0.0.0.0:8000/
nginx_1 | ... worker processes started
db_1    | database "mydb" does not exist, creating...
```

### 2.2 Initialiser la base de données (NOUVEAU TERMINAL)

Dans **un autre terminal PowerShell**, exécutez:

```bash
cd c:\Users\ayoub\Desktop\S2\Framework\ coté\ serveur\TP6\monprojet

# Créer les tables
docker-compose exec web python manage.py migrate

# Créer un compte administrateur
docker-compose exec web python manage.py createsuperuser

# Exemples de réponses:
# Username: admin
# Email: admin@example.com
# Password: votre_mot_de_passe_ici

# Copier les fichiers statiques
docker-compose exec web python manage.py collectstatic --noinput
```

### 2.3 Accès à l'application

Ouvrez dans votre navigateur:
- **Site principal**: http://localhost:8080
- **Admin Django**: http://localhost:8080/admin (connectez-vous avec les identifiants créés)

### 2.4 Ajouter des produits de test

1. Allez sur http://localhost:8080/admin
2. Identifiez-vous
3. Cliquez sur "Products" → "+ Add"
4. Remplissez:
   - Name: "Café premium"
   - Description: "Café arabica de qualité supérieure"
   - Price: "12.99"
   - Stock: "50"
5. Cliquez "Save"
6. Répétez pour ajouter d'autres produits

Retournez sur http://localhost:8080 pour voir vos produits!

---

## 🛑 Arrêter les services en développement

Dans le terminal où vous avez lancé `docker-compose up`:
```
Ctrl + C
```

Ou dans un autre terminal:
```bash
cd c:\Users\ayoub\Desktop\S2\Framework\ coté\ serveur\TP6\monprojet
docker-compose down
```

---

## 📦 ÉTAPE 3: Préparer le déploiement sur Render

### 3.1 Initialiser Git et commit

```bash
cd c:\Users\ayoub\Desktop\S2\Framework\ coté\ serveur\TP6\monprojet

# Initialiser Git
git init
git add .
git commit -m "Initial Django+Docker project"
```

⚠️ **IMPORTANT**: Vérifiez que `.env` est dans `.gitignore` (il l'est!)
```bash
git status  # Ne doit PAS montrer .env!
```

### 3.2 Créer un repository GitHub

1. Allez sur https://github.com/new
2. Nommez le repository: `Atelier6_Django`
3. Cliquez "Create repository"
4. Suivez les instructions pour pousser votre code:

```bash
git remote add origin https://github.com/votre_username/Atelier6_Django.git
git branch -M main
git push -u origin main
```

---

## 🌐 ÉTAPE 4: Déployer sur Render

### 4.1 Créer un compte Render

1. Allez sur https://render.com
2. Cliquez "Sign up with GitHub"
3. Autorisez l'accès à vos repositories

### 4.2 Créer un Web Service

1. Une fois connecté, cliquez "+ New" en haut à droite
2. Sélectionnez "Web Service"
3. Sélectionnez votre repository `Atelier6_Django`
4. Remplissez les paramètres:
   - **Name**: `atelier6-django` (ou un autre nom unique)
   - **Environment**: Docker
   - **Plan**: Free (ou Pro si vous le souhaitez)
5. Cliquez "Create Web Service"

### 4.3 Configurer les variables d'environnement

1. Dans le dashboard Render, allez dans votre service
2. Allez à l'onglet "Environment"
3. Cliquez "Add Environment Variable" pour chaque variable:

```
DEBUG=0
SECRET_KEY=GÉNÉRER_UNE_CLÉ_FORTE (voir ci-dessous)
ALLOWED_HOSTS=votre-app-name.onrender.com
POSTGRES_DB=mydb
POSTGRES_USER=myuser
POSTGRES_PASSWORD=GÉNÉRER_MOT_DE_PASSE_FORT
CSRF_TRUSTED_ORIGINS=https://votre-app-name.onrender.com
```

### 4.4 Générer une SECRET_KEY forte

```bash
python -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())"
```

Copyez la clé générée et collez-la dans Render sous `SECRET_KEY`.

### 4.5 Déployer

1. Cliquez "Deploy" sur le dashboard Render
2. Attendez que le build se termine (3-5 minutes)
3. Une fois terminé, votre app sera accessible via: `https://votre-app-name.onrender.com`

### 4.6 Initialiser la base de données en production

Une fois le déploiement réussi:

```bash
# Créer les tables en production
# Utilisez l'onglet "Shell" dans Render ou:
curl https://votre-app-name.onrender.com/admin

# Pour faire les migrations:
# Consultez les logs Render pour voir s'il y a des erreurs
```

---

## 🧪 Tests après déploiement

Visitez:
- https://votre-app-name.onrender.com (site)
- https://votre-app-name.onrender.com/admin (admin)

---

## 🔧 Commandes utiles

### Développement

```bash
# Voir les logs en temps réel
docker-compose logs -f web

# Accéder à la console Django
docker-compose exec web python manage.py shell

# Créer des migrations après modification des modèles
docker-compose exec web python manage.py makemigrations
docker-compose exec web python manage.py migrate

# Vider la base de données
docker-compose exec web python manage.py flush --no-input
```

### Production (Render)

1. Connectez-vous à votre dashboard Render
2. Allez sur votre service
3. Cliquez "Shell" pour accéder au terminal
4. Exécutez les commandes Django normales

---

## ❌ Dépannage

### "Connection refused" lors du démarrage
```bash
# Arrêter et relancer sans cache
docker-compose down -v
docker-compose up --build
```

### "Port 8080 déjà utilisé" (Windows)
```powershell
# Trouver le processus
netstat -ano | findstr :8080

# Tuer le processus (remplacer PID)
taskkill /PID 1234 /F
```

### Les fichiers statiques ne chargent pas
```bash
docker-compose exec web python manage.py collectstatic --noinput --clear
```

### Erreur "ModuleNotFoundError: No module named 'psycopg2'"
```bash
docker-compose down -v
docker-compose up --build
```

---

## 📚 Structure finale

```
monprojet/
├── boutique/                    # Application Django
├── monprojet/                   # Configuration
├── templates/                   # Templates HTML
├── static/                      # Fichiers statiques
├── staticfiles/                 # Collectés pour production
├── nginx/                       # Configuration nginx
├── Dockerfile                   # Image Docker
├── docker-compose.yml           # Orchestre (dev)
├── docker-compose.prod.yml      # Orchestre (prod)
├── requirements.txt             # Dépendances
├── manage.py                    # CLI Django
├── .env                         # Variables (⚠️ À ne pas commiter)
├── .gitignore                   # Fichiers ignorés
└── README.md                    # Documentation
```

---

## ✨ Prochaines étapes

Maintenant que votre projet est déployé:

1. **Ajouter des fonctionnalités** (panier, commandes, etc.)
2. **Ajouter un domaine personnalisé** sur Render
3. **Configurer HTTPS** (automatique sur Render)
4. **Monitorer les logs** en production
5. **Ajouter des tests** au projet

---

## 🎓 Ce que vous avez appris

✅ Architecture microservices (Nginx + Gunicorn + PostgreSQL)  
✅ Containerisation avec Docker & Docker Compose  
✅ Configuration Django pour la production  
✅ Déploiement en cloud avec Render  
✅ Gestion des secrets avec variables d'environnement  
✅ Reverse proxy avec Nginx  

---

**Besoin d'aide?** Consultez le README.md ou posez une question!
