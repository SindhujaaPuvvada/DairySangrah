import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farm_expense_mangement_app/shared/constants.dart';
import '../../models/feed.dart';

class DatabaseServicesForFeed {
  final String uid;
  DatabaseServicesForFeed(this.uid);

  FirebaseFirestore db = FirebaseFirestore.instance;

  // Function to add or update feed information in Firestore
  Future<void> infoToServerFeed(Feed feed) async {
    DocumentSnapshot docSnapshot = await db
        .collection('User')
        .doc(uid)
        .collection('Feed')
        .doc((fdCategoryId.indexOf(feed.category) + 1).toString())
        .get();

    if (!docSnapshot.exists) {
      await docSnapshot.reference.set({'FeedCategory': feed.category});
    }

    await db
        .collection('User')
        .doc(uid)
        .collection('Feed')
        .doc((fdCategoryId.indexOf(feed.category) + 1).toString())
        .collection(feed.category)
        .doc(feed.feedId)
        .set(feed.toFireStore(), SetOptions(merge: true));
  }

  // Function to get a particular feed category from Firestore
  Future<QuerySnapshot<Map<String, dynamic>>> infoFromServerForCategory(
      String category) async {
    return await db
        .collection('User')
        .doc(uid)
        .collection('Feed')
        .doc((fdCategoryId.indexOf(category)+1).toString())
        .collection(category)
        .orderBy('feedDate', descending: true)
        .get();
  }

  // Function to delete a feed type from Firestore
  Future<void> deleteFeedFromServer(String category, String docID) async {
    await db
        .collection('User')
        .doc(uid)
        .collection('Feed')
        .doc((fdCategoryId.indexOf(category) + 1).toString())
        .collection(category)
        .doc(docID)
        .delete();
  }

  /*// Function to reduce weekly quantity of a specific feed item
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
  }*/
}
