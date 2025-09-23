import 'package:intl/intl.dart';

class Formatters {
  // Date formatters
  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  static final DateFormat _dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');
  static final DateFormat _timeFormat = DateFormat('HH:mm');
  static final DateFormat _monthYearFormat = DateFormat('MM/yyyy');
  static final DateFormat _yearFormat = DateFormat('yyyy');
  
  // Number formatters
  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
    decimalDigits: 2,
  );
  
  static final NumberFormat _numberFormat = NumberFormat('#,##0.00');
  static final NumberFormat _integerFormat = NumberFormat('#,##0');
  
  // Distance formatters
  static final NumberFormat _distanceFormat = NumberFormat('#,##0.0');
  
  // Time formatters
  static final NumberFormat _timeNumberFormat = NumberFormat('00');
  
  // Date formatting
  static String formatDate(DateTime date) {
    return _dateFormat.format(date);
  }
  
  static String formatDateTime(DateTime dateTime) {
    return _dateTimeFormat.format(dateTime);
  }
  
  static String formatTime(DateTime time) {
    return _timeFormat.format(time);
  }
  
  static String formatMonthYear(DateTime date) {
    return _monthYearFormat.format(date);
  }
  
  static String formatYear(DateTime date) {
    return _yearFormat.format(date);
  }
  
  // Relative time formatting
  static String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return years == 1 ? 'há 1 ano' : 'há $years anos';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return months == 1 ? 'há 1 mês' : 'há $months meses';
    } else if (difference.inDays > 7) {
      final weeks = (difference.inDays / 7).floor();
      return weeks == 1 ? 'há 1 semana' : 'há $weeks semanas';
    } else if (difference.inDays > 0) {
      return difference.inDays == 1 ? 'há 1 dia' : 'há ${difference.inDays} dias';
    } else if (difference.inHours > 0) {
      return difference.inHours == 1 ? 'há 1 hora' : 'há ${difference.inHours} horas';
    } else if (difference.inMinutes > 0) {
      return difference.inMinutes == 1 ? 'há 1 minuto' : 'há ${difference.inMinutes} minutos';
    } else {
      return 'agora mesmo';
    }
  }
  
  // Currency formatting
  static String formatCurrency(double amount) {
    return _currencyFormat.format(amount);
  }
  
  static String formatCurrencyCompact(double amount) {
    if (amount >= 1000000) {
      return 'R\$ ${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return 'R\$ ${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      return _currencyFormat.format(amount);
    }
  }
  
  // Number formatting
  static String formatNumber(double number) {
    return _numberFormat.format(number);
  }
  
  static String formatInteger(int number) {
    return _integerFormat.format(number);
  }
  
  static String formatNumberCompact(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    } else {
      return number.toString();
    }
  }
  
  // Distance formatting
  static String formatDistance(double distanceInKm) {
    if (distanceInKm < 1) {
      return '${(distanceInKm * 1000).toInt()}m';
    } else if (distanceInKm == distanceInKm.toInt()) {
      return '${distanceInKm.toInt()}km';
    } else {
      return '${_distanceFormat.format(distanceInKm)}km';
    }
  }
  
  // Time formatting (for race times)
  static String formatRaceTime(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '${_timeNumberFormat.format(hours)}:${_timeNumberFormat.format(minutes)}:${_timeNumberFormat.format(seconds)}';
    } else {
      return '${_timeNumberFormat.format(minutes)}:${_timeNumberFormat.format(seconds)}';
    }
  }
  
  // Pace formatting (min/km)
  static String formatPace(Duration pace) {
    final minutes = pace.inMinutes;
    final seconds = pace.inSeconds.remainder(60);
    return '${_timeNumberFormat.format(minutes)}:${_timeNumberFormat.format(seconds)}/km';
  }
  
  // Elevation formatting
  static String formatElevation(double elevationInMeters) {
    if (elevationInMeters >= 1000) {
      return '${(elevationInMeters / 1000).toStringAsFixed(1)}km';
    } else {
      return '${elevationInMeters.toInt()}m';
    }
  }
  
  // Temperature formatting
  static String formatTemperature(double temperature, {bool useCelsius = true}) {
    if (useCelsius) {
      return '${temperature.toInt()}°C';
    } else {
      final fahrenheit = (temperature * 9/5) + 32;
      return '${fahrenheit.toInt()}°F';
    }
  }
  
  // File size formatting
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }
  
  // Phone number formatting
  static String formatPhoneNumber(String phone) {
    // Remove all non-digit characters
    final digits = phone.replaceAll(RegExp(r'[^\d]'), '');
    
    if (digits.length == 11) {
      return '(${digits.substring(0, 2)}) ${digits.substring(2, 7)}-${digits.substring(7)}';
    } else if (digits.length == 10) {
      return '(${digits.substring(0, 2)}) ${digits.substring(2, 6)}-${digits.substring(6)}';
    } else {
      return phone; // Return original if format is not recognized
    }
  }
  
  // URL formatting
  static String formatUrl(String url) {
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      return 'https://$url';
    }
    return url;
  }
  
  // Text truncation
  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) {
      return text;
    }
    return '${text.substring(0, maxLength)}...';
  }
  
  // Capitalize first letter
  static String capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
  
  // Title case formatting
  static String toTitleCase(String text) {
    return text.split(' ').map((word) => capitalizeFirst(word)).join(' ');
  }
  
  // Clean text (remove extra spaces, normalize)
  static String cleanText(String text) {
    return text.trim().replaceAll(RegExp(r'\s+'), ' ');
  }
}
