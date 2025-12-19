# 🔧 Guide pas à pas : Ajouter Supabase à Xcode

## ⚠️ IMPORTANT : Vous devez faire cela dans Xcode

Le package doit être ajouté via l'interface Xcode. Voici les étapes exactes :

## 📋 Étapes détaillées

### Étape 1 : Ouvrir Xcode
1. Ouvrez Xcode
2. Ouvrez le projet `JusteTemps.xcodeproj`

### Étape 2 : Accéder au gestionnaire de packages

**Méthode A (Recommandée) :**
1. Dans la barre de menu en haut, cliquez sur **"File"**
2. Cliquez sur **"Add Package Dependencies..."**

**Méthode B (Alternative) :**
1. Dans le navigateur de projet (panneau de gauche), cliquez sur l'icône bleue **"JusteTemps"** en haut
2. Sélectionnez le projet (pas le target)
3. Allez dans l'onglet **"Package Dependencies"** (en haut)
4. Cliquez sur le bouton **"+"** en bas à gauche

### Étape 3 : Entrer l'URL du package

1. Dans le champ de recherche en haut, collez exactement cette URL :
   ```
   https://github.com/supabase/supabase-swift
   ```
2. Appuyez sur **Enter** ou attendez que Xcode trouve le package
3. Vous devriez voir apparaître "supabase-swift" dans les résultats

### Étape 4 : Sélectionner la version

1. Dans la section "Dependency Rule", sélectionnez :
   - **"Up to Next Major Version"**
   - Version : `2.0.0` ou la plus récente disponible
2. Cliquez sur **"Add Package"** (bouton bleu en bas à droite)

### Étape 5 : Attendre la résolution

1. Xcode va télécharger et résoudre les dépendances
2. Une barre de progression apparaîtra
3. Cela peut prendre 1-3 minutes selon votre connexion
4. **Ne fermez pas Xcode pendant ce temps**

### Étape 6 : Ajouter au target

1. Une fois la résolution terminée, une nouvelle fenêtre s'ouvre
2. Vous verrez une liste de produits du package
3. **Cochez la case à côté de "JusteTemps"** (votre target)
4. Assurez-vous que "Add to Target" montre "JusteTemps"
5. Cliquez sur **"Add Package"** (bouton bleu en bas à droite)

### Étape 7 : Vérifier l'installation

1. Dans le navigateur de projet (panneau de gauche), vous devriez maintenant voir :
   - Une section **"Package Dependencies"** (en bas)
   - À l'intérieur : **"supabase-swift"** avec une icône de paquet

2. Si vous ne voyez pas cette section :
   - Cliquez sur l'icône bleue du projet
   - Allez dans l'onglet **"Package Dependencies"**
   - Vous devriez voir `supabase-swift` listé

### Étape 8 : Nettoyer et compiler

1. Dans Xcode, allez dans **Product → Clean Build Folder** (ou appuyez sur ⇧⌘K)
2. Attendez que le nettoyage soit terminé
3. Essayez de compiler : **Product → Build** (ou ⌘B)
4. L'erreur `No such module 'Supabase'` devrait maintenant être résolue

## ✅ Vérification finale

Si tout fonctionne :
- ✅ Pas d'erreur rouge dans le code
- ✅ Le projet compile sans erreur
- ✅ Vous pouvez voir `supabase-swift` dans Package Dependencies

## 🐛 Si ça ne fonctionne pas

### Problème 1 : Le package ne s'affiche pas
- Vérifiez votre connexion internet
- Essayez de fermer et rouvrir Xcode
- Réessayez l'étape 2

### Problème 2 : L'erreur persiste après l'ajout
1. **Product → Clean Build Folder** (⇧⌘K)
2. **File → Packages → Reset Package Caches**
3. **File → Packages → Resolve Package Versions**
4. Fermez Xcode complètement
5. Supprimez le cache : 
   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData/*
   ```
6. Rouvrez Xcode et réessayez

### Problème 3 : Xcode ne trouve pas le package
- Vérifiez que vous avez Xcode 14.0 ou supérieur
- Vérifiez votre connexion internet
- Essayez cette URL alternative dans le navigateur pour vérifier :
  https://github.com/supabase/supabase-swift

## 📸 À quoi ça ressemble

Après l'ajout réussi, dans le navigateur de projet vous verrez :
```
📁 JusteTemps
📁 Products
📦 Package Dependencies
   └─ supabase-swift
```

## 🎯 Résultat attendu

Une fois le package ajouté :
- ✅ L'import `import Supabase` fonctionne
- ✅ Le projet compile sans erreur
- ✅ Vous pouvez utiliser Supabase dans votre code

## ⏱️ Temps estimé

- Ajout du package : 2-5 minutes
- Résolution des dépendances : 1-3 minutes
- **Total : 3-8 minutes**

---

**Note importante** : Vous devez absolument faire cela dans Xcode. Je ne peux pas ajouter le package automatiquement car cela nécessite l'interface graphique de Xcode.

