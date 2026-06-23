import 'package:cloud_functions/cloud_functions.dart';

/// Wraps [FirebaseFunctions] and provides a single typed call method.
///
/// Errors are surfaced as [FunctionsCallException] so callers can present
/// user-friendly messages without losing the original error code.
class FunctionsService {
  FunctionsService({FirebaseFunctions? functions})
      : _functions = functions ??
            FirebaseFunctions.instanceFor(region: 'us-central1');

  final FirebaseFunctions _functions;

  /// Calls the Cloud Function named [name] with optional [data].
  ///
  /// Returns the response payload as a [Map<String, dynamic>].
  ///
  /// Throws [FunctionsCallException] for [FirebaseFunctionsException],
  /// or re-throws any other unexpected error.
  Future<Map<String, dynamic>> call(
    String name, [
    Map<String, dynamic>? data,
  ]) async {
    try {
      final callable = _functions.httpsCallable(name);
      final result = await callable.call<dynamic>(data);

      final raw = result.data;
      if (raw is Map) {
        return Map<String, dynamic>.from(raw);
      }
      // Unexpected shape – return empty map so callers stay type-safe.
      return {};
    } on FirebaseFunctionsException catch (e) {
      throw FunctionsCallException(
        code: e.code,
        message: e.message ?? 'Unknown error from $name',
        details: e.details,
        original: e,
      );
    }
  }
}

/// A typed wrapper around [FirebaseFunctionsException] that is easier to
/// handle in UI layers without importing cloud_functions directly.
class FunctionsCallException implements Exception {
  const FunctionsCallException({
    required this.code,
    required this.message,
    this.details,
    this.original,
  });

  /// Firebase error code, e.g. `'not-found'`, `'already-exists'`.
  final String code;

  /// Human-readable error message.
  final String message;

  /// Optional extra details from the function.
  final dynamic details;

  /// The original [FirebaseFunctionsException], available for logging.
  final FirebaseFunctionsException? original;

  @override
  String toString() => 'FunctionsCallException($code): $message';
}
