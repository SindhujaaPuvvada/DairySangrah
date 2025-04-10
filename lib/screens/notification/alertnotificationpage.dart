
import 'package:farm_expense_mangement_app/models/notification.dart';
import 'package:farm_expense_mangement_app/screens/wrappers/wrapperhome.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../main.dart';
import '../../services/database/notificationdatabase.dart';
import '../home/localisations_en.dart';
import '../home/localisations_hindi.dart';
import '../home/localisations_punjabi.dart';


class AlertNotificationsPage extends StatefulWidget {
  const AlertNotificationsPage({super.key});

  @override
  State<AlertNotificationsPage> createState() => _AlertNotificationsPageState();
}

class _AlertNotificationsPageState extends State<AlertNotificationsPage> {

  late Map<String, String> currentLocalization= {};
  late String languageCode = 'en';

  List<Map<String, String>> notifications = [];
  late DatabaseServicesForNotification ntfDb;
  bool _isLoading = true;
  bool _showCheckboxes = false;
  bool _isSelected = false;
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
          notifications.add(
              {
                "title": ntf.ntTitle,
                "details": ntf.ntDetails,
                "id": ntf.ntId,
                "isSelected": false.toString()
              });
        }
      }
      _isLoading = false;
    });
  }

  Future<void> _deleteNotifications() async {
    for (var ntf in notifications) {
      bool sel = bool.parse(ntf['isSelected']!);
      if( sel == true) {
        await ntfDb.closeNotification(ntf['id']!);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AlertNotificationsPage()),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    ntfDb = DatabaseServicesForNotification(uid);
      setState(() {
        _getNotifications();
      });
  }


  @override
  Widget build(BuildContext context) {

    languageCode = Provider.of<AppData>(context).persistentVariable;

    if (languageCode == 'en') {
      currentLocalization = LocalizationEn.translations;
    } else if (languageCode == 'hi') {
      currentLocalization = LocalizationHi.translations;
    } else if (languageCode == 'pa') {
      currentLocalization = LocalizationPun.translations;
    }
    String localizeSentence(String sentence) {
      return sentence
          .split(' ')
          .map((word) => currentLocalization[word] ?? word)
          .join(' ');
    }
    // Helper to trim content to a fixed number of words
    String trimContent(String content, int wordCount) {
      final words = content.split(" ");
      if (words.length <= wordCount) {
        return content;
      }
      return "${words.take(wordCount).join(" ")}...";
    }

    return Scaffold(
        appBar: AppBar(
            leading: BackButton(
                onPressed: () =>
                    Navigator.push(
                        context, MaterialPageRoute(
                        builder: (context) => const WrapperHomePage())
                    )),
            title: Text(
              currentLocalization['notifications']??"",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            backgroundColor: const Color(0xFF0DA6BA),
            // Tealish Blue
            elevation: 4.0,
            actions: _showCheckboxes ? <Widget>[
              IconButton(
                  onPressed: () {
                    _deleteNotifications();
                  },
                  icon: const Icon(
                    Icons.delete,
                    color: Colors.white,
                  )
              ),
            ] : <Widget>[]
        ),
        body: _isLoading
            ? const Center(
          child: CircularProgressIndicator(),)
            : Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 16.0, vertical: 10.0),
          child: ListView.builder(
            scrollDirection: Axis.vertical,
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              _isSelected = bool.parse(notifications[index]['isSelected']!);
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
                      currentLocalization[notifications[index]['title']] ?? notifications[index]['title']!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF333333), // Dark gray
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: Text(
                        trimContent(
                            localizeSentence(notifications[index]['details']!), 5),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF757575), // Medium gray
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    onLongPress: () {
                      setState(() {
                        _showCheckboxes = true;
                      });
                    },
                    onTap: () {
                      // Show full content in a dialog box
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text(
                              currentLocalization[notifications[index]['title']] ?? notifications[index]['title']!,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            content: Text(
                              localizeSentence(notifications[index]['details']!),
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
                                child:  Text(
                          currentLocalization['Close'] ?? 'Close'
,
                          style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[_showCheckboxes ?
                        Checkbox(value: _isSelected,
                            checkColor: Colors.white,
                            activeColor: const Color(0xFF0DA6BA),
                            shape: const CircleBorder(),
                            // Tealish blue
                            onChanged: (val) {
                          setState(() {
                            _isSelected = val!;
                            notifications[index]['isSelected'] =
                                _isSelected.toString();
                          });
                        })
                            : Container(),
                        ])
                ),
              );
            },
          ),
        )
    );
  }
}
