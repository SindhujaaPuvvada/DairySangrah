class CattleEvent {
  String eventId;
  final String cattleId;
  final String eventName;
  final DateTime eventDate;
  String? notes;
  final DateTime createdAt;

  CattleEvent({
    required this.eventId,
    required this.cattleId,
    required this.eventName,
    required this.eventDate,
    this.notes,
    required this.createdAt,
  });

  factory CattleEvent.fromDB(Map<String, dynamic> data) {
    final eventId = data['eventId'].toString();
    final cattleId = data['cattleId'].toString();
    final name = data['eventName'];
    final date = DateTime.parse(data['eventDate']);
    final notes = data['notes'];
    final createdAt = DateTime.parse(data['createdAt']);
    return CattleEvent(
      eventId: eventId,
      cattleId: cattleId,
      eventName: name,
      eventDate: date,
      notes: notes,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toDB() {
    return {
      'cattleId': cattleId,
      'eventName': eventName,
      'eventDate': eventDate.toIso8601String().split('.')[0],
      'notes': notes,
      'createdAt': createdAt.toIso8601String().split('.')[0],
    };
  }
}
