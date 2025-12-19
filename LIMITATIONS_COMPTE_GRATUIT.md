# Limitations avec un compte Apple Developer gratuit

## Problème rencontré

Vous avez reçu cette erreur :
```
Cannot create a iOS App Development provisioning profile for "com.justetemps.app".
Personal development teams, including "Maxime Pontus", do not support the Family Controls (Development) capability.
```

## Explication

L'API **Family Controls** (nécessaire pour accéder aux données Screen Time) nécessite un **compte Apple Developer payant** ($99/an).

Les comptes de développement personnels gratuits ne peuvent pas utiliser cette capability.

## Solutions possibles

### Option 1 : S'inscrire à un compte Apple Developer payant (Recommandé)

**Prix** : $99 USD par an

**Avantages** :
- ✅ Accès complet à toutes les APIs iOS (dont Family Controls)
- ✅ Publication sur l'App Store
- ✅ Certificats de développement illimités
- ✅ Accès aux bêta iOS
- ✅ Support technique Apple

**Inscription** : https://developer.apple.com/programs/

### Option 2 : Utiliser l'application sans vraies données Screen Time

L'application fonctionnera avec **des données simulées** au lieu des vraies données Screen Time.

**Limitations** :
- ❌ Pas d'accès aux vraies données de temps d'écran
- ❌ Les statistiques seront simulées
- ❌ Pas de blocage réel d'applications via Screen Time

**Ce qui fonctionnera quand même** :
- ✅ Interface utilisateur complète
- ✅ Système d'authentification (Supabase)
- ✅ Statistiques avec données simulées
- ✅ Toutes les fonctionnalités sauf Screen Time réel

### Option 3 : Tester temporairement sans Family Controls

Pour tester l'application sans la capability Family Controls :

1. **Supprimez temporairement l'entitlement** :
   - Ouvrez `JusteTemps.entitlements`
   - Commentez ou supprimez la ligne `<key>com.apple.developer.family-controls</key>`
   - Ou supprimez complètement le fichier entitlements

2. **Le code utilisera automatiquement les données simulées**

3. **Note** : Vous verrez un message indiquant que Screen Time nécessite un compte payant

## Recommandation

Pour une application de gestion du temps d'écran, l'**Option 1** (compte payant) est recommandée car :
- L'API Screen Time est essentielle pour ce type d'application
- Cela permet d'accéder aux vraies données utilisateur
- Cela permet de publier l'application sur l'App Store

## Alternative : API publique

⚠️ **Il n'existe pas d'API publique alternative** pour accéder aux données Screen Time sur iOS sans Family Controls.

Apple ne fournit qu'une seule API pour accéder aux données de temps d'écran : l'API Family Controls, qui nécessite un compte payant.

