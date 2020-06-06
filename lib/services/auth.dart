import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:oitaxi/screens/driverMapsActivity.dart';
import 'package:oitaxi/screens/userMapsActivity.dart';
import 'package:oitaxi/screens/mob_auth.dart';
import 'package:oitaxi/screens/register.dart';
import 'package:oitaxi/services/database.dart';

class AuthService {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  String verificationId;

  String _userFromFirebaseUser(FirebaseUser user) {
    return user != null ? user.email : null;
  }

  // auth change user stream
  Stream<String> get user {
    return firebaseAuth.onAuthStateChanged
        //.map((FirebaseUser user) => _userFromFirebaseUser(user));
        .map(_userFromFirebaseUser);
  }

  Future signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount _googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth =
          await _googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.getCredential(
          idToken: googleAuth.idToken, accessToken: googleAuth.accessToken);
      final AuthResult authResult =
          await firebaseAuth.signInWithCredential(credential);
      final FirebaseUser user = authResult.user;
      final DataBaseService db = DataBaseService(email: user.email);
      int isprevLogin = await db.previousLogin();
      if (isprevLogin == 1) {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => CustomerMapActivity()));
        return _userFromFirebaseUser(user);
      } else if (isprevLogin == 2) {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => DriverMapActivity()));
        return _userFromFirebaseUser(user);
      }

      assert(user.email != null);
      assert(user.displayName != null);
      assert(user.photoUrl != null);
      assert(!user.isAnonymous);
      assert(await user.getIdToken() != null);

//      await db.successfulLogin();
      final FirebaseUser currentUser = await firebaseAuth.currentUser();
      assert(user.uid == currentUser.uid);
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => MobileAuth()));
      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future signOutGoogle() async {
    try {
      print('google sign out called');
      await _googleSignIn.signOut();
    } catch (error) {
      print(error.toString());
      return null;
    }
  }

  signIn(AuthCredential authCreds, BuildContext context) async {
    FirebaseUser currentUser = await firebaseAuth.currentUser();
    await currentUser.linkWithCredential(authCreds);
    if (currentUser != null) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => Register()),
          (Route<dynamic> route) => false);
    } else {
      print('Error');
    }
  }

  signInWithOTP(String smsCode, String verId, BuildContext context) {
    AuthCredential authCreds = PhoneAuthProvider.getCredential(
        verificationId: verId, smsCode: smsCode);
    signIn(authCreds, context);
  }

  Future phoneAuth(String phoneNumber, BuildContext context) async {
    final PhoneVerificationCompleted verified =
        (AuthCredential credential) async {
      //This callback will be called when verification is done automatically
      signIn(credential, context);
    };

    final PhoneVerificationFailed verificationFailed =
        (AuthException authException) {
      print(
          'onVerificationFailed, code: ${authException.code}, message: ${authException.message}');
    };

    final PhoneCodeAutoRetrievalTimeout autoTimeout = (String verId) {
      this.verificationId = verId;
    };

    final PhoneCodeSent smsSent = (String verId, [int forceResendingToken]) {
      this.verificationId = verId;
      final _codeController = TextEditingController();
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AlertDialog(
              title: Text('Provide the code sent to your mobile'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextField(
                    controller: _codeController,
                  )
                ],
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text('Confirm'),
                  textColor: Colors.white,
                  color: Colors.blue,
                  onPressed: () async {
                    final code = _codeController.text.trim();
                    signInWithOTP(code, verId, context);
                  },
                )
              ],
            );
          });
    };

    await firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: Duration(seconds: 5),
        verificationCompleted: verified,
        verificationFailed: verificationFailed,
        codeSent: smsSent,
        codeAutoRetrievalTimeout: autoTimeout);
    return null;
  }
}
