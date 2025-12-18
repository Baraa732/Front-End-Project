import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

enum ErrorType {
  network,
  server,
  authentication,
  validation,
  timeout,
  unknown
}

class AppError {
  final ErrorType type;
  final String message;
  final String? details;
  final int? statusCode;
  final dynamic originalError;

  AppError({
    required this.type,
    required this.message,
    this.details,
    this.statusCode,
    this.originalError,
  });

  @override
  String toString() => message;
}

class ErrorHandler {
  static void showError(BuildContext context, dynamic error, {String? customMessage}) {
    final appError = _parseError(error, customMessage);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_getErrorIcon(appError.type), color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    appError.message,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            if (appError.details != null) ...[
              const SizedBox(height: 4),
              Text(
                appError.details!,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ]
          ],
        ),
        backgroundColor: _getErrorColor(appError.type),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: Duration(seconds: appError.type == ErrorType.network ? 6 : 4),
        action: appError.type == ErrorType.network
            ? SnackBarAction(
                label: 'Retry',
                textColor: Colors.white,
                onPressed: () {
                  //TODO : Retry logic
                },
              )
            : null,
      ),
    );
  }

  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static void showWarning(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFFF59E0B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  static AppError _parseError(dynamic error, String? customMessage) {
    if (customMessage != null) {
      return AppError(
        type: ErrorType.unknown,
        message: customMessage,
      );
    }

    if (error is SocketException) {
      return AppError(
        type: ErrorType.network,
        message: 'No internet connection',
        details: 'Please check your network connection and try again',
        originalError: error,
      );
    }

    if (error is TimeoutException) {
      return AppError(
        type: ErrorType.timeout,
        message: 'Request timeout',
        details: 'The server is taking too long to respond',
        originalError: error,
      );
    }

    if (error is HttpException) {
      return AppError(
        type: ErrorType.server,
        message: 'Server error',
        details: 'Please try again later',
        originalError: error,
      );
    }

    if (error is FormatException) {
      return AppError(
        type: ErrorType.server,
        message: 'Invalid response format',
        details: 'The server returned an unexpected response',
        originalError: error,
      );
    }

    if (error is http.Response) {
      return _parseHttpResponse(error);
    }

    // Handle string errors
    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('timeout')) {
      return AppError(
        type: ErrorType.timeout,
        message: 'Request timeout',
        details: 'Please check your connection and try again',
        originalError: error,
      );
    }

    if (errorString.contains('connection') || errorString.contains('network')) {
      return AppError(
        type: ErrorType.network,
        message: 'Connection failed',
        details: 'Please check your internet connection',
        originalError: error,
      );
    }

    if (errorString.contains('unauthorized') || errorString.contains('401')) {
      return AppError(
        type: ErrorType.authentication,
        message: 'Authentication failed',
        details: 'Please login again',
        originalError: error,
      );
    }

    if (errorString.contains('forbidden') || errorString.contains('403')) {
      return AppError(
        type: ErrorType.authentication,
        message: 'Access denied',
        details: 'You do not have permission to perform this action',
        originalError: error,
      );
    }

    if (errorString.contains('validation') || errorString.contains('422')) {
      return AppError(
        type: ErrorType.validation,
        message: 'Validation error',
        details: 'Please check your input and try again',
        originalError: error,
      );
    }

    return AppError(
      type: ErrorType.unknown,
      message: 'An unexpected error occurred',
      details: 'Please try again later',
      originalError: error,
    );
  }

  static AppError _parseHttpResponse(http.Response response) {
    try {
      final data = json.decode(response.body);
      final message = data['message'] ?? 'Request failed';
      final errors = data['errors'];
      
      String? details;
      if (errors != null) {
        if (errors is Map) {
          details = errors.values.expand((e) => e is List ? e : [e]).join(', ');
        } else if (errors is List) {
          details = errors.join(', ');
        }
      }

      switch (response.statusCode) {
        case 400:
          return AppError(
            type: ErrorType.validation,
            message: message,
            details: details ?? 'Bad request',
            statusCode: response.statusCode,
          );
        case 401:
          return AppError(
            type: ErrorType.authentication,
            message: 'Authentication required',
            details: 'Please login to continue',
            statusCode: response.statusCode,
          );
        case 403:
          return AppError(
            type: ErrorType.authentication,
            message: 'Access forbidden',
            details: 'You do not have permission for this action',
            statusCode: response.statusCode,
          );
        case 404:
          return AppError(
            type: ErrorType.server,
            message: 'Resource not found',
            details: 'The requested resource could not be found',
            statusCode: response.statusCode,
          );
        case 422:
          return AppError(
            type: ErrorType.validation,
            message: message,
            details: details ?? 'Validation failed',
            statusCode: response.statusCode,
          );
        case 500:
        case 502:
        case 503:
        case 504:
          return AppError(
            type: ErrorType.server,
            message: 'Server error',
            details: 'Please try again later',
            statusCode: response.statusCode,
          );
        default:
          return AppError(
            type: ErrorType.server,
            message: message,
            details: details,
            statusCode: response.statusCode,
          );
      }
    } catch (e) {
      return AppError(
        type: ErrorType.server,
        message: 'Server error (${response.statusCode})',
        details: 'Unable to parse server response',
        statusCode: response.statusCode,
      );
    }
  }

  static IconData _getErrorIcon(ErrorType type) {
    switch (type) {
      case ErrorType.network:
        return Icons.wifi_off;
      case ErrorType.server:
        return Icons.error_outline;
      case ErrorType.authentication:
        return Icons.lock_outline;
      case ErrorType.validation:
        return Icons.warning_outlined;
      case ErrorType.timeout:
        return Icons.access_time;
      case ErrorType.unknown:
        return Icons.help_outline;
    }
  }

  static Color _getErrorColor(ErrorType type) {
    switch (type) {
      case ErrorType.network:
        return const Color(0xFF6B7280);
      case ErrorType.server:
        return const Color(0xFFEF4444);
      case ErrorType.authentication:
        return const Color(0xFFF59E0B);
      case ErrorType.validation:
        return const Color(0xFF8B5CF6);
      case ErrorType.timeout:
        return const Color(0xFF06B6D4);
      case ErrorType.unknown:
        return const Color(0xFF6B7280);
    }
  }

  static Map<String, dynamic> handleApiError(dynamic error, {String? operation}) {
    final appError = _parseError(error, null);
    
    return {
      'success': false,
      'message': operation != null ? '$operation failed: ${appError.message}' : appError.message,
      'error': appError.originalError?.toString() ?? error.toString(),
      'error_type': appError.type.toString(),
      'status_code': appError.statusCode,
    };
  }

  static void logError(String operation, dynamic error, [StackTrace? stackTrace]) {
    // Log errors for debugging in development
    // In production, consider using a proper logging service
  }

  // Validation helpers
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    if (!RegExp(r'^09[0-9]{8}$').hasMatch(value)) {
      return 'Please enter a valid Syrian phone number';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? validateNumber(String? value, String fieldName, {double? min, double? max}) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    
    final number = double.tryParse(value);
    if (number == null) {
      return '$fieldName must be a valid number';
    }
    
    if (min != null && number < min) {
      return '$fieldName must be at least $min';
    }
    
    if (max != null && number > max) {
      return '$fieldName must not exceed $max';
    }
    
    return null;
  }
}