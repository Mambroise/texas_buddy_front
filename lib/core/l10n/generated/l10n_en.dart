// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'l10n.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class L10nEn extends L10n {
  L10nEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Texas Buddy';

  @override
  String get splashWelcome => 'Welcome to Texas Buddy';

  @override
  String get loginLoading => 'Welcome to Texas Buddy...';

  @override
  String get loginFailed => 'Login failed';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get login => 'Login';

  @override
  String get firstTimeSignup => 'First time? Sign up now!';

  @override
  String get forgotPasswordQ => 'Forgot password?';

  @override
  String get verifyAndSignup => 'Verify & Sign up';

  @override
  String get forgotRegistrationNumberQ => 'Forgot registration number?';

  @override
  String get backToLogin => 'Back to login';

  @override
  String get backToRegister => 'Back to register';

  @override
  String get sendResetCode => 'Send reset code';

  @override
  String get sendRegistrationNumber => 'Send registration number';

  @override
  String get enterRegistrationCodeTitle => 'Enter the code sent to complete registration';

  @override
  String get enterResetCodeTitle => 'Enter your secret verification code';

  @override
  String get codeLabel => 'Code';

  @override
  String get send => 'Send';

  @override
  String get setYourPassword => 'Set your password';

  @override
  String get setYourNewPassword => 'Set your new password';

  @override
  String get newPassword => 'New password';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get submit => 'Submit';

  @override
  String get passwordResetSuccess => 'Password reset. You can log in now.';

  @override
  String get passwordRuleLength => 'At least 8 characters';

  @override
  String get passwordRuleNumber => 'At least one number';

  @override
  String get passwordRuleSpecial => 'At least one special character';

  @override
  String get passwordRuleUpper => 'At least one uppercase letter';

  @override
  String get passwordRuleLetter => 'At least one letter';

  @override
  String get logout => 'Logout';

  @override
  String get profile => 'Your Profile';

  @override
  String get address => 'Address';

  @override
  String get modify => 'Edit';

  @override
  String get accountSecurity => 'Account & Security';

  @override
  String get registrationNumber => 'Registration number';

  @override
  String get firstIp => 'First IP';

  @override
  String get secondIp => 'Second IP';

  @override
  String eventsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# events',
      one: '# event',
    );
    return '$_temp0';
  }

  @override
  String welcomeUser(Object name) {
    return 'Welcome, $name!';
  }

  @override
  String todayDate(Object date) {
    return 'Today is $date';
  }

  @override
  String get mapTab => 'Map';

  @override
  String get planningTab => 'Planning';

  @override
  String get communityTab => 'Community';

  @override
  String get loading => 'Loading...';

  @override
  String get refresh => 'Refresh';

  @override
  String get guest => 'Guest';

  @override
  String get editProfile => 'Edit profile';

  @override
  String get profileEditComingSoon => 'Coming soon: profile editing';

  @override
  String get mapModeEventsTitle => 'This year\'s events';

  @override
  String mapModeEventsSubtitle(int year) {
    return 'See $year events in the visible area';
  }

  @override
  String get mapModeNearbyTitle => 'Activities & events';

  @override
  String get mapModeNearbySubtitle => 'Back to Nearby search';

  @override
  String get recenterMap => 'Recenter map';

  @override
  String get categoryAll => 'All';

  @override
  String get categoryEvents => 'Events';

  @override
  String get categoryEat => 'Eat';

  @override
  String get categoryDrink => 'Drink';

  @override
  String get categoryGoOut => 'Go out';

  @override
  String get categoryHaveFun => 'Have fun';

  @override
  String get categoryFree => 'Free';

  @override
  String get somethingWentWrong => 'Something went wrong.';

  @override
  String get networkError => 'Network error. Check your connection.';

  @override
  String get timeoutError => 'Request timed out. Try again.';

  @override
  String get serverUnavailable => 'Server unavailable. Please try later.';

  @override
  String get unauthorizedError => 'You need to sign in.';

  @override
  String get forbiddenError => 'You don\'t have permission to do this.';

  @override
  String get notFoundError => 'Not found.';

  @override
  String get conflictError => 'Conflict. Please retry.';

  @override
  String get rateLimitError => 'Too many requests. Please wait.';

  @override
  String get validationError => 'Some fields are invalid.';

  @override
  String get parseError => 'Data error.';
}
