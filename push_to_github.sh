#!/bin/bash

# Script pour pousser JusteTemps sur GitHub
# Usage: ./push_to_github.sh VOTRE_USERNAME

if [ -z "$1" ]; then
    echo "❌ Erreur: Vous devez fournir votre nom d'utilisateur GitHub"
    echo "Usage: ./push_to_github.sh VOTRE_USERNAME"
    exit 1
fi

USERNAME=$1
REPO_NAME="JusteTemps"

echo "🚀 Configuration du dépôt GitHub pour JusteTemps"
echo ""

# Vérifier si git est initialisé
if [ ! -d ".git" ]; then
    echo "❌ Erreur: Le dépôt Git n'est pas initialisé"
    exit 1
fi

# Vérifier si le remote existe déjà
if git remote | grep -q "origin"; then
    echo "⚠️  Le remote 'origin' existe déjà"
    read -p "Voulez-vous le remplacer? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git remote remove origin
    else
        echo "❌ Opération annulée"
        exit 1
    fi
fi

# Ajouter le remote
echo "📦 Ajout du remote GitHub..."
git remote add origin https://github.com/$USERNAME/$REPO_NAME.git

# Renommer la branche en main si nécessaire
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" != "main" ]; then
    echo "🔄 Renommage de la branche '$CURRENT_BRANCH' en 'main'..."
    git branch -M main
fi

echo ""
echo "✅ Configuration terminée!"
echo ""
echo "📝 Prochaines étapes:"
echo "1. Créez le dépôt '$REPO_NAME' sur GitHub:"
echo "   https://github.com/new"
echo ""
echo "2. Une fois créé, exécutez:"
echo "   git push -u origin main"
echo ""
echo "Ou exécutez cette commande pour pousser automatiquement:"
echo "   git push -u origin main"
echo ""

read -p "Voulez-vous pousser maintenant? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "📤 Poussage vers GitHub..."
    git push -u origin main
    
    if [ $? -eq 0 ]; then
        echo ""
        echo "✅ Succès! Votre code est maintenant sur GitHub:"
        echo "   https://github.com/$USERNAME/$REPO_NAME"
    else
        echo ""
        echo "❌ Erreur lors du push. Assurez-vous que:"
        echo "   1. Le dépôt existe sur GitHub"
        echo "   2. Vous avez les permissions d'écriture"
        echo "   3. Vous êtes authentifié (Personal Access Token si HTTPS)"
    fi
else
    echo ""
    echo "ℹ️  Pour pousser plus tard, exécutez:"
    echo "   git push -u origin main"
fi

