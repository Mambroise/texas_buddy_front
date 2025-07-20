
# texas_buddy

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Stratégie de persistance des données

Nous ne stockons en local **que** les données nécessaires pour offrir une expérience optimisée et maîtrisée :

1. **Publicités sélectionnées**
    - Suite à l’appel à l’endpoint `api/activities/nearby`, seules les **advertisements** actives (format native_ads) retenues par le serveur publicitaire sont persistées en base SQLite.
    - Objectif : afficher les pubs ciblées même hors ligne et suivre les impressions/clics.

2. **Profil utilisateur**
    - Dès la première connexion, on récupère et stocke les informations de profil (`UserModel`) en local.
    - Permet de maintenir une session et d’afficher les données du compte sans autre requête.

3. **Voyages planifiés et non passés**
    - Seuls les **TripModel** dont la date de fin est postérieure à aujourd’hui sont conservés.
    - Chaque `TripModel` inclut ses **TripDayModel** et **TripStepModel** associés pour le planning offline.

4. **Activités et événements du planning**
    - Pour chaque voyage planifié, on persiste les **ActivityModel** et **EventModel** qui composent les étapes (`TripStepModel`).
    - Assure la cohérence entre carte, détails et historique du voyage, même sans connexion.

> 📌 **Rappel** :
> - Les autres données temporaires (autres activités/événements de la carte, flux « nearby » complet) ne sont **pas** stockées en local.
> - Pour un mode offline plus poussé, on pourrait envisager un cache TTL, mais ce n’est pas requis pour l’instant.
