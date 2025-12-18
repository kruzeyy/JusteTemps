# JusteTemps

Application iOS pour gérer et suivre votre temps d'écran.

## Fonctionnalités

- 📊 **Affichage du temps d'écran** : Visualisez votre temps d'écran quotidien
- 🚫 **Gestion des applications** : Ajoutez des applications à suivre et définissez des limites
- ⏰ **Limites personnalisées** : Définissez une limite quotidienne de temps d'écran
- 🔔 **Notifications** : Recevez des alertes lorsque vous atteignez vos limites
- 📱 **Intégration Screen Time** : Accès rapide aux paramètres Screen Time d'iOS
- 📈 **Statistiques détaillées** : Nouvel onglet avec des graphiques interactifs :
  - Graphique hebdomadaire en barres
  - Top 5 des applications les plus utilisées
  - Graphique en camembert pour la répartition
  - Graphique de tendance sur 14 jours
  - Cartes de résumé avec statistiques clés

## Installation

1. Ouvrez le projet dans Xcode
2. Sélectionnez votre appareil ou simulateur
3. Appuyez sur Run (⌘R)

## Utilisation

### Configuration initiale

1. Lors du premier lancement, l'application vous demandera la permission d'envoyer des notifications
2. Définissez votre limite quotidienne de temps d'écran dans les paramètres
3. Ajoutez les applications que vous souhaitez suivre

### Suivi du temps d'écran

L'application affiche :
- Le temps d'écran total d'aujourd'hui
- Une barre de progression vers votre limite quotidienne
- Les applications les plus utilisées

### Blocage d'applications

**Note importante** : iOS ne permet pas aux applications tierces de bloquer directement d'autres applications. Pour bloquer réellement des applications :

1. Utilisez le bouton "Ouvrir les paramètres Screen Time" dans l'application
2. Configurez les limites d'applications dans les paramètres iOS
3. L'application JusteTemps vous aide à suivre et gérer votre utilisation

## Technologies

- SwiftUI
- SwiftUI Charts (pour les graphiques)
- UserNotifications
- UserDefaults pour la persistance des données

## Compatibilité

- iOS 17.0 ou supérieur
- iPhone et iPad

## Limitations

En raison des restrictions de sécurité d'iOS :
- L'application ne peut pas accéder directement au temps d'écran réel d'autres applications
- Le blocage d'applications doit être configuré via les paramètres Screen Time d'iOS
- L'application utilise un système de suivi simulé pour démontrer les fonctionnalités

## Développement

Pour améliorer l'application avec un vrai suivi du temps d'écran, vous devriez :
1. Utiliser l'API Screen Time d'Apple (nécessite une extension d'application)
2. Implémenter une extension Family Controls pour le contrôle parental
3. Demander les permissions appropriées à l'utilisateur

