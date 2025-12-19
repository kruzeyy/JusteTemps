# 📦 Ajouter le package Supabase à Xcode

## Méthode 1 : Via l'interface Xcode (Recommandée)

### Étapes détaillées :

1. **Ouvrez votre projet dans Xcode**
   - Ouvrez `JusteTemps.xcodeproj`

2. **Ouvrez le gestionnaire de packages**
   - Dans la barre de menu : **File → Add Package Dependencies...**
   - Ou cliquez sur le projet dans le navigateur (icône bleue en haut) → Onglet **"Package Dependencies"** → Bouton **"+"**

3. **Ajoutez l'URL du package**
   - Dans le champ de recherche, collez cette URL :
   ```
   https://github.com/supabase/supabase-swift
   ```
   - Appuyez sur **Enter** ou cliquez sur **"Add Package"**

4. **Sélectionnez la version**
   - Choisissez **"Up to Next Major Version"** avec la version la plus récente
   - Cliquez sur **"Add Package"**

5. **Ajoutez au target**
   - Cochez **"JusteTemps"** dans la liste des targets
   - Cliquez sur **"Add Package"**

6. **Attendez la résolution**
   - Xcode va télécharger et résoudre les dépendances
   - Cela peut prendre quelques minutes

7. **Vérifiez l'installation**
   - Dans le navigateur de projet, vous devriez voir **"Package Dependencies"** avec `supabase-swift`
   - L'erreur `No such module 'Supabase'` devrait disparaître

## Méthode 2 : Vérifier si le package est déjà ajouté

Si vous pensez avoir déjà ajouté le package :

1. **Vérifiez dans le navigateur de projet**
   - Regardez s'il y a une section **"Package Dependencies"**
   - Vérifiez que `supabase-swift` est listé

2. **Vérifiez les paramètres du projet**
   - Cliquez sur le projet (icône bleue)
   - Allez dans l'onglet **"Package Dependencies"**
   - Vérifiez que `supabase-swift` est présent

3. **Si le package est présent mais l'erreur persiste**
   - **Product → Clean Build Folder** (⇧⌘K)
   - Fermez Xcode
   - Supprimez le dossier `DerivedData` :
     ```bash
     rm -rf ~/Library/Developer/Xcode/DerivedData/*
     ```
   - Rouvrez Xcode
   - **File → Packages → Reset Package Caches**
   - **File → Packages → Resolve Package Versions**

## 🔍 Vérification

Après avoir ajouté le package, vous devriez pouvoir :
- Importer `Supabase` sans erreur
- Compiler le projet sans erreur de module manquant

## ⚠️ Si l'erreur persiste

1. **Vérifiez la version de Xcode**
   - Supabase Swift nécessite Xcode 14.0 ou supérieur
   - Vérifiez : **Xcode → About Xcode**

2. **Vérifiez la version d'iOS**
   - Le projet est configuré pour iOS 17.0
   - C'est compatible avec Supabase

3. **Réinstallez le package**
   - Supprimez le package de la liste
   - Réajoutez-le en suivant les étapes ci-dessus

## 📝 Note

Le package `supabase-swift` inclut automatiquement toutes les dépendances nécessaires, y compris :
- `GoTrue` (pour l'authentification)
- `PostgREST` (pour les requêtes)
- Et d'autres modules Supabase

Une fois ajouté, vous n'avez pas besoin d'ajouter d'autres packages.

