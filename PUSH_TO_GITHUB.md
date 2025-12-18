# Instructions pour pousser sur GitHub

## ✅ Étape 1 : Créer le dépôt sur GitHub

1. Allez sur [GitHub](https://github.com) et connectez-vous
2. Cliquez sur le bouton **"+"** en haut à droite → **"New repository"**
3. Remplissez les informations :
   - **Repository name** : `JusteTemps` (ou le nom de votre choix)
   - **Description** : "Application iOS pour gérer et suivre votre temps d'écran"
   - **Visibilité** : Public ou Private (selon votre préférence)
   - **NE COCHEZ PAS** "Initialize this repository with a README" (on a déjà un README)
4. Cliquez sur **"Create repository"**

## ✅ Étape 2 : Connecter votre dépôt local à GitHub

Après avoir créé le dépôt, GitHub vous donnera une URL. Utilisez-la dans la commande suivante :

```bash
cd /Users/maxime/JusteTemps

# Remplacez USERNAME par votre nom d'utilisateur GitHub
git remote add origin https://github.com/USERNAME/JusteTemps.git

# Ou si vous utilisez SSH :
# git remote add origin git@github.com:USERNAME/JusteTemps.git
```

## ✅ Étape 3 : Pousser le code

```bash
# Renommer la branche principale en main (si nécessaire)
git branch -M main

# Pousser le code
git push -u origin main
```

## 🔐 Si vous utilisez HTTPS

Si GitHub vous demande vos identifiants :
- **Username** : Votre nom d'utilisateur GitHub
- **Password** : Utilisez un **Personal Access Token** (pas votre mot de passe)
  - Créez-en un ici : https://github.com/settings/tokens
  - Sélectionnez les permissions : `repo` (accès complet aux dépôts)

## 🔑 Si vous utilisez SSH

Assurez-vous d'avoir configuré votre clé SSH :
```bash
# Vérifier si vous avez une clé SSH
ls -al ~/.ssh

# Si vous n'en avez pas, créez-en une :
ssh-keygen -t ed25519 -C "votre_email@example.com"

# Ajoutez-la à votre agent SSH
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

# Copiez la clé publique
cat ~/.ssh/id_ed25519.pub

# Ajoutez-la sur GitHub : Settings → SSH and GPG keys → New SSH key
```

## 📝 Commandes rapides (tout en une fois)

```bash
cd /Users/maxime/JusteTemps
git remote add origin https://github.com/VOTRE_USERNAME/JusteTemps.git
git branch -M main
git push -u origin main
```

## ✅ Vérification

Après avoir poussé, allez sur votre dépôt GitHub et vérifiez que tous les fichiers sont présents :
- ✅ Tous les fichiers Swift
- ✅ Le fichier project.pbxproj
- ✅ Le README.md
- ✅ Le .gitignore
- ✅ Les Assets

## 🔄 Commandes pour les mises à jour futures

```bash
# Ajouter les modifications
git add .

# Créer un commit
git commit -m "Description de vos modifications"

# Pousser vers GitHub
git push
```

