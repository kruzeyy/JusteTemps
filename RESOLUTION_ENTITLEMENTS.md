# Résolution de l'erreur "Entitlements file was modified during the build"

## Problème

Vous voyez cette erreur :
```
Entitlements file "JusteTemps.entitlements" was modified during the build, which is not supported.
```

## Cause

Xcode modifie automatiquement le fichier entitlements pendant le build pour ajouter des entitlements basés sur les capabilities que vous avez activées (comme Family Controls). Cela peut causer des conflits.

## Solution appliquée

J'ai ajouté `CODE_SIGN_ALLOW_ENTITLEMENTS_MODIFICATION = YES` dans les Build Settings du projet. Cela permet à Xcode de modifier le fichier entitlements pendant le build.

## Vérification

Le fichier `JusteTemps.entitlements` devrait maintenant contenir :
- `com.apple.developer.family-controls` (pour Screen Time)
- `com.apple.developer.default-data-protection` (pour la protection des données)

## Alternative : Configuration manuelle dans Xcode

Si vous préférez configurer manuellement :

1. **Ouvrez Xcode**
2. **Sélectionnez le projet "JusteTemps"**
3. **Sélectionnez le target "JusteTemps"**
4. **Allez dans "Build Settings"**
5. **Recherchez "Code Signing Entitlements"**
6. **Recherchez "Allow Entitlements Modification"**
7. **Définissez-le sur "Yes"**

## Note importante

Cette option permet à Xcode de modifier automatiquement les entitlements pendant le build, ce qui est normal quand vous utilisez des capabilities comme Family Controls. Xcode ajoutera automatiquement les entitlements nécessaires basés sur les capabilities que vous avez activées dans "Signing & Capabilities".

## Vérification finale

Après cette modification :
1. **Nettoyez le build** : `Product` → `Clean Build Folder` (⇧⌘K)
2. **Recompilez** : `Product` → `Build` (⌘B)
3. L'erreur devrait disparaître

