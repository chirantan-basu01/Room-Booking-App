class Validators {
  Validators._();

  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!_emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? validateDateRange(DateTime? checkIn, DateTime? checkOut) {
    if (checkIn == null) {
      return 'Please select check-in date';
    }
    if (checkOut == null) {
      return 'Please select check-out date';
    }
    if (checkOut.isBefore(checkIn) || checkOut.isAtSameMomentAs(checkIn)) {
      return 'Check-out must be after check-in';
    }
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    if (checkIn.isBefore(todayOnly)) {
      return 'Check-in cannot be in the past';
    }
    return null;
  }

  static String? validateCheckInDate(DateTime? date) {
    if (date == null) {
      return 'Please select check-in date';
    }
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    if (date.isBefore(todayOnly)) {
      return 'Check-in cannot be in the past';
    }
    return null;
  }

  static String? validateCheckOutDate(DateTime? checkIn, DateTime? checkOut) {
    if (checkOut == null) {
      return 'Please select check-out date';
    }
    if (checkIn != null && !checkOut.isAfter(checkIn)) {
      return 'Check-out must be after check-in';
    }
    return null;
  }
}
