class User {
  final String userId;
  final String userName;
  final String phoneNumber;
  final String chosenLanguage;
  String? fcmToken;
  String? subscription;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.userId,
    required this.userName,
    required this.phoneNumber,
    this.chosenLanguage = 'en',
    this.fcmToken,
    this.subscription,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromDB(Map<String, dynamic> data) {
    return User(
      userId: data['userId'],
      userName: data['userName'],
      phoneNumber: data['phoneNumber'],
      chosenLanguage: data['chosenLanguage'] ?? 'en',
      fcmToken: data['fcmToken'] ?? '',
      subscription: data['subscription'] ?? '',
      createdAt: DateTime.parse(data['createdAt']),
      updatedAt: DateTime.parse(data['updatedAt']),
    );
  }

  Map<String, dynamic> toDB() {
    return {
      'userId': userId,
      'userName': userName,
      'phoneNumber': phoneNumber,
      'chosenLanguage': chosenLanguage,
      'fcmToken': fcmToken,
      'subscription': subscription,
      'createdAt': createdAt.toIso8601String().split('.')[0],
      'updatedAt': updatedAt.toIso8601String().split('.')[0],
    };
  }
}

class DairyFarmUser {
  final String userId;
  final String farmId;
  final String userRole;
  final DateTime createdAt;
  final DateTime updatedAt;

  DairyFarmUser({
    required this.userId,
    required this.farmId,
    required this.userRole,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DairyFarmUser.fromDB(Map<String, dynamic> data) {
    return DairyFarmUser(
      userId: data['userId'].toString(),
      farmId: data['farmId'].toString(),
      userRole: data['userRole'],
      createdAt: DateTime.parse(data['createdAt']),
      updatedAt: DateTime.parse(data['updatedAt']),
    );
  }

  Map<String, dynamic> toDB() {
    return {
      'userId': userId,
      'farmId': farmId,
      'userRole': userRole,
      'createdAt': createdAt.toIso8601String().split('.')[0],
      'updatedAt': updatedAt.toIso8601String().split('.')[0],
    };
  }
}
