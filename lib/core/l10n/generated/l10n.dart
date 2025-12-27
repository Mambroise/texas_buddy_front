import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'l10n_en.dart';
import 'l10n_es.dart';
import 'l10n_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of L10n
/// returned by `L10n.of(context)`.
///
/// Applications need to include `L10n.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/l10n.dart';
///
/// return MaterialApp(
///   localizationsDelegates: L10n.localizationsDelegates,
///   supportedLocales: L10n.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the L10n.supportedLocales
/// property.
abstract class L10n {
  L10n(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static L10n of(BuildContext context) {
    return Localizations.of<L10n>(context, L10n)!;
  }

  static const LocalizationsDelegate<L10n> delegate = _L10nDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('fr')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Texas Buddy'**
  String get appTitle;

  /// No description provided for @splashWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Texas Buddy'**
  String get splashWelcome;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageFrench.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get languageFrench;

  /// No description provided for @languageSpanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get languageSpanish;

  /// No description provided for @loginLoading.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Texas Buddy...'**
  String get loginLoading;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed'**
  String get loginFailed;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @firstTimeSignup.
  ///
  /// In en, this message translates to:
  /// **'First time? Sign up now!'**
  String get firstTimeSignup;

  /// No description provided for @forgotPasswordQ.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPasswordQ;

  /// No description provided for @verifyAndSignup.
  ///
  /// In en, this message translates to:
  /// **'Verify & Sign up'**
  String get verifyAndSignup;

  /// No description provided for @forgotRegistrationNumberQ.
  ///
  /// In en, this message translates to:
  /// **'Forgot registration number?'**
  String get forgotRegistrationNumberQ;

  /// No description provided for @backToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to login'**
  String get backToLogin;

  /// No description provided for @backToRegister.
  ///
  /// In en, this message translates to:
  /// **'Back to register'**
  String get backToRegister;

  /// No description provided for @sendResetCode.
  ///
  /// In en, this message translates to:
  /// **'Send reset code'**
  String get sendResetCode;

  /// No description provided for @sendRegistrationNumber.
  ///
  /// In en, this message translates to:
  /// **'Send registration number'**
  String get sendRegistrationNumber;

  /// No description provided for @enterRegistrationCodeTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the code sent to complete registration'**
  String get enterRegistrationCodeTitle;

  /// No description provided for @enterResetCodeTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your secret verification code'**
  String get enterResetCodeTitle;

  /// No description provided for @codeLabel.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get codeLabel;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @setYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Set your password'**
  String get setYourPassword;

  /// No description provided for @setYourNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Set your new password'**
  String get setYourNewPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPassword;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @passwordResetSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password reset. You can log in now.'**
  String get passwordResetSuccess;

  /// No description provided for @passwordRuleLength.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters'**
  String get passwordRuleLength;

  /// No description provided for @passwordRuleNumber.
  ///
  /// In en, this message translates to:
  /// **'At least one number'**
  String get passwordRuleNumber;

  /// No description provided for @passwordRuleSpecial.
  ///
  /// In en, this message translates to:
  /// **'At least one special character'**
  String get passwordRuleSpecial;

  /// No description provided for @passwordRuleUpper.
  ///
  /// In en, this message translates to:
  /// **'At least one uppercase letter'**
  String get passwordRuleUpper;

  /// No description provided for @passwordRuleLetter.
  ///
  /// In en, this message translates to:
  /// **'At least one letter'**
  String get passwordRuleLetter;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Your Profile'**
  String get profile;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @modify.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get modify;

  /// No description provided for @accountSecurity.
  ///
  /// In en, this message translates to:
  /// **'Account & Security'**
  String get accountSecurity;

  /// No description provided for @registrationNumber.
  ///
  /// In en, this message translates to:
  /// **'Registration number'**
  String get registrationNumber;

  /// No description provided for @firstIp.
  ///
  /// In en, this message translates to:
  /// **'First IP'**
  String get firstIp;

  /// No description provided for @secondIp.
  ///
  /// In en, this message translates to:
  /// **'Second IP'**
  String get secondIp;

  /// Number of events in a list
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one {# event} other {# events}}'**
  String eventsCount(int count);

  /// No description provided for @welcomeUser.
  ///
  /// In en, this message translates to:
  /// **'Welcome, {name}!'**
  String welcomeUser(Object name);

  /// No description provided for @todayDate.
  ///
  /// In en, this message translates to:
  /// **'Today is {date}'**
  String todayDate(Object date);

  /// No description provided for @mapTab.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get mapTab;

  /// No description provided for @planningTab.
  ///
  /// In en, this message translates to:
  /// **'Planning'**
  String get planningTab;

  /// No description provided for @communityTab.
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get communityTab;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @guest.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get guest;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editProfile;

  /// No description provided for @profileEditComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon: profile editing'**
  String get profileEditComingSoon;

  /// No description provided for @mapModeEventsTitle.
  ///
  /// In en, this message translates to:
  /// **'This year\'s events'**
  String get mapModeEventsTitle;

  /// Subtitle showing the year-filtered events in current viewport
  ///
  /// In en, this message translates to:
  /// **'See {year} events in the visible area'**
  String mapModeEventsSubtitle(int year);

  /// No description provided for @mapModeNearbyTitle.
  ///
  /// In en, this message translates to:
  /// **'Activities & events'**
  String get mapModeNearbyTitle;

  /// No description provided for @mapModeNearbySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Back to Nearby search'**
  String get mapModeNearbySubtitle;

  /// No description provided for @recenterMap.
  ///
  /// In en, this message translates to:
  /// **'Recenter map'**
  String get recenterMap;

  /// No description provided for @categoryAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get categoryAll;

  /// No description provided for @categoryEvents.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get categoryEvents;

  /// No description provided for @categoryEat.
  ///
  /// In en, this message translates to:
  /// **'Eat'**
  String get categoryEat;

  /// No description provided for @categoryDrink.
  ///
  /// In en, this message translates to:
  /// **'Drink'**
  String get categoryDrink;

  /// No description provided for @categoryGoOut.
  ///
  /// In en, this message translates to:
  /// **'Go out'**
  String get categoryGoOut;

  /// No description provided for @categoryHaveFun.
  ///
  /// In en, this message translates to:
  /// **'Have fun'**
  String get categoryHaveFun;

  /// No description provided for @categoryFree.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get categoryFree;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong.'**
  String get somethingWentWrong;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Network error. Check your connection.'**
  String get networkError;

  /// No description provided for @timeoutError.
  ///
  /// In en, this message translates to:
  /// **'Request timed out. Try again.'**
  String get timeoutError;

  /// No description provided for @serverUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Server unavailable. Please try later.'**
  String get serverUnavailable;

  /// No description provided for @unauthorizedError.
  ///
  /// In en, this message translates to:
  /// **'You need to sign in.'**
  String get unauthorizedError;

  /// No description provided for @forbiddenError.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have permission to do this.'**
  String get forbiddenError;

  /// No description provided for @notFoundError.
  ///
  /// In en, this message translates to:
  /// **'Not found.'**
  String get notFoundError;

  /// No description provided for @conflictError.
  ///
  /// In en, this message translates to:
  /// **'Conflict. Please retry.'**
  String get conflictError;

  /// No description provided for @rateLimitError.
  ///
  /// In en, this message translates to:
  /// **'Too many requests. Please wait.'**
  String get rateLimitError;

  /// No description provided for @validationError.
  ///
  /// In en, this message translates to:
  /// **'Some fields are invalid.'**
  String get validationError;

  /// No description provided for @parseError.
  ///
  /// In en, this message translates to:
  /// **'Data error.'**
  String get parseError;

  /// No description provided for @tripCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'New trip'**
  String get tripCreateTitle;

  /// No description provided for @tripCreateNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Trip title'**
  String get tripCreateNameLabel;

  /// No description provided for @tripCreateNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Austin Roadtrip'**
  String get tripCreateNameHint;

  /// No description provided for @tripCreateDatesLabel.
  ///
  /// In en, this message translates to:
  /// **'Dates'**
  String get tripCreateDatesLabel;

  /// No description provided for @tripCreateDatesPick.
  ///
  /// In en, this message translates to:
  /// **'Select dates'**
  String get tripCreateDatesPick;

  /// No description provided for @tripCreateSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get tripCreateSave;

  /// No description provided for @tripCreateCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get tripCreateCancel;

  /// No description provided for @tripCreateCreate.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get tripCreateCreate;

  /// No description provided for @tripCreateValidationNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Title is required'**
  String get tripCreateValidationNameRequired;

  /// No description provided for @tripCreateValidationNameMax.
  ///
  /// In en, this message translates to:
  /// **'Max {max} characters'**
  String tripCreateValidationNameMax(Object max);

  /// No description provided for @tripCreateValidationDatesRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select a date range'**
  String get tripCreateValidationDatesRequired;

  /// No description provided for @tripCreateTodoPersist.
  ///
  /// In en, this message translates to:
  /// **'TODO: persist the trip in DB'**
  String get tripCreateTodoPersist;

  /// No description provided for @trips_create_success.
  ///
  /// In en, this message translates to:
  /// **'trip successfully created'**
  String get trips_create_success;

  /// No description provided for @tripCreateAdults.
  ///
  /// In en, this message translates to:
  /// **'Adults'**
  String get tripCreateAdults;

  /// No description provided for @tripCreateChildren.
  ///
  /// In en, this message translates to:
  /// **'Children'**
  String get tripCreateChildren;

  /// No description provided for @trips_add_label.
  ///
  /// In en, this message translates to:
  /// **'Add a trip'**
  String get trips_add_label;

  /// No description provided for @trips_actions_delete_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get trips_actions_delete_tooltip;

  /// No description provided for @trips_actions_edit_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get trips_actions_edit_tooltip;

  /// No description provided for @trips_delete_title.
  ///
  /// In en, this message translates to:
  /// **'Delete this trip?'**
  String get trips_delete_title;

  /// No description provided for @trips_delete_confirm.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get trips_delete_confirm;

  /// No description provided for @trips_delete_toast.
  ///
  /// In en, this message translates to:
  /// **'Deletion confirmed (UI only).'**
  String get trips_delete_toast;

  /// No description provided for @trips_edit_toast.
  ///
  /// In en, this message translates to:
  /// **'Edit coming soon.'**
  String get trips_edit_toast;

  /// No description provided for @common_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get common_cancel;

  /// No description provided for @trips_delete_message.
  ///
  /// In en, this message translates to:
  /// **'\"{tripTitle}\" will be removed from your list. This action is irreversible.'**
  String trips_delete_message(Object tripTitle);

  /// No description provided for @trips_delete_success.
  ///
  /// In en, this message translates to:
  /// **'Trip deleted.'**
  String get trips_delete_success;

  /// No description provided for @trips_delete_error.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete trip.'**
  String get trips_delete_error;

  /// No description provided for @trips_update_success.
  ///
  /// In en, this message translates to:
  /// **'Trip updated.'**
  String get trips_update_success;

  /// No description provided for @trips_update_error.
  ///
  /// In en, this message translates to:
  /// **'Failed to update trip.'**
  String get trips_update_error;

  /// No description provided for @tripEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit trip'**
  String get tripEditTitle;

  /// No description provided for @tripEditSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get tripEditSave;

  /// No description provided for @tripNoAddress.
  ///
  /// In en, this message translates to:
  /// **'No address'**
  String get tripNoAddress;

  /// No description provided for @addHotelAddress.
  ///
  /// In en, this message translates to:
  /// **'Add an address'**
  String get addHotelAddress;

  /// No description provided for @addressFormTitle.
  ///
  /// In en, this message translates to:
  /// **'Set hotel address'**
  String get addressFormTitle;

  /// No description provided for @cityLabel.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get cityLabel;

  /// No description provided for @cityHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Dallas'**
  String get cityHint;

  /// No description provided for @addressLabel.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get addressLabel;

  /// No description provided for @addressHint.
  ///
  /// In en, this message translates to:
  /// **'Type at least 3 letters…'**
  String get addressHint;

  /// No description provided for @fillCityFirst.
  ///
  /// In en, this message translates to:
  /// **'Enter the city first'**
  String get fillCityFirst;

  /// No description provided for @typeAtLeast3Chars.
  ///
  /// In en, this message translates to:
  /// **'Type at least 3 letters to search.'**
  String get typeAtLeast3Chars;

  /// No description provided for @genericError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred.'**
  String get genericError;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No results found.'**
  String get noResults;

  /// No description provided for @planning_select_trip_hint.
  ///
  /// In en, this message translates to:
  /// **'Select a trip to start planning ✨'**
  String get planning_select_trip_hint;

  /// No description provided for @planning_select_trip_hintDescription.
  ///
  /// In en, this message translates to:
  /// **'Banner text displayed in the planning overlay when no trip is currently open.'**
  String get planning_select_trip_hintDescription;

  /// No description provided for @timeline_delete_title.
  ///
  /// In en, this message translates to:
  /// **'Delete step'**
  String get timeline_delete_title;

  /// Confirmation message shown before deleting a step in the timeline
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the step \"{stepTitle}\"?'**
  String timeline_delete_message(String stepTitle);

  /// Title of the dialog used to edit an activity duration in the timeline.
  ///
  /// In en, this message translates to:
  /// **'Edit “{stepTitle}”'**
  String timeline_edit_duration_title(String stepTitle);

  /// No description provided for @timeline_edit_duration_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Adjust the activity duration. Subsequent steps will shift automatically.'**
  String get timeline_edit_duration_subtitle;

  /// No description provided for @common_hours_short.
  ///
  /// In en, this message translates to:
  /// **'h'**
  String get common_hours_short;

  /// No description provided for @common_minutes_short.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get common_minutes_short;

  /// No description provided for @common_save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get common_save;

  /// No description provided for @timeline_edit_success.
  ///
  /// In en, this message translates to:
  /// **'Duration updated, the day has been adjusted.'**
  String get timeline_edit_success;

  /// No description provided for @timeline_edit_error.
  ///
  /// In en, this message translates to:
  /// **'Unable to update this activity.'**
  String get timeline_edit_error;

  /// Message shown when dropping a step onto an occupied slot
  ///
  /// In en, this message translates to:
  /// **'This time slot is already taken'**
  String get timeline_drop_occupied;

  /// No description provided for @interestsTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your interests'**
  String get interestsTitle;

  /// No description provided for @interestsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick a few topics to personalize your recommendations.'**
  String get interestsSubtitle;

  /// No description provided for @myInterests.
  ///
  /// In en, this message translates to:
  /// **'My interests'**
  String get myInterests;

  /// No description provided for @interestsOpenCta.
  ///
  /// In en, this message translates to:
  /// **'Edit my interests'**
  String get interestsOpenCta;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @interestsLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading interests…'**
  String get interestsLoading;

  /// No description provided for @interestsLoadError.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load your interests.'**
  String get interestsLoadError;

  /// No description provided for @interestsRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get interestsRetry;

  /// No description provided for @interestsSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get interestsSave;

  /// No description provided for @interestsSkip.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get interestsSkip;

  /// No description provided for @interestsClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get interestsClose;

  /// No description provided for @interestsMinOneError.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one interest.'**
  String get interestsMinOneError;

  /// No description provided for @interestsSaveSuccess.
  ///
  /// In en, this message translates to:
  /// **'Interests saved.'**
  String get interestsSaveSuccess;

  /// No description provided for @interestsSaveError.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t save your interests.'**
  String get interestsSaveError;
}

class _L10nDelegate extends LocalizationsDelegate<L10n> {
  const _L10nDelegate();

  @override
  Future<L10n> load(Locale locale) {
    return SynchronousFuture<L10n>(lookupL10n(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'es', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_L10nDelegate old) => false;
}

L10n lookupL10n(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return L10nEn();
    case 'es': return L10nEs();
    case 'fr': return L10nFr();
  }

  throw FlutterError(
    'L10n.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
