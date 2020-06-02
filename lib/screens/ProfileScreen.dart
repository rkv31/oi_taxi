import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:oitaxi/models/customer.dart';
import 'package:oitaxi/services/auth.dart';
import 'package:oitaxi/screens/login.dart';
import 'package:oitaxi/services/database.dart';
import 'package:oitaxi/shared/loading.dart';
import 'package:provider/provider.dart';
import 'package:oitaxi/screens/userMapsActivity.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _auth = AuthService();
  String email;
  @override
  Widget build(BuildContext context) {
    email = Provider.of<String>(context);
    return StreamBuilder<Customer>(
      stream: DataBaseService(email: email).customerData,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          Customer userData = snapshot.data;
          return Scaffold(
            appBar: AppBar(
              title: Text(userData.displayName),
              automaticallyImplyLeading: false,
              actions: <Widget>[
                IconButton(
                  icon: Icon(
                    FontAwesomeIcons.signOutAlt,
                    size: 20.0,
                    color: Colors.white,
                  ),
                  onPressed: () async {
                    await _auth.signOutGoogle();
                    print('signed out');
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => Login(),
                      ),
                    );
                  },
                )
              ],
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  CircleAvatar(
                    backgroundImage: NetworkImage(userData.photoUrl),
                    radius: 50.0,
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Text(
                    "Name : " + userData.displayName,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 20.0),
                  ),
                  Text(
                    "Email : " + userData.email,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 20.0),
                  ),
                  Text(
                    "UId : " + userData.uid,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 20.0),
                  ),
                  Text(
                    "Phone No. : " + userData.phoneNumber,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 20.0),
                  ),
                  FlatButton(
                    child: Text(
                      'Continue to Maps',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CustomerMapActivity()));
                    },
                    color: Colors.blue,
                  )
                ],
              ),
            ),
          );
        } else {
          return Loading();
        }
      },
    );
  }
}
