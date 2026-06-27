/// Local breakdown of "time together" computed from [relationshipStartDate].
/// All calculations are done in Dart to avoid a CF round-trip on every
/// Home screen render.
class RelationshipBreakdown {
  final int totalDays;
  final int years;
  final int months;
  final int days;
  final DateTime nextAnniversaryDate;
  final int daysUntilAnniversary;

  const RelationshipBreakdown({
    required this.totalDays,
    required this.years,
    required this.months,
    required this.days,
    required this.nextAnniversaryDate,
    required this.daysUntilAnniversary,
  });

  /// Computes breakdown from [startDate] relative to today.
  ///
  /// Day 0 semantics: if start == today → totalDays = 0, we show "1-й день"
  /// in the UI so users never see "0 дней" on the day they set the date.
  factory RelationshipBreakdown.compute(DateTime startDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = DateTime(startDate.year, startDate.month, startDate.day);

    // Total calendar days elapsed (0 on day of setting).
    final totalDays = today.difference(start).inDays;

    // Calendar breakdown: years / months / remaining days
    // Uses date arithmetic so leap years and variable month lengths are
    // handled correctly (same algorithm as backend relationshipCounter.ts).
    int y = today.year - start.year;
    int m = today.month - start.month;
    int d = today.day - start.day;

    if (d < 0) {
      m -= 1;
      // Days in previous month relative to today.
      final prevMonth = DateTime(today.year, today.month, 0);
      d += prevMonth.day;
    }
    if (m < 0) {
      y -= 1;
      m += 12;
    }

    // Next anniversary: same month/day, current or next year.
    DateTime next =
    DateTime(today.year, start.month, start.day);
    if (!next.isAfter(today)) {
      next = DateTime(today.year + 1, start.month, start.day);
    }
    final daysUntil = next.difference(today).inDays;

    return RelationshipBreakdown(
      totalDays: totalDays,
      years: y,
      months: m,
      days: d,
      nextAnniversaryDate: next,
      daysUntilAnniversary: daysUntil,
    );
  }

  /// Human-readable duration: "X лет Y мес Z дней" or "X дней" if < 1 month.
  String get durationLabel {
    if (totalDays == 0) return '1-й день 🎉';

    final parts = <String>[];
    if (years > 0) parts.add(_plural(years, 'год', 'года', 'лет'));
    if (months > 0) parts.add(_plural(months, 'месяц', 'месяца', 'месяцев'));
    if (years == 0) {
      // Show days only when less than a year (cleaner for large numbers).
      if (months == 0 || days > 0) {
        parts.add(_plural(days == 0 && months == 0 ? totalDays : days,
            'день', 'дня', 'дней'));
      }
    }
    return parts.join(' ');
  }

  static String _plural(int n, String one, String few, String many) {
    final mod10 = n % 10;
    final mod100 = n % 100;
    if (mod10 == 1 && mod100 != 11) return '$n $one';
    if (mod10 >= 2 && mod10 <= 4 && (mod100 < 10 || mod100 >= 20)) {
      return '$n $few';
    }
    return '$n $many';
  }
}