import 'package:flutter/material.dart';
import 'dart:async';
import 'package:farm_expense_mangement_app/screens/home/homepage.dart';
import 'package:farm_expense_mangement_app/screens/home/profilepage.dart';
import 'package:provider/provider.dart';
import '../../main.dart';

class WrapperHomePage extends StatefulWidget {
  const WrapperHomePage({super.key});

  @override
  State<WrapperHomePage> createState() => _WrapperHomePageState();
}

class LanguagePopup {
  static void showLanguageOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Language'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLanguageOption(context, 'English', 'en'),
              _buildLanguageOption(context, 'Hindi', 'hi'),
              _buildLanguageOption(context, 'Punjabi', 'pa'),
            ],
          ),
        );
      },
    );
  }

  static Widget _buildLanguageOption(
      BuildContext context, String language, String languageCode) {
    return InkWell(
      onTap: () {
        Provider.of<AppData>(context, listen: false).persistentVariable = languageCode;
        Navigator.pop(context);
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          language,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}

class _WrapperHomePageState extends State<WrapperHomePage> {
  late StreamController<int> _streamControllerScreen;
  final int _screenFromNumber = 0;
  int _selectedIndex = 0;

  late PreferredSizeWidget _appBar;
  late Widget _bodyScreen;

  @override
  void dispose() {
    _streamControllerScreen.close();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _streamControllerScreen = StreamController<int>.broadcast();
    _streamControllerScreen.add(_screenFromNumber);
    _appBar = const HomeAppBar();
    _bodyScreen = const HomePage();
  }

  void _updateIndex(int index) {
    setState(() {
      _selectedIndex = index;
      if (_selectedIndex == 0) {
        _appBar = const HomeAppBar();
        _bodyScreen = const HomePage();
      } else if (_selectedIndex == 1) {
        _appBar = const ProfileAppBar();
        _bodyScreen = const ProfilePage();
      } else if (_selectedIndex == 2) {
        LanguagePopup.showLanguageOptions(context);
      } else if (_selectedIndex == 3) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AlertNotificationsPage()),
        );
      }
    });
  }

  void home(BuildContext context) {
    setState(() {
      _updateIndex(0);
    });
  }

  void profile(BuildContext context) {
    setState(() {
      _updateIndex(1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      appBar: _appBar,
      body: _bodyScreen,
      bottomNavigationBar: ClipRRect(
        clipBehavior: Clip.hardEdge,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(36),
          topRight: Radius.circular(36),
        ),
        child: BottomAppBar(
          shadowColor: Colors.white70,
          color: Colors.white,
          surfaceTintColor: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FloatingActionButton(
                onPressed: () {
                  profile(context);
                },
                backgroundColor: Colors.white,
                elevation: 0,
                child: Icon(
                  Icons.person,
                  size: 36,
                  color: _selectedIndex == 1 ? Colors.black : Colors.grey,
                ),
              ),
              FloatingActionButton(
                onPressed: () {
                  home(context);
                },
                backgroundColor: Colors.white,
                elevation: 0,
                child: Icon(
                  Icons.home,
                  size: 36,
                  color: _selectedIndex == 0 ? Colors.black : Colors.grey,
                ),
              ),
              FloatingActionButton(
                onPressed: () {
                  LanguagePopup.showLanguageOptions(context);
                },
                backgroundColor: Colors.white,
                elevation: 0,
                child: Icon(
                  Icons.language,
                  size: 36,
                  color: _selectedIndex == 2 ? Colors.black : Colors.grey,
                ),
              ),
              FloatingActionButton(
                onPressed: () {
                  _updateIndex(3);
                },
                backgroundColor: Colors.white,
                elevation: 0,
                child: Icon(
                  Icons.notifications,
                  size: 36,
                  color: _selectedIndex == 3 ? Colors.black : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';

class AlertNotificationsPage extends StatelessWidget {
  const AlertNotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy notifications list
    final List<Map<String, String>> notifications = [
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
    ];

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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        child: ListView.builder(
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 10.0),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFFFF), // White background
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
                  color: const Color(0xFFE0E0E0), // Light gray border
                  width: 1,
                ),
              ),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0DA6BA), // Tealish Blue Circle
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
                    _trimContent(notifications[index]['details']!, 5),
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
                              foregroundColor: const Color(0xFF0DA6BA),
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
      ),
    );
  }
}