import 'package:supabase_flutter/supabase_flutter.dart';

class ErrorHandler {
  static String parse(Object e) {
    if (e is AuthException) return _fromAuth(e);
    if (e is PostgrestException) return _fromPostgrest(e);
    if (e is StorageException) return _fromStorage(e);

    final msg = e.toString().toLowerCase();
    if (msg.contains('socketexception') ||
        msg.contains('connection refused') ||
        msg.contains('network is unreachable') ||
        msg.contains('failed host lookup')) {
      return 'No internet connection. Please check your network.';
    }
    if (msg.contains('timeout')) {
      return 'Request timed out. Please try again.';
    }

    return 'Something went wrong. Please try again.';
  }

  static String _fromAuth(AuthException e) {
    switch (e.message.toLowerCase()) {
      case 'invalid login credentials':
        return 'Incorrect email or password.';
      case 'email not confirmed':
        return 'Please confirm your email before signing in.';
      case 'user already registered':
        return 'An account with this email already exists.';
      case 'password should be at least 6 characters':
        return 'Password must be at least 6 characters.';
      case 'email rate limit exceeded':
        return 'Too many attempts. Please wait a moment and try again.';
      case 'user not found':
        return 'No account found with this email.';
      case 'signup disabled':
        return 'New registrations are currently disabled.';
      case 'over_email_send_rate_limit':
      case 'for security purposes, you can only request this once every 60 seconds':
        return 'Please wait 60 seconds before requesting another email.';
      default:
        return e.message.isNotEmpty ? e.message : 'Authentication failed. Please try again.';
    }
  }

  static String _fromPostgrest(PostgrestException e) {
    switch (e.code) {
      case '23505':
        return 'This record already exists.';
      case '23503':
        return 'Related record not found.';
      case '42501':
        return 'You don\'t have permission to do this.';
      case 'PGRST116':
        return 'Record not found.';
      default:
        // ignore: avoid_print
        print('[DB ERROR] code=${e.code} message=${e.message} details=${e.details} hint=${e.hint}');
        return 'Database error. Please try again.';
    }
  }

  static String _fromStorage(StorageException e) {
    return 'File upload failed. Please try again.';
  }
}
