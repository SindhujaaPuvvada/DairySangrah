import 'package:flutter/material.dart';
import 'package:farm_expense_mangement_app/screens/authenticate/phoneno.dart';
import '../home/localisations_en.dart';
import '../home/localisations_hindi.dart';
import '../home/localisations_punjabi.dart';
import 'package:provider/provider.dart';
import 'package:farm_expense_mangement_app/main.dart';
class DairyMitraRegistrationPage extends StatefulWidget {
  @override
  _DairyMitraRegistrationPageState createState() =>
      _DairyMitraRegistrationPageState();
}

class _DairyMitraRegistrationPageState
    extends State<DairyMitraRegistrationPage> {
  String? selectedOption;
  late Map<String, String> currentLocalization= {};
  late String languageCode = 'en';



  @override
  Widget build(BuildContext context) {
    languageCode = Provider.of<AppData>(context).persistentVariable;
    print(languageCode);

    if (languageCode == 'en') {
      currentLocalization = LocalizationEn.translations;
    } else if (languageCode == 'hi') {
      currentLocalization = LocalizationHi.translations;
    } else if (languageCode == 'pa') {
      currentLocalization = LocalizationPun.translations;
    }
    print(currentLocalization["Register a new farm"]);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22, // Adjusted font size
          ),
        ),
        centerTitle: true, // Center the title
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 20), // Spacing from the top

            // "DairyMitra Registration" text
            Text(
              'DairyMitra Registration',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 10), // Space between title and subtitle

            // Subtitle text
            Text(
              'Get started with your farm management journey',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 40), // Space before the buttons

            // "Register a New Farm" button
            GestureDetector(
              onTap: () {
                setState(() {
                  selectedOption = 'Register a New Farm';
                });
              },
              child: Container(
                width: double.infinity, // Full width
                padding: EdgeInsets.symmetric(vertical: 16.0),
                margin: EdgeInsets.only(bottom: 20), // Space between buttons
                decoration: BoxDecoration(
                  color: selectedOption == 'Register a New Farm'
                      ? Colors.grey.shade200
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12), // Curved edges
                  border: Border.all(color: Colors.grey.shade300, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3), // Slight shadow
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    SizedBox(width: 16),
                    Text(
                      currentLocalization['Register a New Farm']??"",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Spacer(),
                    if (selectedOption == 'Register a New Farm')
                      Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Color(0xFF0EA6BB), // Blue background
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check,
                          size: 20,
                          color: Colors.white, // White checkmark
                        ),
                      ),
                    SizedBox(width: 16),
                  ],
                ),
              ),
            ),

            // "Join an Existing Farm" button
            GestureDetector(
              onTap: () {
                setState(() {
                  selectedOption = 'Join an Existing Farm';
                });
              },
              child: Container(
                width: double.infinity, // Full width
                padding: EdgeInsets.symmetric(vertical: 16.0),
                decoration: BoxDecoration(
                  color: selectedOption == 'Join an Existing Farm'
                      ? Colors.grey.shade200
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12), // Curved edges
                  border: Border.all(color: Colors.grey.shade300, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3), // Slight shadow
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    SizedBox(width: 16),
                    Text(
                      'Join an Existing Farm',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Spacer(),
                    if (selectedOption == 'Join an Existing Farm')
                      Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Color(0xFF0EA6BB), // Blue background
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check,
                          size: 20,
                          color: Colors.white, // White checkmark
                        ),
                      ),
                    SizedBox(width: 16),
                  ],
                ),
              ),
            ),

            if (selectedOption != null)
              Padding(
                padding: const EdgeInsets.only(top: 40.0),
                child: SizedBox(
                  width: double.infinity, // Full width
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF0EA6BB), // Confirm button color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12), // Curved edges
                      ),
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                    ),
                    onPressed: () {
                      // Handle confirm action
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignUpPage()),
                      );
                    },
                    child: Text(
                      'Confirm',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // Text color
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}