import 'package:flutter/material.dart';

import '../../services/auth.dart';
import '../../shared/constants.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final AuthService _auth = AuthService();

  final _formKey = GlobalKey<FormState>();
  String email = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  Future<void> requestResetPassword() async {
    await _auth.updatePassword(email);
    success();
  }

  void success() {
    Navigator.pop(context);
    final snackBar = SnackBar(
      backgroundColor: Colors.red.shade500,
      content: const Text('Email send'),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'asset/bgscreen.png',
              fit: BoxFit.fitHeight,
            ),
          ),
          Container(
            color: Colors.black.withOpacity(0.5), // Set opacity level here

            child: ListView(
              children: [
                Container(
                  padding: const EdgeInsets.only(top: 0.0),
                  color: Colors.transparent,
                  child: AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    centerTitle: true,

                    // centerTitle: true,
                    title: const Text(
                      'Reset Password',
                      style: TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                Padding(
                  padding: const EdgeInsets.all(50.0),
                  child: Container(
                    width: 300,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.black
                          .withOpacity(0.4), // Set container color with opacity
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: <Widget>[
                            const SizedBox(height: 20.0),
                            TextFormField(
                              decoration: textInputDecoration.copyWith(
                                hintText: 'email',
                              ),
                              onChanged: (val) {
                                setState(() => email = val);
                              },
                            ),
                            const SizedBox(height: 20.0),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange[900],
                              ),
                              onPressed: () {
                                requestResetPassword();
                              },
                              child: const Text(
                                'Request Mail',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
