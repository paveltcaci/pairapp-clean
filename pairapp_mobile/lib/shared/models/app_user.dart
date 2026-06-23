import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String id;
  final String? email;
  final String? displayName;
  final String? avatarUrl;
  final DateTime? birthDate;
  final String? gender;
  final String? language;
  final String? currentCoupleId;
  final bool isDeleted;
  final bool isBlocked;
  final DateTime? acceptedTermsOfUseAt;
  final DateTime? acceptedPrivacyPolicyAt;

  const AppUser({
    required this.id,
    this.email,
    this.displayName,
    this.avatarUrl,
    this.birthDate,
    this.gender,
    this.language,
    this.currentCoupleId,
    this.isDeleted = false,
    this.isBlocked = false,
    this.acceptedTermsOfUseAt,
    this.acceptedPrivacyPolicyAt,
  });

  /// True when the user has finished the profile completion step.
  bool get isProfileCompleted =>
      displayName != null &&
      displayName!.isNotEmpty &&
      acceptedTermsOfUseAt != null &&
      acceptedPrivacyPolicyAt != null;

  /// True when the user is linked to a couple.
  bool get hasCouple =>
      currentCoupleId != null && currentCoupleId!.isNotEmpty;

  factory AppUser.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return AppUser(
      id: doc.id,
      email: data['email'] as String?,
      displayName: data['displayName'] as String?,
      avatarUrl: data['avatarUrl'] as String?,
      birthDate: _tsToDateTime(data['birthDate']),
      gender: data['gender'] as String?,
      language: data['language'] as String?,
      currentCoupleId: data['currentCoupleId'] as String?,
      isDeleted: (data['isDeleted'] as bool?) ?? false,
      isBlocked: (data['isBlocked'] as bool?) ?? false,
      acceptedTermsOfUseAt:
          _tsToDateTime(data['acceptedTermsOfUseAt']),
      acceptedPrivacyPolicyAt:
          _tsToDateTime(data['acceptedPrivacyPolicyAt']),
    );
  }

  static DateTime? _tsToDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    return null;
  }
}
