import 'package:cloud_firestore/cloud_firestore.dart';

class Feed {
  String itemName;
  int quantity;
  // String Category;
  String Type;
  int? requiredQuantity;

  Feed({
    required this.itemName,
    required this.quantity,
    required this.Type,
    // required this.Category,
    this.requiredQuantity,
  });

  Map<String, dynamic> toFireStore() {
    return {
      'itemName': itemName,
      'quantity': quantity,
      'Type': Type,
      // 'Category': Category,
      'requiredQuantity': requiredQuantity,
    };
  }

  // Updated fromFireStore to require only one argument
  factory Feed.fromFireStore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final json = snapshot.data();
    return Feed(
      itemName: json?['itemName'] ?? '',
      Type: json?['Type'] ?? '',
      // Category: json?['Category']??'',
      quantity: json?['quantity'] ?? 0,
      requiredQuantity: json?['requiredQuantity'],
    );
  }
}
