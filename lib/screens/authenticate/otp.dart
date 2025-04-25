import 'package:farm_expense_mangement_app/screens/authenticate/authUtils.dart';
import 'package:farm_expense_mangement_app/screens/authenticate/registerNewFarm.dart';
import 'package:farm_expense_mangement_app/services/database/userdatabase.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:farm_expense_mangement_app/services/auth.dart';
import 'package:farm_expense_mangement_app/screens/wrappers/wrapperhome.dart';
import 'package:farm_expense_mangement_app/screens/authenticate/phoneno.dart';
import '../../logging.dart';
import '../../main.dart';
import '../home/localisations_en.dart';
import '../home/localisations_hindi.dart';
import '../home/localisations_punjabi.dart';
import 'package:provider/provider.dart';
import 'package:farm_expense_mangement_app/main.dart';
class OtpVerificationPage extends StatefulWidget {
  const OtpVerificationPage({super.key});

  @override
  _OtpVerificationPageState createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final _focusNodes = List.generate(6, (index) => FocusNode());
  final _controllers = List.generate(6, (index) => TextEditingController());
  final AuthService _auth = AuthService();
  late String languageCode = 'en';
  final log = logger(OtpVerificationPage);
  late Map<String, String> currentLocalization= {};
  // late String languageCode = 'en';



  @override
  void initState() {
    super.initState();
    // Add listeners to the controllers to handle focus changes
    for (int i = 0; i < _controllers.length; i++) {
      _controllers[i].addListener(() {
        if (_controllers[i].text.length == 1) {
          if (i < _controllers.length - 1) {
            FocusScope.of(context).requestFocus(_focusNodes[i + 1]);
          }
        }
      });
    }
  }

  @override
  void dispose() {
    for (var node in _focusNodes) {
      node.dispose();
    }
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }


 @override
  Widget build(BuildContext context) {
   languageCode = Provider.of<AppData>(context).persistentVariable;
   //print(languageCode);

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
          currentLocalization['Login To Dairy Sangrah']??"",
          style: TextStyle(
            fontWeight: FontWeight.bold, // Make the title bold
          ),
        ),
        centerTitle: true, // Ensures the title stays centered
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // "Enter OTP" text (bold)
            Text(
              currentLocalization['Enter OTP']??"",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 20), // Space between the text and OTP boxes

            // Centered Row for OTP input boxes
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center, // Center the boxes
                mainAxisSize: MainAxisSize.min, // Wrap the Row around its children
                children: List.generate(6, (index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0), // Spacing between boxes
                    child: _buildOtpBox(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      isFirst: index == 0,
                      isLast: index == 5,
                    ),
                  );
                }),
              ),
            ),

            SizedBox(height: 20), // Space between the OTP boxes and the continue button

            // Continue button (same style as sign-up button)
            SizedBox(
              width: double.infinity, // Full width
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF0EA6BB), // Continue button color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // More curve for the button
                  ),
                  padding: EdgeInsets.symmetric(vertical: 14.0), // Slightly smaller height
                ),
                onPressed: () async {
                  String otp = _controllers.map((controller) => controller.text).join();
                  //print(otp);
                  //print(SignUpPage.verify);
                  try {
                    PhoneAuthCredential credential = PhoneAuthProvider
                        .credential(
                        verificationId: SignUpPage.verify, smsCode: otp);
                    await FirebaseAuth.instance.signInWithCredential(
                        credential);


                    String uid = FirebaseAuth.instance.currentUser!.uid;
                    DatabaseServicesForUser userDb = DatabaseServicesForUser(uid);

                    final snapshot =  await userDb.infoFromServer(uid);

                    if (SignUpPage.newFarmReg && !snapshot.exists) {
                      //print("in register block");

                      Navigator.pushReplacement(
                          context, MaterialPageRoute(
                          builder: (context) => RegisterFarm()));
                    }
                    else {
                      if (snapshot.exists) {
                        //print("in wrapper block");
                        Navigator.pushReplacement(
                            context, MaterialPageRoute(
                            builder: (context) => const WrapperHomePage()));
                      }
                      else {
                        showDialog(context: context,
                            builder: (context) {
                              return AuthUtils.buildAlertDialog(
                                  title: 'No existing Farm!',
                                  content: 'There is no farm registered with this number.Please choose REGISTER to register as a new Farm or choose CANCEL to go back!',
                                  opt1: 'REGISTER',
                                  onPressedOpt1: () {
                                    Navigator.pushReplacement(
                                        context, MaterialPageRoute(
                                        builder: (context) => RegisterFarm()));
                                  },
                                  opt2: 'CANCEL',
                                  onPressedOpt2: () async {
                                    await FirebaseAuth
                                        .instance
                                        .currentUser!.delete();
                                    Navigator.pushReplacement(
                                      context, MaterialPageRoute(
                                          builder: (context) => MyApp()));
                                  }
                              );
                            });
                      }
                    }
                  }
                  catch (e) {
                    log.e("Encountered error!!", time: DateTime.now(), error: e.toString());
                  }
                },
                child: Text(
                  currentLocalization['Continue']??"",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // Text color
                  ),
                ),
              ),
            ),

            SizedBox(height: 20), // Space between the continue button and the next section

            // "Didn't receive code?" and "Resend OTP" button
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  currentLocalization["Didn't receive code?"]??"",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w300, // Light weight font
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Handle resend OTP logic here
                  },
                  child: Text(
                    currentLocalization['Resend OTP']??"",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600, // Slightly more weight
                      color: Color(0xFF0EA6BB), // Link color
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 20), // Space between the resend OTP section and the terms text

            // Terms and conditions text
            // Center(
            //   child: Text(
            //     'By signing up you agree to our Terms Conditions & Privacy Policy.',
            //     style: TextStyle(
            //       fontSize: 16,
            //       fontWeight: FontWeight.w500, // Slightly more weight than previous text
            //       color: Colors.grey[600], // Text color
            //     ),
            //     textAlign: TextAlign.center,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  // Helper method to build individual OTP input box with aesthetic improvements
  Widget _buildOtpBox({
    required TextEditingController controller,
    required FocusNode focusNode,
    required bool isFirst,
    required bool isLast,
  }) {
    return Container(
      width: 40,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8), // Slightly rounded corners
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 0,
            blurRadius: 6,
            offset: Offset(0, 4), // Shadow only on the bottom side
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1, // Restrict input to 1 character
        decoration: InputDecoration(
          border: InputBorder.none,
          counterText: '', // Hide the counter text
        ),
        onChanged: (text) {
          if (text.length == 1) {
            if (!isLast) {
              FocusScope.of(context).requestFocus(_focusNodes[_focusNodes.indexOf(focusNode) + 1]);
            }
          } else if (text.isEmpty && !isFirst) {
            FocusScope.of(context).requestFocus(_focusNodes[_focusNodes.indexOf(focusNode) - 1]);
          }
        },
      ),
    );
  }
}