# Résolution des packages Swift manquants

## Erreur
```
Missing package product 'PostgREST'
Missing package product 'Functions'
Missing package product 'Supabase'
Missing package product 'Auth'
Missing package product 'Storage'
Missing package product 'Realtime'
```

## Solution : Réinitialiser les packages Swift

### Méthode 1 : Résoudre les packages dans Xcode (Recommandée)

1. **Ouvrez le projet dans Xcode**
   - Ouvrez `JusteTemps.xcodeproj`

2. **Résolvez les packages**
   - Dans la barre de menu : **File → Packages → Resolve Package Versions**
   - OU : **File → Packages → Reset Package Caches** (si la première option ne fonctionne pas)

3. **Attendez la résolution**
   - Xcode va télécharger et résoudre tous les packages
   - Une barre de progression apparaîtra en bas de l'écran
   - Cela peut prendre 1-3 minutes

4. **Nettoyez et reconstruisez**
   - **Product → Clean Build Folder** (⇧⌘K)
   - **Product → Build** (⌘B)

### Méthode 2 : Supprimer et réajouter le package

Si la méthode 1 ne fonctionne pas :

1. **Supprimez le package**
   - Sélectionnez le projet (icône bleue) dans le navigateur
   - Allez dans l'onglet **"Package Dependencies"**
   - Sélectionnez `supabase-swift`
   - Cliquez sur le bouton **"-"** pour le supprimer

2. **Supprimez le cache**
   - Fermez Xcode
   - Supprimez le dossier DerivedData :
     ```bash
     rm -rf ~/Library/Developer/Xcode/DerivedData/JusteTemps-*
     ```
   - Supprimez le fichier Package.resolved (optionnel) :
     ```bash
     rm JusteTemps.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved
     ```

3. **Rouvrez Xcode et réajoutez le package**
   - Rouvrez `JusteTemps.xcodeproj`
   - **File → Add Package Dependencies...**
   - Entrez l'URL : `https://github.com/supabase/supabase-swift`
   - Sélectionnez **"Up to Next Major Version"** avec la version la plus récente
   - Cliquez sur **"Add Package"**
   - Dans la fenêtre suivante, cochez **"JusteTemps"** dans la liste des targets
   - Cliquez sur **"Add Package"**

4. **Vérifiez que les produits sont liés**
   - Sélectionnez le target **"JusteTemps"**
   - Allez dans l'onglet **"General"**
   - Descendez jusqu'à **"Frameworks, Libraries, and Embedded Content"**
   - Vérifiez que tous les produits suivants sont présents :
     - ✅ Supabase
     - ✅ Auth
     - ✅ PostgREST
     - ✅ Realtime
     - ✅ Storage
     - ✅ Functions
   - Si un produit manque, cliquez sur **"+"** et ajoutez-le depuis **"Package Products"**

5. **Nettoyez et reconstruisez**
   - **Product → Clean Build Folder** (⇧⌘K)
   - **Product → Build** (⌘B)

### Méthode 3 : Vérifier la connexion Internet

Parfois, Xcode ne peut pas télécharger les packages si la connexion est instable :

1. Vérifiez votre connexion Internet
2. Essayez de résoudre les packages à nouveau
3. Si vous êtes derrière un proxy/firewall, configurez les paramètres réseau de Xcode :
   - **Xcode → Settings → Accounts → Download Manual Profiles** (pour forcer une connexion)

### Méthode 4 : Vérifier les paramètres du projet

1. **Sélectionnez le projet** (icône bleue)
2. Allez dans l'onglet **"Package Dependencies"**
3. Vérifiez que `supabase-swift` est listé avec l'URL correcte :
   ```
   https://github.com/supabase/supabase-swift
   ```
4. Vérifiez que la version est correcte (généralement "Up to Next Major Version: 2.5.1")

### Vérification finale

Une fois les packages résolus :

1. ✅ Les erreurs "Missing package product" devraient disparaître
2. ✅ Vous devriez voir `supabase-swift` dans "Package Dependencies"
3. ✅ Les produits (Supabase, Auth, etc.) devraient être dans "Frameworks, Libraries, and Embedded Content"
4. ✅ Le projet devrait compiler sans erreur

## Note importante

Si vous continuez à avoir des problèmes après avoir essayé toutes ces méthodes :

1. Vérifiez que vous utilisez une version récente de Xcode (14+)
2. Vérifiez que vous avez une connexion Internet stable
3. Essayez de redémarrer Xcode
4. Essayez de redémarrer votre Mac

