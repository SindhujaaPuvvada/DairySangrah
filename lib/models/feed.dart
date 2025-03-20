import 'package:cloud_firestore/cloud_firestore.dart';

class Feed {
  String category;
  String feedType;
  double quantity;
  String source;
  double totPrice;
  double ratePerKg;
  DateTime feedDate;

  Feed({
    required this.category,
    required this.feedType,
    required this.quantity,
    required this.source,
    required this.totPrice,
    required this.ratePerKg,
    required this.feedDate,
  });

  Map<String, dynamic> toFireStore() {
    return {
      'feedType': feedType,
      'quantity': quantity,
      'source': source,
      'totPrice': totPrice,
      'ratePerKg': ratePerKg,
      'feedDate': feedDate,
    };
  }

  // Updated fromFireStore to require only one argument
  factory Feed.fromFireStore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final json = snapshot.data();
    return Feed(
      category: "",
      feedType: json?['feedType'] ?? '',
      quantity: json?['quantity'] ?? 0,
      source: json?['source'] ?? '',
      totPrice: json?['totPrice'] ?? 0,
      ratePerKg: json?['ratePerKg'] ?? 0,
      feedDate: json!['feedDate'].toDate(),
    );
  }
}
