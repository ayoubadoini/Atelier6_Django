# 🎯 DÉBUT - Démarrez d'ici!

## ⚡ 3 commandes pour démarrer

### 1️⃣ Ouvrez PowerShell et naviguez au projet

```powershell
cd "c:\Users\ayoub\Desktop\S2\Framework coté serveur\TP6\monprojet"
```

### 2️⃣ Lancez les services Docker (Terminal 1)

Assurez-vous que **Docker Desktop est actif** sur votre système.

```powershell
docker-compose up --build
```

**Attendez** que vous voyiez:
```
web_1       | Starting development server at http://0.0.0.0:8000/
nginx_1     | ... workers started
db_1        | database "mydb" does not exist, creating...
```

Ne fermez PAS ce terminal.

### 3️⃣ Initialisez la base de données (Terminal 2 - NOUVEAU)

Dans un **NOUVEL** terminal PowerShell:

```powershell
cd "c:\Users\ayoub\Desktop\S2\Framework coté serveur\TP6\monprojet"
docker-compose exec web python manage.py migrate
docker-compose exec web python manage.py createsuperuser
docker-compose exec web python manage.py collectstatic --noinput
```

Pour `createsuperuser`, entrez:
```
Username: admin
Email: admin@example.com
Password: votre_mot_de_passe_ici (ex: Admin@123)
```

---

## 🌐 Accédez à l'application

Ouvrez votre navigateur:

- **Site principal**: http://localhost:8080 ✅
- **Interface admin**: http://localhost:8080/admin ✅

Connectez-vous avec:
- Username: `admin`
- Password: Votre mot de passe

---

## 📝 Ajoutez des produits de test

1. Allez sur http://localhost:8080/admin
2. Connectez-vous
3. Cliquez sur **"Products"** → **"+ Add"**
4. Remplissez:
   - **Name**: "Café Premium"
   - **Description**: "Arabica de qualité"
   - **Price**: "12.99"
   - **Stock**: "50"
5. Cliquez **"Save"**

Allez sur http://localhost:8080 → Vous verrez vos produits! 🎉

---

## 🛑 Pour arrêter

Terminal 1 (Docker):
```
Ctrl + C
```

Ou depuis Terminal 2:
```powershell
docker-compose down
```

---

## 📚 Prochaines lectures

Après avoir testé l'application:

1. [QUICK_START.md](QUICK_START.md) - Guide complet pas à pas
2. [README.md](README.md) - Documentation technique
3. [CHEATSHEET.md](CHEATSHEET.md) - Fiche rapide

---

## ❓ Vous avez une erreur?

### "docker: command not found"
→ Docker Desktop n'est pas installé ou pas en cours d'exécution. Installez-le depuis https://www.docker.com/

### "Port 8080 already in use"
```powershell
Get-NetTCPConnection -LocalPort 8080
# Trouvez le PID, puis:
Stop-Process -Id <PID> -Force
```

### "Connection refused"
→ Docker a besoin de temps. Attendez 30 secondes et réessayez.

### "ModuleNotFoundError"
```powershell
docker-compose down -v
docker-compose up --build
```

---

## ✨ Vous êtes prêt!

Votre application Django fonctionne maintenant avec:
- ✅ Django (application web)
- ✅ PostgreSQL (base de données)
- ✅ Nginx (reverse proxy)
- ✅ Gunicorn (serveur applicatif)

**Prochaine étape**: Déployer sur Render (voir QUICK_START.md)

---

**Bonne chance! 🚀**
