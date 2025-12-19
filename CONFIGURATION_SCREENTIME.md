# Configuration de Screen Time dans JusteTemps

## Important : Limitations de l'API FamilyControls

L'API FamilyControls d'Apple est principalement conçue pour le **contrôle parental** (bloquer des applications) et ne permet pas de récupérer directement les données historiques de temps d'écran de l'utilisateur.

### Ce qui fonctionne actuellement :

1. ✅ **Demande d'autorisation Screen Time** : L'application peut demander l'autorisation à l'utilisateur
2. ✅ **Surveillance en temps réel** : Utilisation de `DeviceActivityCenter` pour surveiller l'activité
3. ✅ **Collecte de données** : Le `DeviceActivityMonitor` enregistre les données progressivement

### Ce qui nécessite une configuration supplémentaire :

Pour obtenir les **vraies données historiques** de temps d'écran directement depuis Screen Time, il faudrait :

1. **Créer une extension DeviceActivityReport** :
   - Nouveau target dans Xcode de type "Device Activity Report Extension"
   - Créer une vue SwiftUI qui hérite de `DeviceActivityReportView`
   - Configurer les entitlements appropriés

2. **Configurer les entitlements dans Xcode** :
   - Activer la capability "Family Controls" dans les Signing & Capabilities
   - Ajouter l'entitlement `com.apple.developer.family-controls`

3. **Utiliser DeviceActivityReport.Context** :
   - Créer des contextes pour différents types de rapports (.usage, .notifications, etc.)
   - Utiliser ces contextes pour obtenir les données depuis Screen Time

## Configuration actuelle

L'application demande actuellement l'autorisation Screen Time et utilise `DeviceActivityCenter` pour surveiller l'activité. Les données sont collectées progressivement via le `DeviceActivityMonitor` et sauvegardées localement.

## Note pour l'utilisateur

Si vous voyez des données simulées, c'est parce que :
- L'autorisation Screen Time n'a pas été accordée, OU
- Les données réelles n'ont pas encore été collectées (cela prend du temps pour que l'API collecte les données)

Pour avoir les meilleures données :
1. Accorder l'autorisation Screen Time lorsque demandée
2. Laisser l'application fonctionner pendant quelques heures/jours pour collecter les données
3. Les données seront progressivement mises à jour au fur et à mesure

