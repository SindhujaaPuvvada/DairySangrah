
import 'package:farm_expense_mangement_app/models/notification.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../services/database/notificationdatabase.dart';


class AlertNotificationsPage extends StatefulWidget {
  const AlertNotificationsPage({super.key});

  @override
  State<AlertNotificationsPage> createState() => _AlertNotificationsPageState();
}

class _AlertNotificationsPageState extends State<AlertNotificationsPage> {

  List<Map<String, String>> notifications = [];
  late DatabaseServicesForNotification ntfDb;
  bool _isLoading = true;
  final String uid = FirebaseAuth.instance.currentUser!.uid;

  Future<void> _getNotifications() async {
    final snapshot = await ntfDb.infoFromServerAllNotifications();
    setState(() {
      List<CattleNotification> ntfs = snapshot.docs.map((doc) =>
          CattleNotification.fromFireStore(doc, null)).toList();

      for (var ntf in ntfs) {
        int diff = DateTime
            .now()
            .difference(ntf.ntShowDate)
            .inDays;
        if ((!ntf.ntClosed) & (diff >= 0)) {
          notifications.add({"title": ntf.ntTitle, "details": ntf.ntDetails});
        }
      }

      _isLoading = false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    ntfDb = DatabaseServicesForNotification(uid);
      setState(() {
        _getNotifications();
        /*notifications = [
          {
            "title": "Cattle Feed Low",
            "details": "Your cattle feed stock is running low. Please restock soon."
          },
          {
            "title": "Milk Production Updated",
            "details": "Morning milk production has been updated in your records."
          },
          {
            "title": "Expense Recorded",
            "details": "A new expense for medicine purchase has been recorded."
          },
        ];*/
      });
  }


  @override
  Widget build(BuildContext context) {

    // Helper to trim content to a fixed number of words
    String _trimContent(String content, int wordCount) {
      final words = content.split(" ");
      if (words.length <= wordCount) {
        return content;
      }
      return words.take(wordCount).join(" ") + "...";
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Alert Notifications',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          backgroundColor: const Color(0xFF0DA6BA), // Tealish Blue
          elevation: 4.0,
        ),
        body: _isLoading
               ? const Center(
      child: CircularProgressIndicator(),)
        : Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 10.0),
                  child: ListView.builder(
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 10.0),
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFFFF),
                          // White background
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              spreadRadius: 2,
                              blurRadius: 6,
                              offset: const Offset(0, 4), // Shadow position
                            ),
                          ],
                          border: Border.all(
                            color: const Color(0xFFE0E0E0),
                            // Light gray border
                            width: 1,
                          ),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(
                              color: Color(0xFF0DA6BA),
                              // Tealish Blue Circle
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.notifications,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          title: Text(
                            notifications[index]['title']!,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF333333), // Dark gray
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 6.0),
                            child: Text(
                              _trimContent(
                                  notifications[index]['details']!, 5),
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF757575), // Medium gray
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          onTap: () {
                                // Show full content in a dialog box
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text(
                                        notifications[index]['title']!,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      content: Text(
                                        notifications[index]['details']!,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Color(0xFF333333),
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          style: TextButton.styleFrom(
                                            foregroundColor: const Color(
                                                0xFF0DA6BA),
                                          ),
                                          child: const Text(
                                            'Close',
                                            style: TextStyle(fontSize: 16),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                        ),
                      );
                    },
                  ),
                )
    );
  }
}
