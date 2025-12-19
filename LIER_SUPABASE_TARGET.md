# 🔗 Lier Supabase au target JusteTemps

## ⚠️ Problème actuel

Le package `supabase-swift` est installé mais n'est pas lié au target "JusteTemps", ce qui cause l'erreur `No such module 'Supabase'`.

## ✅ Solution : Lier le package au target

### Méthode 1 : Via l'interface Xcode (Recommandée)

1. **Ouvrez le projet dans Xcode**
   - Le projet devrait maintenant s'ouvrir sans erreur

2. **Sélectionnez le target**
   - Dans le navigateur de projet (panneau de gauche), cliquez sur l'icône bleue **"JusteTemps"** en haut
   - Sous **"TARGETS"**, sélectionnez **"JusteTemps"**

3. **Allez dans l'onglet "General"**
   - En haut, cliquez sur l'onglet **"General"**

4. **Ajoutez le framework**
   - Descendez jusqu'à la section **"Frameworks, Libraries, and Embedded Content"**
   - Cliquez sur le bouton **"+"** (en bas à gauche de cette section)

   - Dans la fenêtre qui s'ouvre, vous devriez voir une section **"Package Products"**
   - Sélectionnez **"Supabase"**
   - Cliquez sur **"Add"**

6. **Vérifiez**
   - "Supabase" devrait maintenant apparaître dans la liste "Frameworks, Libraries, and Embedded Content"
   - L'erreur `No such module 'Supabase'` devrait disparaître

### Méthode 2 : Via l'onglet "Build Phases"

1. **Sélectionnez le target "JusteTemps"**

2. **Allez dans l'onglet "Build Phases"**

3. **Développez "Link Binary With Libraries"**

4. **Cliquez sur "+"**

5. **Sélectionnez "Supabase"** dans "Package Products"

6. **Cliquez sur "Add"**

## ✅ Vérification

Après avoir lié le package :

1. **Nettoyez le build**
   - **Product → Clean Build Folder** (⇧⌘K)

2. **Compilez**
   - **Product → Build** (⌘B)
   - L'erreur devrait disparaître

3. **Vérifiez dans le code**
   - L'import `import Supabase` devrait fonctionner sans erreur

## 🎯 Résultat attendu

Une fois le package lié :
- ✅ "Supabase" apparaît dans "Frameworks, Libraries, and Embedded Content"
- ✅ Le projet compile sans erreur
- ✅ `import Supabase` fonctionne dans tous vos fichiers

## 📝 Note importante

Le package est déjà installé et référencé dans le projet. Il faut juste le lier explicitement au target pour que Xcode sache l'utiliser lors de la compilation.

