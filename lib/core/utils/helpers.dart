import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Helpers {
  // Platform detection
  static bool get isAndroid => Platform.isAndroid;
  static bool get isIOS => Platform.isIOS;
  static bool get isWeb => !isAndroid && !isIOS;
  
  // Device type detection
  static bool isTablet(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final shortestSide = mediaQuery.size.shortestSide;
    return shortestSide >= 600;
  }
  
  static bool isPhone(BuildContext context) {
    return !isTablet(context);
  }
  
  // Screen size helpers
  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }
  
  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }
  
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }
  
  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }
  
  // Safe area helpers
  static double getSafeAreaTop(BuildContext context) {
    return MediaQuery.of(context).padding.top;
  }
  
  static double getSafeAreaBottom(BuildContext context) {
    return MediaQuery.of(context).padding.bottom;
  }
  
  static double getSafeAreaLeft(BuildContext context) {
    return MediaQuery.of(context).padding.left;
  }
  
  static double getSafeAreaRight(BuildContext context) {
    return MediaQuery.of(context).padding.right;
  }
  
  // Keyboard helpers
  static bool isKeyboardVisible(BuildContext context) {
    return MediaQuery.of(context).viewInsets.bottom > 0;
  }
  
  static double getKeyboardHeight(BuildContext context) {
    return MediaQuery.of(context).viewInsets.bottom;
  }
  
  // URL launcher helpers
  static Future<bool> launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri.toString());
      }
      return false;
    } catch (e) {
      return false;
    }
  }
  
  static Future<bool> launchEmail(String email, {String? subject, String? body}) async {
    try {
      final uri = Uri(
        scheme: 'mailto',
        path: email,
        query: _encodeQueryParameters({
          if (subject != null) 'subject': subject,
          if (body != null) 'body': body,
        }),
      );
      
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri.toString());
      }
      return false;
    } catch (e) {
      return false;
    }
  }
  
  static Future<bool> launchPhone(String phone) async {
    try {
      final uri = Uri(scheme: 'tel', path: phone);
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri.toString());
      }
      return false;
    } catch (e) {
      return false;
    }
  }
  
  static String? _encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }
  
  // String helpers
  static bool isNullOrEmpty(String? value) {
    return value == null || value.isEmpty;
  }
  
  static bool isNotNullOrEmpty(String? value) {
    return !isNullOrEmpty(value);
  }
  
  static String? nullIfEmpty(String? value) {
    return isNullOrEmpty(value) ? null : value;
  }
  
  static String defaultIfEmpty(String? value, String defaultValue) {
    return isNullOrEmpty(value) ? defaultValue : value!;
  }
  
  // List helpers
  static bool isListNullOrEmpty<T>(List<T>? list) {
    return list == null || list.isEmpty;
  }
  
  static bool isListNotNullOrEmpty<T>(List<T>? list) {
    return !isListNullOrEmpty(list);
  }
  
  static T? firstOrNull<T>(List<T> list) {
    return list.isNotEmpty ? list.first : null;
  }
  
  static T? lastOrNull<T>(List<T> list) {
    return list.isNotEmpty ? list.last : null;
  }
  
  // Map helpers
  static bool isMapNullOrEmpty<K, V>(Map<K, V>? map) {
    return map == null || map.isEmpty;
  }
  
  static bool isMapNotNullOrEmpty<K, V>(Map<K, V>? map) {
    return !isMapNullOrEmpty(map);
  }
  
  // DateTime helpers
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }
  
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year && 
           date.month == yesterday.month && 
           date.day == yesterday.day;
  }
  
  static bool isThisWeek(DateTime date) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return date.isAfter(startOfWeek.subtract(const Duration(days: 1))) && 
           date.isBefore(endOfWeek.add(const Duration(days: 1)));
  }
  
  static bool isThisMonth(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }
  
  static bool isThisYear(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year;
  }
  
  // Number helpers
  static bool isBetween(double value, double min, double max) {
    return value >= min && value <= max;
  }
  
  static double clamp(double value, double min, double max) {
    if (value < min) return min;
    if (value > max) return max;
    return value;
  }
  
  static int clampInt(int value, int min, int max) {
    if (value < min) return min;
    if (value > max) return max;
    return value;
  }
  
  // Color helpers
  static Color withOpacity(Color color, double opacity) {
    return color.withValues(alpha: opacity);
  }
  
  static Color lighten(Color color, double amount) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    return hslLight.toColor();
  }
  
  static Color darken(Color color, double amount) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
  
  // Validation helpers
  static bool isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(email);
  }
  
  static bool isValidPhone(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[^\d]'), '');
    return cleaned.length >= 10 && cleaned.length <= 15;
  }
  
  static bool isValidUrl(String url) {
    try {
      Uri.parse(url);
      return true;
    } catch (e) {
      return false;
    }
  }
  
  // File helpers
  static String getFileExtension(String fileName) {
    return fileName.split('.').last.toLowerCase();
  }
  
  static bool isImageFile(String fileName) {
    final extension = getFileExtension(fileName);
    return ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'].contains(extension);
  }
  
  static bool isVideoFile(String fileName) {
    final extension = getFileExtension(fileName);
    return ['mp4', 'avi', 'mov', 'wmv', 'flv', 'webm'].contains(extension);
  }
  
  // Debug helpers
  static void log(String message, {String? tag}) {
    if (kDebugMode) {
      print('${tag != null ? '[$tag] ' : ''}$message');
    }
  }
  
  static void logError(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      print('${tag != null ? '[$tag] ' : ''}ERROR: $message');
      if (error != null) print('Error: $error');
      if (stackTrace != null) print('Stack: $stackTrace');
    }
  }
  
  // Random helpers
  static String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
  
  static String generateRandomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    return String.fromCharCodes(
      Iterable.generate(length, (_) => chars.codeUnitAt(random % chars.length))
    );
  }
  
  // List manipulation helpers
  static List<T> removeDuplicates<T>(List<T> list) {
    return list.toSet().toList();
  }
  
  static List<T> removeNulls<T>(List<T?> list) {
    return list.where((item) => item != null).cast<T>().toList();
  }
  
  static List<T> shuffle<T>(List<T> list) {
    final shuffled = List<T>.from(list);
    shuffled.shuffle();
    return shuffled;
  }
  
  // Map manipulation helpers
  static Map<K, V> removeNullValues<K, V>(Map<K, V?> map) {
    return Map.fromEntries(
      map.entries.where((entry) => entry.value != null).cast<MapEntry<K, V>>()
    );
  }
  
  static Map<K, V> filter<K, V>(Map<K, V> map, bool Function(MapEntry<K, V>) test) {
    return Map.fromEntries(map.entries.where(test));
  }
}
