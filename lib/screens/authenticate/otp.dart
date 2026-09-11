import 'package:farm_expense_mangement_app/screens/authenticate/showfarms.dart';
import 'package:farm_expense_mangement_app/screens/authenticate/registerNewFarm.dart';
import 'package:farm_expense_mangement_app/services/localizationService.dart';
import 'package:farm_expense_mangement_app/services/supabaseService.dart';
import 'package:flutter/material.dart';
import 'package:farm_expense_mangement_app/screens/authenticate/phoneno.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../logging.dart';
import '../../main.dart';
import 'package:provider/provider.dart';
import '../../services/database/userdatabase.dart';

class OtpVerificationPage extends StatefulWidget {
  const OtpVerificationPage({super.key});

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final _focusNodes = List.generate(6, (index) => FocusNode());
  final _controllers = List.generate(6, (index) => TextEditingController());

  //final AuthService _auth = AuthService();
  late String languageCode = 'en';
  final log = logger(OtpVerificationPage);
  late Map<String, dynamic> currentLocalization = {};

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

    currentLocalization = Localization().translations[languageCode] ?? {};
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
          currentLocalization['Login To Dairy Sangrah'] ?? "",
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
              currentLocalization['Enter OTP'] ?? "",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 20),
            // Space between the text and OTP boxes
            // Centered Row for OTP input boxes
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center, // Center the boxes
                mainAxisSize:
                    MainAxisSize.min, // Wrap the Row around its children
                children: List.generate(6, (index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                    ), // Spacing between boxes
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

            SizedBox(height: 20),
            // Space between the OTP boxes and the continue button
            // Continue button (same style as sign-up button)
            SizedBox(
              width: double.infinity, // Full width
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF0EA6BB), // Continue button color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      10,
                    ), // More curve for the button
                  ),
                  padding: EdgeInsets.symmetric(
                    vertical: 14.0,
                  ), // Slightly smaller height
                ),
                onPressed: () async {
                  String otp = _controllers
                      .map((controller) => controller.text)
                      .join();
                  //print(otp);
                  //print(SignUpPage.verify);
                  try {
                    final res = await SupabaseService.client.auth.verifyOTP(
                      phone: PhoneAuthentication.phoneNumber,
                      token: otp,
                      type: OtpType.sms,
                    );

                    if (res.session == null) {
                      log.e("Verification failed!!", time: DateTime.now());
                    } else {
                      log.i("User logged in: ${res.user?.id}");

                      String uid = SupabaseService.client.auth.currentUser!.id;
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      String phoneNo = PhoneAuthentication.phoneNumber
                          .replaceFirst("+91", "");
                      await prefs.setString('phoneNumber', phoneNo);

                      DbServicesForUser userDb = DbServicesForUser();

                      final snapshot = await userDb.infoFromServer(uid);

                      if (snapshot == null) {
                        //print("in register block");
                        if (context.mounted) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RegisterFarm(),
                            ),
                          );
                        }
                      } else {
                        if (context.mounted) {
                          Provider.of<AppData>(
                            context,
                            listen: false,
                          ).persistentVariable = snapshot['chosenLanguage'];
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ShowFarmsPage(),
                            ),
                          );
                        }
                      }

                      /*

                      if (SignUpPage.newFarmReg && !snapshot.exists) {
                        //print("in register block");
                        if (context.mounted) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RegisterFarm(),
                            ),
                          );
                        }
                      } else {
                        if (snapshot.exists) {
                          //print("in wrapper block");
                          checkForFirstLaunch().then((bool value) {
                            bool showOnboarding = value;
                            if (context.mounted) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (BuildContext context) {
                                    return showOnboarding
                                        ? OnBoardingScreens()
                                        : const WrapperHomePage();
                                  },
                                ),
                              );
                            }
                          });
                        } else {
                          if (context.mounted) {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AuthUtils.buildAlertDialog(
                                  title:
                                  currentLocalization['No existing Farm!'] ??
                                      '',
                                  content:
                                  currentLocalization['Not Registered Content'] ??
                                      '',
                                  opt1: currentLocalization['register'] ?? '',
                                  onPressedOpt1: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => RegisterFarm(),
                                      ),
                                    );
                                  },
                                  opt2: currentLocalization['cancel'] ?? '',
                                  onPressedOpt2: () async {
                                    await SupabaseService.client.auth.signOut();
                                    if (context.mounted) {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              first_screen.SignUpPage(),
                                        ),
                                      );
                                    }
                                  },
                                );
                              },
                            );
                          }
                        }
                      }*/
                    }
                  } catch (e) {
                    log.e(
                      "Encountered error!!",
                      time: DateTime.now(),
                      error: e.toString(),
                    );
                    if(e.toString().contains("otp_expired")){
                      final snackBar = SnackBar(
                        backgroundColor: Colors.redAccent,
                        content: Text(
                          currentLocalization['otp_expired'] ??
                              'OTP expired!',
                        )
                      );
                      if(context.mounted) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(snackBar);
                      }
                    }
                  }
                },
                child: Text(
                  currentLocalization['Continue'] ?? "",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // Text color
                  ),
                ),
              ),
            ),

            SizedBox(height: 20),
            // Space between the continue button and the next section
            // "Didn't receive code?" and "Resend OTP" button
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  currentLocalization["Didn't receive code?"] ?? "",
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
                    currentLocalization['Resend OTP'] ?? "",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600, // Slightly more weight
                      color: Color(0xFF0EA6BB), // Link color
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 20),
            // Space between the resend OTP section and the terms text
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
            color: Colors.grey.withValues(alpha: 0.3),
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
        maxLength: 1,
        // Restrict input to 1 character
        decoration: InputDecoration(
          border: InputBorder.none,
          counterText: '', // Hide the counter text
        ),
        onChanged: (text) {
          if (text.length == 1) {
            if (!isLast) {
              FocusScope.of(
                context,
              ).requestFocus(_focusNodes[_focusNodes.indexOf(focusNode) + 1]);
            }
          } else if (text.isEmpty && !isFirst) {
            FocusScope.of(
              context,
            ).requestFocus(_focusNodes[_focusNodes.indexOf(focusNode) - 1]);
          }
        },
      ),
    );
  }
}
