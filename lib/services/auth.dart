import 'package:farm_expense_mangement_app/models/user.dart' as my_app_user;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:farm_expense_mangement_app/services/database/userdatabase.dart';
import 'package:get/get.dart';

import '../logging.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  var verificationId = ''.obs;
  final log = logger(AuthService);

  // Create user object based on FirebaseUser
  my_app_user.User? _userFromFirebaseUser(User? user) {
    return user != null ? my_app_user.User(uid: user.uid) : null;
  }

  // Auth change user stream
  Stream<User?> get authStateChanges {
    return _auth.authStateChanges();
  }

  // Sign in anonymously

  // Register with email and password

  Future<my_app_user.User?> registerWithEmailAndPassword(
    String email,
    String password,
    String ownerName,
    String farmName,
    String location,
    int phoneNo,
  ) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;
      final farmUser = my_app_user.FarmUser(
        ownerName: ownerName,
        farmName: farmName,
        location: location,
        phoneNo: phoneNo,
        chosenLanguage: "en",
      );
      await DatabaseServicesForUser(user!.uid).infoToServer(user.uid, farmUser);

      return _userFromFirebaseUser(user);
    } catch (error) {
      log.e('Encountered error', time: DateTime.now(), error: error.toString());
      return null;
    }
  }

  Future<my_app_user.User?> signInWithphoneAndOTP(String phoneNo) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNo,
      verificationCompleted: (credential) async {
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: (e) {
        if (e.code == 'invalid-phone-number') {
          log.e('The phone number entered is invalid.');
          // Show an error message to the user about invalid phone number
        } else if (e.code == 'too-many-requests') {
          log.e('Too many requests. Try again later.');
          // Show an error message about too many requests
        } else if (e.code == 'quota-exceeded') {
          log.e('SMS quota exceeded. Please try again later.');
          // Show an error message about SMS quota being exceeded
        } else if (e.code == 'operation-not-allowed') {
          log.e(
            'Phone authentication is not enabled. Please enable it in Firebase.',
          );
          // Handle operation-not-allowed error
        } else if (e.code == 'network-request-failed') {
          log.e(
            'Network error occurred. Please check your internet connection.',
          );
          // Show an error message about network issues
        } else {
          log.e('Verification failed: ${e.message}');
          // Handle any other errors
        }
      },
      codeSent: (verificationId, resendToken) {
        this.verificationId.value = verificationId;
        //print("verify1");
        //print(verificationId);
        // Navigator.push(MaterialPageRoute(builder: (context) => OtpVerificationPage()));
      },
      codeAutoRetrievalTimeout: (verificationId) {
        this.verificationId.value = verificationId;
      },
    );
    return null;
  }

  Future<bool> verifyOTP(String otp) async {
    //print("verify2${verificationId.value}");
    try {
      // Use await to wait for the sign-in process to complete
      var credentials = await _auth.signInWithCredential(
        PhoneAuthProvider.credential(
          verificationId: verificationId.value,
          smsCode: otp,
        ),
      );

      // Check if the user is not null and return true if successful, otherwise false
      //print(credentials.user);
      return credentials.user != null ? true : false;
    } catch (e) {
      // Handle exceptions, like an invalid OTP
      log.e(
        "Error during OTP verification",
        time: DateTime.now(),
        error: e.toString(),
      );
      return false;
    }
  }

  Future<my_app_user.User?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;
      return _userFromFirebaseUser(user);
    } catch (error) {
      log.e(
        "Error during email authentication",
        time: DateTime.now(),
        error: error.toString(),
      );
      return null;
    }
  }

  Future<void> updatePassword(String email) async {
    // final user = FirebaseAuth.instance.currentUser;
    // final actionCodeSettings = ActionCodeSettings(
    //     url: 'https://farm-expense-management-cp.firebaseapp.com/__/auth/action?mode=action&oobCode=code',
    //     androidPackageName: 'farm-expense-management-cp.firebaseapp.com',
    //   handleCodeInApp: true
    // );
    try {
      return await _auth.sendPasswordResetEmail(email: email);
    } catch (error) {
      log.e(
        "Error during update password!",
        time: DateTime.now(),
        error: error.toString(),
      );
      return;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      return await _auth.signOut();
    } catch (error) {
      log.e(
        "Error during signout!",
        time: DateTime.now(),
        error: error.toString(),
      );
    }
  }
}
