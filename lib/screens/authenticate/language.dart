import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import provider package for state management
import 'package:farm_expense_mangement_app/screens/authenticate/base.dart';
import 'package:farm_expense_mangement_app/main.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  String? selectedLanguage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Dairy Sangrah',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(height: 8),
                    Text(
                      'Language',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Center(child: Image.asset('asset/lang.jpeg')),
                    // Language Options
                    languageOption('ENGLISH', 'en', 'ENGLISH'),
                    languageOption('हिन्दी', 'hi', 'हिन्दी'),
                    languageOption('ਪੰਜਾਬੀ', 'pa', 'ਪੰਜਾਬੀ'),
                    languageOption('తెలుగు', 'te', 'తెలుగు'),
                  ],
                ),
              ),
            ),
          ),
          if (selectedLanguage != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 35),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF0EA6BB),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DairyMitraRegistrationPage(),
                      ),
                    );
                  },
                  child: Text(
                    'NEXT',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget languageOption(String language, String code, String displayName) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedLanguage = language;
          // Set the selected language in AppData
          Provider.of<AppData>(context, listen: false).persistentVariable =
              code;
        });
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        margin: EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color:
              selectedLanguage == language
                  ? Colors.grey.shade200
                  : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.3),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            SizedBox(width: 16),
            Text(
              displayName,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
            ),
            Spacer(),
            if (selectedLanguage == language)
              Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Color(0xFF0EA6BB),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check, size: 20, color: Colors.white),
              ),
            SizedBox(width: 16),
          ],
        ),
      ),
    );
  }
}
