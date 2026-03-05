class AppConstants {
  AppConstants._();

  static const String appName = 'StayEase';
  static const String appTagline = 'Book your perfect stay';

  static const String hiveUserBox = 'user_box';
  static const String hiveBookingsBox = 'bookings_box';
  static const String hiveSettingsBox = 'settings_box';

  static const String userKey = 'current_user';
  static const String onboardingKey = 'onboarding_completed';

  static const Duration splashDuration = Duration(milliseconds: 1500);
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration snackBarDuration = Duration(seconds: 3);

  static const double horizontalPadding = 20.0;
  static const double verticalPadding = 16.0;
  static const double cardBorderRadius = 16.0;
  static const double buttonBorderRadius = 12.0;
  static const double inputBorderRadius = 12.0;

  static const int minPasswordLength = 6;
  static const int maxGuestsPerRoom = 6;
  static const int maxBookingDays = 30;

  static const String currencySymbol = '\$';
  static const String dateFormat = 'MMM dd, yyyy';
  static const String dateTimeFormat = 'MMM dd, yyyy • hh:mm a';
  static const String shortDateFormat = 'dd MMM';
}
