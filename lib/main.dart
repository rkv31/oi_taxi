import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oitaxi/screens/login.dart';
import 'package:oitaxi/services/auth.dart';
import 'package:provider/provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StreamProvider<String>.value(
      value: AuthService().user,
      child: MaterialApp(
        title: 'google fb login',
        debugShowCheckedModeBanner: false,
        home: Login(),
      ),
    );
  }
}
//
//class UserDetails {
//  final String providerDetails;
//  final String userName;
//  final String photoUrl;
//  final String userEmail;
//  final List<ProviderDetails> providerData;
//  UserDetails(this.providerDetails, this.userName, this.photoUrl,
//      this.userEmail, this.providerData);
//}
//
//class ProviderDetails {
//  final String providerDetails;
//  ProviderDetails(this.providerDetails);
//}
