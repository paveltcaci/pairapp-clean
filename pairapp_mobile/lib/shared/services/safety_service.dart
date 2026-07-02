import 'functions_service.dart';

/// Handles account safety actions through Cloud Functions.
class SafetyService {
  SafetyService({FunctionsService? functions})
    : _functions = functions ?? FunctionsService();

  final FunctionsService _functions;

  Future<void> createReport({required String reason, String? description}) {
    final trimmedDescription = description?.trim();
    return _functions.call('createReport', {
      'reason': reason,
      if (trimmedDescription != null && trimmedDescription.isNotEmpty)
        'description': trimmedDescription,
    });
  }

  Future<void> blockUser({String? reportId}) {
    final trimmedReportId = reportId?.trim();
    return _functions.call('blockUser', {
      if (trimmedReportId != null && trimmedReportId.isNotEmpty)
        'reportId': trimmedReportId,
    });
  }

  Future<void> deleteAccount({required bool confirm}) {
    return _functions.call('deleteAccount', {'confirm': confirm});
  }
}
