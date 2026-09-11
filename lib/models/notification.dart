class CattleNotification {
  final String ntId;
  final String farmId;
  final String ntType;
  final String ntLevel;
  final String ntRelatedTo;
  final String ntTitle;
  final String ntDetails;
  final DateTime ntShowDate;
  DateTime? ntClosedDate;
  final DateTime createdAt;

  CattleNotification({
    required this.ntId,
    required this.farmId,
    required this.ntType,
    required this.ntLevel,
    required this.ntRelatedTo,
    required this.ntTitle,
    required this.ntDetails,
    required this.ntShowDate,
    this.ntClosedDate,
    required this.createdAt,
  });

  factory CattleNotification.fromDB(Map<String, dynamic> data) {
    return CattleNotification(
      ntId: data['ntId'].toString(),
      farmId: data['farmId'].toString(),
      ntType: data['ntType'],
      ntLevel: data['ntLevel'],
      ntRelatedTo: data['ntRelatedTo'],
      ntTitle: data['ntTitle'],
      ntDetails: data['ntDetails'],
      ntShowDate: DateTime.parse(data['ntShowDate']),
      ntClosedDate: (data['ntClosedDate'] != null)
          ? DateTime.parse(data['ntClosedDate'])
          : null,
      createdAt: DateTime.parse(data['createdAt']),
    );
  }

  Map<String, dynamic> toDB() {
    return {
      'farmId': farmId,
      'ntType': ntType,
      'ntLevel': ntLevel,
      'ntRelatedTo': ntRelatedTo,
      'ntTitle': ntTitle,
      'ntDetails': ntDetails,
      'ntShowDate': ntShowDate.toIso8601String().split('.')[0],
      'ntClosedDate': (ntClosedDate != null)
          ? ntClosedDate!.toIso8601String().split('.')[0]
          : null,
      'createdAt': createdAt.toIso8601String().split('.')[0],
    };
  }
}
