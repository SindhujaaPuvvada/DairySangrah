import 'package:farm_expense_mangement_app/models/notification.dart';
import 'package:farm_expense_mangement_app/screens/wrappers/wrapperhome.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../main.dart';
import '../../services/database/notificationdatabase.dart';
import 'package:farm_expense_mangement_app/services/localizationService.dart';

class NotificationAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const NotificationAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> currentLocalization = {};
    String languageCode = 'en';

    languageCode = Provider.of<AppData>(context).persistentVariable;

    currentLocalization = Localization().translations[languageCode]??{};

    return AppBar(
      leading: BackButton(
        color: Colors.white,
        onPressed:
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const WrapperHomePage()),
            ),
      ),
      centerTitle: true,
      title: Text(
        currentLocalization['notifications'] ?? "",
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      backgroundColor: const Color(0xFF0DA6BA),
      // Tealish Blue
      elevation: 4.0,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class AlertNotificationsPage extends StatefulWidget {
  const AlertNotificationsPage({super.key});

  @override
  State<AlertNotificationsPage> createState() => _AlertNotificationsPageState();
}

class _AlertNotificationsPageState extends State<AlertNotificationsPage> {
  late Map<String, dynamic> currentLocalization = {};
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
      List<CattleNotification> ntfs =
          snapshot.docs
              .map((doc) => CattleNotification.fromFireStore(doc, null))
              .toList();

      for (var ntf in ntfs) {
        int diff = DateTime.now().difference(ntf.ntShowDate).inDays;
        if ((!ntf.ntClosed) & (diff >= 0)) {
          notifications.add({
            "title": ntf.ntTitle,
            "details": ntf.ntDetails,
            "id": ntf.ntId,
            "isSelected": false.toString(),
          });
        }
      }
      _isLoading = false;
    });
  }

  Future<void> _deleteNotifications() async {
    var futures = <Future<void>>[];
    List<dynamic> deletedNtfs = [];
    for (var ntf in notifications) {
      bool sel = bool.parse(ntf['isSelected']!);
      if (sel == true) {
        futures.add(ntfDb.closeNotification(ntf['id']!));
        deletedNtfs.add(ntf);
      }
    }
    for (var dNtf in deletedNtfs) {
      notifications.remove(dNtf);
    }
    await Future.wait(futures);
    if (mounted) {
      setState(() {
        _showCheckboxes = false;
      });
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

    currentLocalization = Localization().translations[languageCode]??{};

    String localizeSentence(String sentence) {
      List<String> parts = sentence.split(' ');
      if (parts.isEmpty) return sentence;

      String firstWord = parts[0];
      String rest = sentence.substring(firstWord.length).trim();

      int isIndex = rest.indexOf('is ');
      int dashIndex = rest.indexOf('-');

      String localizedFirst = currentLocalization[firstWord] ?? firstWord;
      String middle = "";
      String remaining = "";

      if (dashIndex != -1 && (isIndex == -1 || dashIndex < isIndex)) {
        middle = rest.substring(0, dashIndex + 1).trim();
        remaining = rest.substring(dashIndex + 1).trim();
      } else if (isIndex != -1) {
        middle = rest.substring(0, isIndex).trim();
        remaining = rest.substring(isIndex).trim();
      } else {
        middle = rest;
      }

      String localizedRemaining = currentLocalization[remaining] ?? remaining;

      return '$localizedFirst ${middle.isNotEmpty ? '$middle ' : ''}$localizedRemaining';
    }

    if (_isLoading) {
      return Container(
        color: Colors.white,
        child: Center(child: CircularProgressIndicator()),
      );
    } else {
      return Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 10.0,
            ),
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
                        color: Colors.grey.withValues(alpha: 0.3),
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
                      currentLocalization[notifications[index]['title']] ??
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
                        localizeSentence(notifications[index]['details']!),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF333333),
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
                              currentLocalization[notifications[index]['title']] ??
                                  notifications[index]['title']!,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            content: Text(
                              localizeSentence(
                                notifications[index]['details']!,
                              ),
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
                                  foregroundColor: const Color(0xFF0DA6BA),
                                ),
                                child: Text(
                                  currentLocalization['Close'] ?? 'Close',
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
                      children: <Widget>[
                        _showCheckboxes
                            ? Checkbox(
                              value: _isSelected,
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
                              },
                            )
                            : Container(),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          _showCheckboxes
              ? Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).padding.bottom + 10,
                  ),
                  child: FloatingActionButton(
                    onPressed: () {
                      _deleteNotifications();
                    },
                    backgroundColor: Colors.white,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                          child: Icon(
                            Icons.delete,
                            color: Color.fromRGBO(13, 166, 186, 1.0),
                          ),
                        ),
                        Text(
                          currentLocalization['delete'] ?? 'Delete',
                          style: TextStyle(color: Colors.black, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              )
              : Container(),
        ],
      );
    }
  }
}
