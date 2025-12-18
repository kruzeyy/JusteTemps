# 🚀 Guide rapide pour mettre sur GitHub

## ✅ Étape 1 : Créer le dépôt sur GitHub

1. Allez sur https://github.com/new
2. Remplissez :
   - **Repository name** : `JusteTemps`
   - **Description** : "Application iOS pour gérer et suivre votre temps d'écran"
   - **Public** ou **Private** (selon votre choix)
   - **NE COCHEZ PAS** "Add a README file" (on en a déjà un)
3. Cliquez sur **"Create repository"**

## ✅ Étape 2 : Pousser le code (Option A - Script automatique)

```bash
cd /Users/maxime/JusteTemps
./push_to_github.sh VOTRE_USERNAME_GITHUB
```

Le script vous guidera à travers le processus.

## ✅ Étape 2 : Pousser le code (Option B - Commandes manuelles)

```bash
cd /Users/maxime/JusteTemps

# Ajouter le remote (remplacez USERNAME par votre nom d'utilisateur GitHub)
git remote add origin https://github.com/USERNAME/JusteTemps.git

# Renommer la branche en main
git branch -M main

# Pousser le code
git push -u origin main
```

## 🔐 Authentification GitHub

### Si vous utilisez HTTPS :
- **Username** : Votre nom d'utilisateur GitHub
- **Password** : Utilisez un **Personal Access Token** (PAS votre mot de passe)
  - Créez-en un : https://github.com/settings/tokens
  - Permissions : `repo` (accès complet)

### Si vous préférez SSH :
1. Configurez votre clé SSH (voir instructions dans PUSH_TO_GITHUB.md)
2. Utilisez : `git remote add origin git@github.com:USERNAME/JusteTemps.git`

## ✅ Vérification

Après le push, visitez votre dépôt :
```
https://github.com/VOTRE_USERNAME/JusteTemps
```

Vous devriez voir tous vos fichiers !

## 📝 Commandes utiles pour plus tard

```bash
# Voir l'état
git status

# Ajouter des modifications
git add .

# Créer un commit
git commit -m "Description de vos changements"

# Pousser vers GitHub
git push
```

## 🎉 C'est fait !

Votre code est maintenant sur GitHub et vous pouvez le partager avec d'autres développeurs !

