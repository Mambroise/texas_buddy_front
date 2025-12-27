// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'l10n.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class L10nFr extends L10n {
  L10nFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Texas Buddy';

  @override
  String get splashWelcome => 'Bienvenue dans Texas Buddy';

  @override
  String get settings => 'Paramètres';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get settingsLanguage => 'Langue';

  @override
  String get languageEnglish => 'Anglais';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageSpanish => 'Espagnol';

  @override
  String get loginLoading => 'Bienvenue sur Texas Buddy...';

  @override
  String get loginFailed => 'Échec de la connexion';

  @override
  String get email => 'E-mail';

  @override
  String get password => 'Mot de passe';

  @override
  String get login => 'Se connecter';

  @override
  String get firstTimeSignup => 'Première fois ? Inscrivez-vous !';

  @override
  String get forgotPasswordQ => 'Mot de passe oublié ?';

  @override
  String get verifyAndSignup => 'Vérifier & S’inscrire';

  @override
  String get forgotRegistrationNumberQ => 'Numéro d’inscription oublié ?';

  @override
  String get backToLogin => 'Retour à la connexion';

  @override
  String get backToRegister => 'Retour à l’inscription';

  @override
  String get sendResetCode => 'Envoyer le code de réinitialisation';

  @override
  String get sendRegistrationNumber => 'Envoyer le numéro d’inscription';

  @override
  String get enterRegistrationCodeTitle => 'Saisissez le code envoyé pour finaliser l’inscription';

  @override
  String get enterResetCodeTitle => 'Saisissez votre code de vérification secret';

  @override
  String get codeLabel => 'Code';

  @override
  String get send => 'Envoyer';

  @override
  String get setYourPassword => 'Définissez votre mot de passe';

  @override
  String get setYourNewPassword => 'Définissez votre nouveau mot de passe';

  @override
  String get newPassword => 'Nouveau mot de passe';

  @override
  String get confirmPassword => 'Confirmez le mot de passe';

  @override
  String get passwordsDoNotMatch => 'Les mots de passe ne correspondent pas';

  @override
  String get submit => 'Valider';

  @override
  String get passwordResetSuccess => 'Mot de passe réinitialisé. Vous pouvez vous connecter.';

  @override
  String get passwordRuleLength => 'Au moins 8 caractères';

  @override
  String get passwordRuleNumber => 'Au moins un chiffre';

  @override
  String get passwordRuleSpecial => 'Au moins un caractère spécial';

  @override
  String get passwordRuleUpper => 'Au moins une majuscule';

  @override
  String get passwordRuleLetter => 'Au moins une lettre';

  @override
  String get logout => 'Se déconnecter';

  @override
  String get profile => 'Votre profil';

  @override
  String get address => 'Adresse';

  @override
  String get modify => 'Modifier';

  @override
  String get accountSecurity => 'Compte & sécurité';

  @override
  String get registrationNumber => 'Numéro d’enregistrement';

  @override
  String get firstIp => 'Première IP';

  @override
  String get secondIp => 'Seconde IP';

  @override
  String eventsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# évènements',
      one: '# évènement',
    );
    return '$_temp0';
  }

  @override
  String welcomeUser(Object name) {
    return 'Bienvenue, $name !';
  }

  @override
  String todayDate(Object date) {
    return 'Nous sommes le $date';
  }

  @override
  String get mapTab => 'Carte';

  @override
  String get planningTab => 'Planning';

  @override
  String get communityTab => 'Communauté';

  @override
  String get loading => 'Chargement…';

  @override
  String get refresh => 'Rafraîchir';

  @override
  String get guest => 'Invité';

  @override
  String get editProfile => 'Modifier le profil';

  @override
  String get profileEditComingSoon => 'À venir : édition du profil';

  @override
  String get mapModeEventsTitle => 'Événements de l’année';

  @override
  String mapModeEventsSubtitle(int year) {
    return 'Voir les événements $year dans la zone visible';
  }

  @override
  String get mapModeNearbyTitle => 'Activités et événements';

  @override
  String get mapModeNearbySubtitle => 'Revenir à la recherche Nearby';

  @override
  String get recenterMap => 'Recentrer la carte';

  @override
  String get categoryAll => 'Tous';

  @override
  String get categoryEvents => 'Événements';

  @override
  String get categoryEat => 'Manger';

  @override
  String get categoryDrink => 'Boire';

  @override
  String get categoryGoOut => 'Sortir';

  @override
  String get categoryHaveFun => 'S’amuser';

  @override
  String get categoryFree => 'Gratuit';

  @override
  String get somethingWentWrong => 'Une erreur est survenue.';

  @override
  String get networkError => 'Erreur réseau. Vérifiez votre connexion.';

  @override
  String get timeoutError => 'Délai dépassé. Réessayez.';

  @override
  String get serverUnavailable => 'Serveur indisponible. Réessayez plus tard.';

  @override
  String get unauthorizedError => 'Vous devez vous connecter.';

  @override
  String get forbiddenError => 'Vous n’avez pas l’autorisation.';

  @override
  String get notFoundError => 'Introuvable.';

  @override
  String get conflictError => 'Conflit. Veuillez réessayer.';

  @override
  String get rateLimitError => 'Trop de requêtes. Patientez.';

  @override
  String get validationError => 'Certains champs sont invalides.';

  @override
  String get parseError => 'Erreur de données.';

  @override
  String get tripCreateTitle => 'Nouveau voyage';

  @override
  String get tripCreateNameLabel => 'Titre du voyage';

  @override
  String get tripCreateNameHint => 'Ex. Roadtrip Austin';

  @override
  String get tripCreateDatesLabel => 'Dates';

  @override
  String get tripCreateDatesPick => 'Sélectionner les dates';

  @override
  String get tripCreateSave => 'OK';

  @override
  String get tripCreateCancel => 'Annuler';

  @override
  String get tripCreateCreate => 'Créer';

  @override
  String get tripCreateValidationNameRequired => 'Le titre est requis';

  @override
  String tripCreateValidationNameMax(Object max) {
    return 'Maximum $max caractères';
  }

  @override
  String get tripCreateValidationDatesRequired => 'Veuillez choisir une période';

  @override
  String get tripCreateTodoPersist => 'TODO : enregistrer le voyage en BDD';

  @override
  String get trips_create_success => 'Voyage créé avec succès';

  @override
  String get tripCreateAdults => 'Adultes';

  @override
  String get tripCreateChildren => 'Enfants';

  @override
  String get trips_add_label => 'Ajouter un voyage';

  @override
  String get trips_actions_delete_tooltip => 'Supprimer';

  @override
  String get trips_actions_edit_tooltip => 'Modifier';

  @override
  String get trips_delete_title => 'Supprimer ce voyage ?';

  @override
  String get trips_delete_confirm => 'Supprimer';

  @override
  String get trips_delete_toast => 'Suppression confirmée (UI seulement).';

  @override
  String get trips_edit_toast => 'Édition à venir.';

  @override
  String get common_cancel => 'Annuler';

  @override
  String trips_delete_message(Object tripTitle) {
    return '« $tripTitle » sera supprimé de votre liste. Cette action est irréversible.';
  }

  @override
  String get trips_delete_success => 'Voyage supprimé.';

  @override
  String get trips_delete_error => 'Échec de la suppression du voyage.';

  @override
  String get trips_update_success => 'Voyage mis à jour.';

  @override
  String get trips_update_error => 'Échec de la mise à jour du voyage.';

  @override
  String get tripEditTitle => 'Modifier le voyage';

  @override
  String get tripEditSave => 'Enregistrer';

  @override
  String get tripNoAddress => 'Aucune adresse';

  @override
  String get addHotelAddress => 'ajouter l\'adresse';

  @override
  String get addressFormTitle => 'Définir l\'adresse de l\'hôtel';

  @override
  String get cityLabel => 'Ville';

  @override
  String get cityHint => 'ex. Dallas';

  @override
  String get addressLabel => 'Adresse';

  @override
  String get addressHint => 'Tape au moins 3 lettres…';

  @override
  String get fillCityFirst => 'Saisis d\'abord la ville';

  @override
  String get typeAtLeast3Chars => 'Tape au moins 3 lettres pour rechercher.';

  @override
  String get genericError => 'Une erreur est survenue.';

  @override
  String get noResults => 'Aucun résultat.';

  @override
  String get planning_select_trip_hint => 'Sélectionnez un voyage pour commencer à planifier ✨';

  @override
  String get planning_select_trip_hintDescription => 'Texte du bandeau affiché dans l\'overlay de planning quand aucun voyage n\'est ouvert.';

  @override
  String get timeline_delete_title => 'Supprimer l’étape';

  @override
  String timeline_delete_message(String stepTitle) {
    return 'Voulez-vous vraiment supprimer l’étape « $stepTitle » ?';
  }

  @override
  String timeline_edit_duration_title(String stepTitle) {
    return 'Modifier « $stepTitle »';
  }

  @override
  String get timeline_edit_duration_subtitle => 'Ajuste la durée de l\'activité. Les étapes suivantes seront décalées automatiquement.';

  @override
  String get common_hours_short => 'h';

  @override
  String get common_minutes_short => 'min';

  @override
  String get common_save => 'Enregistrer';

  @override
  String get timeline_edit_success => 'Durée mise à jour, la journée a été recalée.';

  @override
  String get timeline_edit_error => 'Impossible de mettre à jour cette activité.';

  @override
  String get timeline_drop_occupied => 'Créneau déjà occupé';

  @override
  String get interestsTitle => 'Choisis tes centres d’intérêt';

  @override
  String get interestsSubtitle => 'Sélectionne quelques thèmes pour personnaliser tes recommandations.';

  @override
  String get myInterests => 'Mes centres d’intérêt';

  @override
  String get interestsOpenCta => 'Modifier mes centres d’intérêt';

  @override
  String get search => 'Rechercher';

  @override
  String get interestsLoading => 'Chargement des centres d’intérêt…';

  @override
  String get interestsLoadError => 'Impossible de charger les centres d’intérêt.';

  @override
  String get interestsRetry => 'Réessayer';

  @override
  String get interestsSave => 'Enregistrer';

  @override
  String get interestsSkip => 'Plus tard';

  @override
  String get interestsClose => 'Fermer';

  @override
  String get interestsMinOneError => 'Choisis au moins un centre d’intérêt.';

  @override
  String get interestsSaveSuccess => 'Centres d’intérêt enregistrés.';

  @override
  String get interestsSaveError => 'Impossible d’enregistrer tes centres d’intérêt.';
}
