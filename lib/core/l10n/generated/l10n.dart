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
