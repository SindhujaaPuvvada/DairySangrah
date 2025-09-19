import 'package:farm_expense_mangement_app/screens/authenticate/forgotpasswordpage.dart';
import 'package:flutter/material.dart';
import 'package:farm_expense_mangement_app/services/auth.dart';
import 'package:farm_expense_mangement_app/shared/constants.dart';

class SignIn extends StatefulWidget {
  final Function toggleView;

  const SignIn({super.key, required this.toggleView});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final AuthService _auth = AuthService();

  // text field state
  String email = '';
  String password = '';
  final _formKey = GlobalKey<FormState>();
  String error = '';
  bool loading = false;

  void forgotPasswordPage(BuildContext context) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const ForgotPasswordPage()));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            // backgroundColor: Colors.transparent,
            body: Stack(children: [
      Positioned.fill(
        child: Image.asset(
          'asset/bgscreen.png',
          fit: BoxFit.fitHeight,
        ),
      ),
      Container(
          color: Colors.black.withValues(alpha: 0.5),
          // Set opacity level here

          child: ListView(children: [
            Container(
              padding: const EdgeInsets.only(top: 0.0),
              color: Colors.transparent,
              child: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                actions: <Widget>[
                  TextButton.icon(
                    icon: const Icon(
                      Icons.person,
                      color: Colors.black,
                    ),
                    label: const Text(
                      'Register',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    onPressed: () => widget.toggleView(),
                  ),
                ],
                // centerTitle: true,
                title: const Text(
                  ' Mobile Dairy',
                  style: TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            // centerTitle: true,
            // title: const Text(
            //   ' Mobile Dairy',
            //   style: TextStyle(
            //     fontSize: 25,
            //     fontWeight: FontWeight.bold,
            //     color: Colors.black,
            //   ),
            // ),
            const SizedBox(
              height: 30,
            ),
            Padding(
                padding: const EdgeInsets.all(50.0),
                child: Container(
                    width: 300,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.black.withValues(
                          alpha: 0.4), // Set container color with opacity
                    ),
                    child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Form(
                            key: _formKey,
                            child: Column(children: <Widget>[
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
                              TextFormField(
                                obscureText: true,
                                decoration: textInputDecoration.copyWith(
                                    hintText: 'password'),
                                onChanged: (val) {
                                  setState(() => password = val);
                                },
                              ),
                              const SizedBox(height: 20.0),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange[900],
                                ),
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    dynamic result =
                                        await _auth.signInWithEmailAndPassword(
                                            email, password);
                                    if (result == null) {
                                      setState(() {
                                        error =
                                            'Could not sign in with those credentials';
                                      });
                                    }
                                  }
                                },
                                child: const Text(
                                  'Sign In',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              TextButton(
                                  onPressed: () {
                                    // Add your 'Forgot Password' action here
                                    // For example, you can navigate to a new screen for password reset
                                    forgotPasswordPage(context);
                                  },
                                  child: const Text('Forgot Password?',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      )))
                            ])))))
          ]))
    ])));
  }
}
