class Query {
  final String userId;
  final String name;
  String? emailId;
  final String phoneNo;
  final String theQuery;
  final DateTime createdAt;

  Query({
    required this.userId,
    required this.name,
    required this.phoneNo,
    this.emailId,
    required this.theQuery,
    required this.createdAt,
  });

  factory Query.fromDB(Map<String, dynamic> data) {
    return Query(
      userId: data['userId'],
      name: data['name'],
      emailId: data['emailId'],
      phoneNo: data['phoneNo'],
      theQuery: data['theQuery'],
      createdAt: DateTime.parse(data['createdAt']),
    );
  }

  Map<String, dynamic> toDB() {
    return {
      'userId': userId,
      'name': name,
      'emailId': emailId,
      'phoneNo': phoneNo,
      'theQuery': theQuery,
      'createdAt': createdAt.toIso8601String().split('.')[0],
    };
  }
}
