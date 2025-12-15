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
  String get settings => 'Settings';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageFrench => 'French';

  @override
  String get languageSpanish => 'Spanish';

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

  @override
  String get tripCreateTitle => 'New trip';

  @override
  String get tripCreateNameLabel => 'Trip title';

  @override
  String get tripCreateNameHint => 'e.g. Austin Roadtrip';

  @override
  String get tripCreateDatesLabel => 'Dates';

  @override
  String get tripCreateDatesPick => 'Select dates';

  @override
  String get tripCreateSave => 'Save';

  @override
  String get tripCreateCancel => 'Cancel';

  @override
  String get tripCreateCreate => 'Create';

  @override
  String get tripCreateValidationNameRequired => 'Title is required';

  @override
  String tripCreateValidationNameMax(Object max) {
    return 'Max $max characters';
  }

  @override
  String get tripCreateValidationDatesRequired => 'Please select a date range';

  @override
  String get tripCreateTodoPersist => 'TODO: persist the trip in DB';

  @override
  String get trips_create_success => 'trip successfully created';

  @override
  String get tripCreateAdults => 'Adults';

  @override
  String get tripCreateChildren => 'Children';

  @override
  String get trips_add_label => 'Add a trip';

  @override
  String get trips_actions_delete_tooltip => 'Delete';

  @override
  String get trips_actions_edit_tooltip => 'Edit';

  @override
  String get trips_delete_title => 'Delete this trip?';

  @override
  String get trips_delete_confirm => 'Delete';

  @override
  String get trips_delete_toast => 'Deletion confirmed (UI only).';

  @override
  String get trips_edit_toast => 'Edit coming soon.';

  @override
  String get common_cancel => 'Cancel';

  @override
  String trips_delete_message(Object tripTitle) {
    return '\"$tripTitle\" will be removed from your list. This action is irreversible.';
  }

  @override
  String get trips_delete_success => 'Trip deleted.';

  @override
  String get trips_delete_error => 'Failed to delete trip.';

  @override
  String get trips_update_success => 'Trip updated.';

  @override
  String get trips_update_error => 'Failed to update trip.';

  @override
  String get tripEditTitle => 'Edit trip';

  @override
  String get tripEditSave => 'Save';

  @override
  String get tripNoAddress => 'No address';

  @override
  String get addHotelAddress => 'Add an address';

  @override
  String get addressFormTitle => 'Set hotel address';

  @override
  String get cityLabel => 'City';

  @override
  String get cityHint => 'e.g. Dallas';

  @override
  String get addressLabel => 'Address';

  @override
  String get addressHint => 'Type at least 3 letters…';

  @override
  String get fillCityFirst => 'Enter the city first';

  @override
  String get typeAtLeast3Chars => 'Type at least 3 letters to search.';

  @override
  String get genericError => 'An error occurred.';

  @override
  String get noResults => 'No results found.';

  @override
  String get planning_select_trip_hint => 'Select a trip to start planning ✨';

  @override
  String get planning_select_trip_hintDescription => 'Banner text displayed in the planning overlay when no trip is currently open.';

  @override
  String get timeline_delete_title => 'Delete step';

  @override
  String timeline_delete_message(String stepTitle) {
    return 'Are you sure you want to delete the step \"$stepTitle\"?';
  }

  @override
  String timeline_edit_duration_title(String stepTitle) {
    return 'Edit “$stepTitle”';
  }

  @override
  String get timeline_edit_duration_subtitle => 'Adjust the activity duration. Subsequent steps will shift automatically.';

  @override
  String get common_hours_short => 'h';

  @override
  String get common_minutes_short => 'min';

  @override
  String get common_save => 'Save';

  @override
  String get timeline_edit_success => 'Duration updated, the day has been adjusted.';

  @override
  String get timeline_edit_error => 'Unable to update this activity.';
}
