# Ajouter un logo à l'application JusteTemps

## ✅ Code déjà configuré

J'ai déjà configuré le code pour utiliser un logo. Il suffit maintenant d'ajouter vos images de logo dans Xcode.

## Étape 1 : Créer vos images de logo

Vous devez créer 3 versions de votre logo pour toutes les tailles d'écran :
- **AppLogo.png** : 256x256 pixels (pour @1x)
- **AppLogo@2x.png** : 512x512 pixels (pour @2x - iPhone Retina)
- **AppLogo@3x.png** : 768x768 pixels (pour @3x - iPhone Plus/Pro Max)

### Options pour créer le logo :

1. **Utiliser un outil en ligne** (Recommandé) :
   - [Canva](https://www.canva.com) : Créez un logo avec une icône d'horloge (gratuit)
   - [LogoMaker](https://www.logomaker.com) : Outil simple pour créer des logos
   - [Figma](https://www.figma.com) : Design vectoriel professionnel (gratuit)

2. **Utiliser une icône simple** :
   - Créez un logo avec une horloge ou un chronomètre
   - Utilisez des couleurs qui correspondent à votre app (bleu/violet selon votre thème)

3. **Logo temporaire** :
   - En attendant, l'application utilise l'icône système `clock.fill`
   - Cela fonctionne déjà, mais un logo personnalisé sera plus professionnel

## Étape 2 : Ajouter les images dans Xcode

1. **Ouvrez Xcode**
   - Ouvrez le projet `JusteTemps.xcodeproj`

2. **Ouvrez Assets.xcassets**
   - Dans le navigateur de projet (panneau de gauche), cliquez sur `JusteTemps/Assets.xcassets`
   - Vous devriez voir "AppLogo" dans la liste (dossier que j'ai créé)

3. **Si "AppLogo" n'existe pas, créez-le** :
   - Clic droit dans `Assets.xcassets` → "New Image Set"
   - Renommez-le en "AppLogo"

4. **Ajoutez vos images**
   - Cliquez sur "AppLogo" dans la liste
   - Glissez-déposez vos 3 images dans les cases correspondantes :
     - `AppLogo.png` → glissez dans la case "1x"
     - `AppLogo@2x.png` → glissez dans la case "2x"
     - `AppLogo@3x.png` → glissez dans la case "3x"

5. **Vérifiez**
   - Les images devraient apparaître dans les 3 cases
   - Vous pouvez voir un aperçu de votre logo

## Étape 3 : Utilisation automatique

Une fois les images ajoutées, le logo apparaîtra automatiquement dans :
- ✅ **LoginView** : Logo principal sur l'écran de connexion (80x80 pixels)
- ✅ **ScreenTimeView** : Logo dans l'en-tête principal (60x60 pixels)

Le code détecte automatiquement si "AppLogo" existe :
- Si le logo existe → Affiche votre logo personnalisé
- Si le logo n'existe pas → Affiche l'icône système `clock.fill` (fallback)

## Option : Utiliser un logo SVG (Recommandé pour débutants)

Si vous créez un logo SVG (vectoriel), c'est encore plus simple :

1. **Créez un fichier SVG** avec votre logo (Canva peut exporter en SVG)
2. **Dans Xcode** :
   - Glissez le fichier SVG directement dans `Assets.xcassets`
   - Xcode le convertira automatiquement aux bonnes tailles
   - Renommez-le en "AppLogo"

## Résultat

Une fois que vous avez ajouté vos images, le logo apparaîtra :
- Sur l'écran de connexion (grand, centré)
- Sur l'écran principal (plus petit, en haut)
- Remplacera l'icône système `clock.fill`

**C'est tout ! Le code est déjà prêt, il suffit d'ajouter vos images dans Xcode.**
