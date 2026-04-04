# 🛣️ Routes et API de l'application

## 📍 Routes disponibles

### Site principal

| Route | Méthode | Description |
|-------|---------|-------------|
| `/` | GET | Accueil - Liste tous les produits |
| `/product/<id>/` | GET | Détail d'un produit spécifique |

### Admin Django

| Route | Méthode | Description |
|-------|---------|-------------|
| `/admin/` | GET | Interface admin Django |
| `/admin/login/` | POST | Connexion admin |
| `/admin/boutique/product/` | GET | Liste des produits (admin) |
| `/admin/boutique/product/add/` | GET/POST | Ajouter un produit |
| `/admin/boutique/product/<id>/change/` | GET/POST | Modifier un produit |
| `/admin/boutique/product/<id>/delete/` | GET/POST | Supprimer un produit |

---

## 🏠 Page d'accueil (`/`)

### Fonctionnalités
- ✅ Affiche tous les produits de la BD
- ✅ Grille responsive (3 colonnes sur desktop)
- ✅ Montre: nom, prix, stock
- ✅ Badge "Stock disponible" ou "Rupture de stock"
- ✅ Lien vers le détail de chaque produit

### Données retournées
```python
{
    'products': [
        {
            'id': 1,
            'name': 'Café Premium',
            'description': 'Arabica...',
            'price': 12.99,
            'stock': 50,
            'created_at': datetime,
            'updated_at': datetime
        },
        # ... plus de produits
    ]
}
```

---

## 🎯 Détail produit (`/product/<id>/`)

### Fonctionnalités
- ✅ Affiche les détails complets d'un produit
- ✅ Montre la description complète
- ✅ État du stock avec badge couleur
- ✅ Dates de création et modification
- ✅ Bouton retour à l'accueil

### Exemple d'accès
```
http://localhost:8080/product/1/
http://localhost:8080/product/5/
```

### Données retournées
```python
{
    'product': {
        'id': 1,
        'name': 'Café Premium',
        'description': 'Arabica de haute qualité...',
        'price': 12.99,
        'stock': 50,
        'created_at': '2024-04-04 10:30:45',
        'updated_at': '2024-04-04 10:30:45'
    }
}
```

---

## 🔧 Interface Admin (`/admin/`)

### Fonctionnalités disponibles

1. **Authentification**
   - Connectez-vous avec votre compte super-utilisateur
   - Gérez les permissions utilisateurs

2. **Gestion des produits**
   - ✅ Lister tous les produits
   - ✅ Ajouter un nouveau produit
   - ✅ Modifier un produit existant
   - ✅ Supprimer un produit
   - ✅ Chercher par nom
   - ✅ Filtrer par date de création

3. **Modèles disponibles**
   - Products (Boutique)
   - Users (Django)
   - Groups (Django)

---

## 📊 Modèle Product

### Champs du modèle

```python
class Product(models.Model):
    name                # CharField - Nom du produit (max 255 caractères)
    description         # TextField - Description longue (optionnel)
    price              # DecimalField - Prix (2 décimales)
    stock              # IntegerField - Quantité en stock (défaut: 0)
    created_at         # DateTimeField - Créé le (auto)
    updated_at         # DateTimeField - Modifié le (auto)
```

### Validation
- Name: Requis, max 255 charactères
- Price: Requis, format décimal
- Stock: Défaut à 0 si non spécifié
- Description: Optionnel

---

## 🌍 URLs configurées

### Configuration dans `monprojet/urls.py`
```python
urlpatterns = [
    path('admin/', admin.site.urls),      # Admin Django
    path('', include('boutique.urls')),   # App boutique
]
```

### Configuration dans `boutique/urls.py`
```python
path('', views.home, name='home'),                          # GET /
path('product/<int:pk>/', views.product_detail, name='product_detail'),  # GET /product/1/
```

---

## 📱 Exemples d'utilisation

### Charger l'accueil
```
GET http://localhost:8080/
```
Retourne: Page HTML avec tous les produits

### Charger un produit
```
GET http://localhost:8080/product/1/
```
Retourne: Page HTML avec les détails du produit ID=1

### Ajouter un produit (via admin)
```
POST /admin/boutique/product/add/
```
Remplissez le formulaire et validez

---

## 🔐 Permissions

### Admin Django
- ✅ Créer des produits
- ✅ Modifier des produits
- ✅ Supprimer des produits
- ✅ Voir tous les produits

### Utilisateurs normaux
- ✅ Voir la liste des produits
- ✅ Voir le détail d'un produit
- ❌ Ajouter/modifier/supprimer des produits

---

## 🎨 Template rendering

### Contexte global (tous les templates)
```python
{
    'request': <HttpRequest>,          # L'objet requête
}
```

### Filtres Jinja2 utilisés
- `truncatewords:15` - Tronque le texte à 15 mots
- `date:"d/m/Y à H:i"` - Formate les dates

---

## 📈 Prochaines fonctionnalités possibles

Pour améliorer l'API:

1. **REST API** (avec Django REST Framework)
   ```
   GET /api/products/
   GET /api/products/<id>/
   POST /api/products/
   ```

2. **Panier**
   ```
   POST /cart/add/<product_id>/
   GET /cart/
   POST /cart/checkout/
   ```

3. **Recherche**
   ```
   GET /?q=café
   GET /?sort=price&order=asc
   ```

4. **Pagination**
   ```
   GET /?page=2&limit=10
   ```

5. **Filtres**
   ```
   GET /?price_min=10&price_max=50&in_stock=true
   ```

---

## 🧪 Tester les routes

### Avec curl (PowerShell)
```powershell
# Get accueil
curl http://localhost:8080

# Get détail produit
curl http://localhost:8080/product/1/

# Get admin
curl http://localhost:8080/admin
```

### Avec Python
```python
import requests

# Get accueil
r = requests.get('http://localhost:8080')
print(r.status_code)  # 200

# Get détail produit
r = requests.get('http://localhost:8080/product/1/')
print(r.status_code)  # 200 ou 404 si n'existe pas
```

---

## 🎯 Codes de statut HTTP

| Code | Significat |
|------|-----------|
| 200 | OK - Requête réussie |
| 404 | Not Found - Produit inexistant |
| 405 | Method Not Allowed - Mauvaise méthode HTTP |
| 500 | Server Error - Erreur serveur |

---

## 📝 Notes

- Tous les URLs sont **case-sensitive**
- Les IDs de produits sont des **entiers**
- Les templates incluent du **CSS responsive**
- L'admin Django est **sécurisé** (login requis)

---

**Bon développement! 🚀**
