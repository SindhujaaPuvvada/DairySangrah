import 'package:farm_expense_mangement_app/models/user.dart';
import 'package:farm_expense_mangement_app/screens/wrappers/wrapperhome.dart';
import 'package:farm_expense_mangement_app/services/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:farm_expense_mangement_app/shared/constants.dart';
import 'package:email_otp/email_otp.dart';

class Register extends StatefulWidget {
  final Function toggleView;
  const Register({super.key, required this.toggleView});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();
  String error = '';
  final TextEditingController _textController = TextEditingController();

  // Text field state
  String email = '';
  String password = '';
  String ownerName = '';
  String farmName = '';
  String location = '';
  int phoneNo = 1234567;

  @override
  Widget build(BuildContext context) {
    // Color myColor=const Color(0xff39445a);
    return MaterialApp(
      home: Scaffold(
        body: Stack(
          children: <Widget>[
            // Background image
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage(
                        'asset/bgscreen.png'), // Background image path
                    fit: BoxFit.fitHeight),
              ),
            ),
            // Content container with opacity
            Container(
              color: Colors.black.withOpacity(0.5), // Set opacity level here
              child: Column(
                children: [
                  // App bar with transparent background
                  Container(
                    padding: const EdgeInsets.only(
                        top:
                            0), // Adjust top padding to account for system status bar
                    height: 110, // Set app bar height
                    color: Colors
                        .transparent, // Make app bar background transparent
                    child: AppBar(
                      backgroundColor: Colors
                          .transparent, // Make app bar background transparent
                      elevation: 0, // Remove app bar shadow
                      // centerTitle: true,
                      title: const Text(
                        ' Mobile Dairy',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 27,
                            fontWeight: FontWeight.bold),
                      ),
                      actions: <Widget>[
                        TextButton.icon(
                          icon: const Icon(Icons.person, color: Colors.black),
                          label: const Text(
                            'Sign In',
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                          onPressed: () => widget.toggleView(),
                        ),
                      ],
                    ),
                  ),
                  // Form content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 20.0, horizontal: 50.0),
                      child: Form(
                        key: _formKey,
                        child: ListView(
                          children: <Widget>[
                            const SizedBox(height: 20.0),
                            TextFormField(
                              decoration: textInputDecoration.copyWith(
                                  hintText: 'email'),
                              validator: (val) =>
                                  val!.isEmpty ? 'Enter an email' : null,
                              onChanged: (val) {
                                setState(() => email = val);
                              },
                            ),
                            const SizedBox(height: 20.0),
                            TextFormField(
                              obscureText: true,
                              decoration: textInputDecoration.copyWith(
                                  hintText: 'password'),
                              validator: (val) => val!.length < 6
                                  ? 'Enter a password 6+ chars long'
                                  : null,
                              onChanged: (val) {
                                setState(() => password = val);
                              },
                            ),
                            const SizedBox(height: 20.0),
                            TextFormField(
                              decoration: textInputDecoration.copyWith(
                                  hintText: 'Owner_name'),
                              onChanged: (val) {
                                setState(() => ownerName = val);
                              },
                            ),
                            const SizedBox(height: 20.0),
                            TextFormField(
                              decoration: textInputDecoration.copyWith(
                                  hintText: 'Farm_name'),
                              onChanged: (val) {
                                setState(() => farmName = val);
                              },
                            ),
                            const SizedBox(height: 20.0),
                            TextFormField(
                              decoration: textInputDecoration.copyWith(
                                  hintText: 'Location'),
                              onChanged: (val) {
                                setState(() => location = val);
                              },
                            ),
                            const SizedBox(height: 20.0),
                            TextFormField(
                              decoration: textInputDecoration.copyWith(
                                  hintText: 'Phone_no'),
                              keyboardType: TextInputType.number,
                              controller: _textController,
                            ),
                            const SizedBox(height: 20.0),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange[900],
                              ),
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => RegisterOtp(
                                              email: email,
                                              password: password,
                                              farmUser: FarmUser(
                                                  farmName: farmName,
                                                  ownerName: ownerName,
                                                  phoneNo: phoneNo,
                                                  location: location),
                                              toggleView: widget.toggleView)));
                                }
                              },
                              child: const Text(
                                'Register',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            const SizedBox(height: 12.0),
                            Text(
                              error,
                              style: const TextStyle(
                                  color: Colors.red, fontSize: 14.0),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RegisterOtp extends StatefulWidget {
  final Function toggleView;
  final String email;
  final String password;
  final FarmUser farmUser;
  const RegisterOtp(
      {super.key,
      required this.email,
      required this.password,
      required this.farmUser,
      required this.toggleView});

  @override
  State<RegisterOtp> createState() => _RegisterOtpState();
}

class _RegisterOtpState extends State<RegisterOtp> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  String error = '';
  final TextEditingController _textController = TextEditingController();

  String otp = '';

  dynamic emailOTP = EmailOTP();

  Future _sendOTP() async {
    if (await emailOTP.sendOTP() == true) {
      successOTP();
    } else {
      failedOTP();
    }
  }

  void successOTP() {
    final snackBar = SnackBar(
        backgroundColor: Colors.red.shade500,
        content: const Text('OTP send'),
        action: SnackBarAction(label: 'Undo', onPressed: () {}));

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void failedOTP() {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => Register(toggleView: widget.toggleView)));
    _formKey.currentState!.save();
    final snackBar = SnackBar(
        backgroundColor: Colors.red.shade500,
        content: const Text('Error in sending OTP'),
        action: SnackBarAction(label: 'Undo', onPressed: () {}));

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    emailOTP.setConfig(
        appEmail: "2021csb1136@iitrpr.ac.in",
        appName: "Dairy Management",
        userEmail: widget.email,
        otpLength: 6,
        otpType: OTPType.numeric);
    _sendOTP();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Stack(
          children: <Widget>[
            // Background image
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('asset/f3.jpeg'), // Background image path
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Content container with opacity
            Container(
              color: Colors.black.withOpacity(0.5), // Set opacity level here
              child: Column(
                children: [
                  // App bar with transparent background
                  Container(
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context)
                            .padding
                            .top), // Adjust top padding to account for system status bar
                    height: 90, // Set app bar height
                    color: Colors
                        .transparent, // Make app bar background transparent
                    child: AppBar(
                      backgroundColor: Colors
                          .transparent, // Make app bar background transparent
                      elevation: 0, // Remove app bar shadow
                      // title: Text(
                      //   'Dairy Management App',
                      //   style: TextStyle(
                      //     color: Colors.white,
                      //   ),
                      // ),
                      leading: IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          )),
                    ),
                  ),
                  // Form content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 20.0, horizontal: 50.0),
                      child: Form(
                        key: _formKey,
                        child: ListView(
                          children: <Widget>[
                            const SizedBox(height: 20.0),
                            TextFormField(
                              controller: _textController,
                              decoration:
                                  textInputDecoration.copyWith(hintText: 'OTP'),
                              validator: (val) =>
                                  val!.isEmpty ? 'Enter OTP' : null,
                              onChanged: (val) {
                                setState(() => otp = val);
                              },
                            ),
                            const SizedBox(height: 20.0),
                            const SizedBox(height: 20.0),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange[900],
                              ),
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  bool verified;
                                  verified = emailOTP.verifyOTP(otp: otp);

                                  if (verified) {
                                    try {
                                      dynamic result = await _auth
                                          .registerWithEmailAndPassword(
                                              widget.email,
                                              widget.password,
                                              widget.farmUser.ownerName,
                                              widget.farmUser.farmName,
                                              widget.farmUser.location,
                                              widget.farmUser.phoneNo);
                                      if (result == null) {
                                        setState(() {
                                          error = 'Please supply a valid email';
                                        });
                                        Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => Register(
                                                    toggleView:
                                                        widget.toggleView)));
                                      } else {
                                        Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const WrapperHomePage()));
                                      }
                                    } on FirebaseAuthException {
                                      Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => Register(
                                                  toggleView:
                                                      widget.toggleView)));
                                    }
                                  } else {
                                    final snackBar = SnackBar(
                                        backgroundColor: Colors.red.shade500,
                                        content: const Text('Wrong OTP'),
                                        action: SnackBarAction(
                                            label: 'Undo', onPressed: () {}));
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(snackBar);
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => Register(
                                                toggleView:
                                                    widget.toggleView)));
                                  }
                                } else {
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => Register(
                                              toggleView: widget.toggleView)));
                                  _formKey.currentState!.save();
                                  final snackBar = SnackBar(
                                      backgroundColor: Colors.red.shade500,
                                      content:
                                          const Text('Error in sending OTP'),
                                      action: SnackBarAction(
                                          label: 'Undo', onPressed: () {}));

                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(snackBar);
                                }
                              },
                              child: const Text(
                                'Submit',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            const SizedBox(height: 12.0),
                            Text(
                              error,
                              style: const TextStyle(
                                  color: Colors.red, fontSize: 14.0),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
