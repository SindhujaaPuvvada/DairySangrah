import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:farm_expense_mangement_app/services/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:farm_expense_mangement_app/screens/authenticate/otp.dart';
import '../home/localisations_en.dart';
import '../home/localisations_hindi.dart';
import '../home/localisations_punjabi.dart';
import 'package:provider/provider.dart';
import 'package:farm_expense_mangement_app/main.dart';
class SignUpPage extends StatelessWidget {
  final AuthService _auth = AuthService();
  final TextEditingController _phoneController = TextEditingController();
  static String verify="";
  late Map<String, String> currentLocalization= {};

  late String languageCode = 'en';


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
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Text(
            '<', // Custom back button symbol
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w400,
              color: Colors.black, // Color of the symbol
            ),
          ),
          onPressed: () {
            Navigator.pop(context); // Handle back navigation
          },
        ),
        title: Text(
          currentLocalization['Sign Up']??"", // Centered title
          style: TextStyle(
            fontWeight: FontWeight.bold, // Make title bold
          ),
        ),
        centerTitle: true, // Ensures the title stays centered
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              // "Enter Your Phone Number" text (bold but not all caps)
              Text(
                currentLocalization['Enter Your Phone Number']??"",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 10), // Space between the text and the image

              // Image at the top
              Image.asset('asset/phone.jpeg'), // Replace with your image asset path

              SizedBox(height: 20), // Space between the image and the next text

              // Phone number input field with white background and shadow
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 0,
                      blurRadius: 5,
                      offset: Offset(0, 4), // Shadow only on the bottom
                    ),
                  ],
                ),
                child: TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    border: InputBorder.none, // No border around
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0), // Padding inside the field
                    labelText: currentLocalization['Phone Number']??"",
                    hintText: currentLocalization['Enter your phone number']??"",
                  ),
                ),
              ),

              SizedBox(height: 20), // Space between the input field and the next element

              // Full-width sign-up button with color #0EA6BB

              SizedBox(
                width: double.infinity, // Full width
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF0EA6BB), // Sign-up button color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20), // More curve for the button
                    ),
                    padding: EdgeInsets.symmetric(vertical: 14.0), // Slightly smaller height
                  ),
                  onPressed: ()  async{
                    // Add +91 to the phone number before passing it to the function
                    String phoneNumber = "+91" + _phoneController.text.trim();
                    Navigator.push(
                        context, MaterialPageRoute(
                        builder: (context) =>  OtpVerificationPage()));
                    // Handle sign-up logic here
                    await FirebaseAuth.instance.verifyPhoneNumber(phoneNumber:phoneNumber,timeout: const Duration(seconds: 60),verificationCompleted: (PhoneAuthCredential credential) { }, verificationFailed: (FirebaseAuthException e) {}, codeSent: (String verificationId, int? resendtoken){
                      SignUpPage.verify=verificationId;
                      print(verificationId);
                    }, codeAutoRetrievalTimeout: (String verificationId){

                    });
                  },
                  child: Text(
                    currentLocalization['Sign Up']??"",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // Text color
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
