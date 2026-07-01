import 'functions_service.dart';

/// Wraps the two Cloud Functions that mutate the couple's relationship
/// start date. Read/display is handled locally via [RelationshipBreakdown].
class RelationshipService {
  RelationshipService({FunctionsService? functions})
      : _functions = functions ?? FunctionsService();

  final FunctionsService _functions;

  /// Calls [updateRelationshipStartDate] CF.
  /// [date] must be a local calendar date; time component is ignored.
  /// Throws [FunctionsCallException] on error.
  Future<void> updateStartDate(DateTime date) async {
    // Backend expects ISO-8601 date string (date-only is fine; time is 00:00 UTC).
    final iso = '${date.year.toString().padLeft(4, '0')}'
        '-${date.month.toString().padLeft(2, '0')}'
        '-${date.day.toString().padLeft(2, '0')}';
    await _functions.call('updateRelationshipStartDate', {'date': iso});
  }

  /// Calls [confirmRelationshipStartDate] CF.
  /// Returns true if the partner's confirmation was newly recorded,
  /// false if they had already confirmed.
  Future<bool> confirmStartDate() async {
    final result = await _functions.call('confirmRelationshipStartDate');
    return result['alreadyConfirmed'] != true;
  }
}