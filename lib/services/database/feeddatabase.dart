import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/feed.dart';

class DatabaseServicesForFeed {
  final String uid;
  DatabaseServicesForFeed(this.uid);

  FirebaseFirestore db = FirebaseFirestore.instance;

  // Function to add or update feed information in Firestore
  Future<void> infoToServerFeed(Feed feed) async {
    await db
        .collection('User')
        .doc(uid)
        .collection('Feed')
        .doc(feed.Type)
    .collection(feed.itemName)
         .doc(feed.itemName)

        .set(feed.toFireStore(), SetOptions(merge: true));
    print('Feed item added or updated: ${feed.itemName}');
  }

  // Function to get a single feed item from Firestore
  Future<DocumentSnapshot<Map<String, dynamic>>> infoFromServer(
      String itemName) async {
    return await db
        .collection('User')
        .doc(uid)
        .collection('Feed')
        .doc(itemName)
        .get();
  }

  // Function to get all feed items for the user
  Future<QuerySnapshot<Map<String, dynamic>>> infoFromServerAllFeed() async {
    return await db
        .collection('User')
        .doc(uid)
        .collection('Feed')
        .orderBy('itemName')
        .get();
  }

  // Function to delete a feed item from Firestore
  Future<void> deleteFeed(String itemName) async {
    await db
        .collection('User')
        .doc(uid)
        .collection('Feed')
        .doc(itemName)
        .delete();
    print('Feed item deleted: $itemName');
  }

  // Function to reduce weekly quantity of a specific feed item
  Future<void> reduceWeeklyQuantity(String itemName) async {
    final feedRef = db.collection('User').doc(uid).collection('Feed').doc(itemName);

    final doc = await feedRef.get();
    if (doc.exists) {
      final feedData = Feed.fromFireStore(doc);
      if (feedData.requiredQuantity != null && feedData.quantity >= feedData.requiredQuantity!) {
        // Calculate the new quantity
        final newQuantity = feedData.quantity - feedData.requiredQuantity!;

        // Update Firestore with the reduced quantity
        await feedRef.update({
          'quantity': newQuantity,
        });

        print('Weekly quantity deducted for $itemName. New quantity: $newQuantity');
      } else {
        print('Insufficient quantity for weekly deduction or no required quantity set.');
      }
    } else {
      print('Feed item not found for weekly deduction.');
    }
  }

  // Function to start the weekly deduction for all feed items
  Future<void> startWeeklyDeductionForAllFeeds() async {
    final querySnapshot = await infoFromServerAllFeed();

    // Iterate through all feed items and apply the weekly deduction
    for (var doc in querySnapshot.docs) {
      final itemName = doc.get('itemName');
      await reduceWeeklyQuantity(itemName);
    }
  }
}
