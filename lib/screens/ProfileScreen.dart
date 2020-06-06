import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oitaxi/services/database.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: FutureBuilder(
        future: getUserInfo(),
        builder: (context, userSnap) {
          if (userSnap.connectionState == ConnectionState.none ||
              userSnap.hasData == false)
            return Container(
              child: Center(
                child: Text(
                  'User details not available',
                  style: TextStyle(color: Colors.black26, fontSize: 20),
                ),
              ),
            );
          return Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                CircleAvatar(
                  backgroundImage: NetworkImage(userSnap.data['photoUrl']),
                  radius: 50.0,
                ),
                SizedBox(height: 50.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'Name',
                      style: TextStyle(fontSize: 20),
                      textAlign: TextAlign.left,
                    ),
                    Text(
                      userSnap.data['name'],
                      style: TextStyle(fontSize: 20),
                      textDirection: TextDirection.ltr,
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'Email',
                      style: TextStyle(fontSize: 20),
                      textAlign: TextAlign.left,
                    ),
                    Text(
                      userSnap.data['email'],
                      style: TextStyle(fontSize: 20),
                      textDirection: TextDirection.ltr,
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'Phone Number',
                      style: TextStyle(fontSize: 20),
                      textAlign: TextAlign.left,
                    ),
                    Text(
                      userSnap.data['phoneNumber'],
                      style: TextStyle(fontSize: 20),
                      textDirection: TextDirection.ltr,
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'Gender',
                      style: TextStyle(fontSize: 20),
                      textAlign: TextAlign.left,
                    ),
                    Text(
                      userSnap.data['gender'],
                      style: TextStyle(fontSize: 20),
                      textDirection: TextDirection.ltr,
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'Address',
                      style: TextStyle(fontSize: 20),
                      textAlign: TextAlign.left,
                    ),
                    Text(
                      userSnap.data['address'],
                      maxLines: 3,
                      softWrap: true,
                      style: TextStyle(fontSize: 20),
                      textDirection: TextDirection.ltr,
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
                (DataBaseService.isDriver)
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                'Car Model',
                                style: TextStyle(fontSize: 20),
                                textAlign: TextAlign.left,
                              ),
                              Text(
                                userSnap.data['carModel'],
                                style: TextStyle(fontSize: 20),
                                textDirection: TextDirection.ltr,
                                textAlign: TextAlign.left,
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                'Car Number',
                                style: TextStyle(fontSize: 20),
                                textAlign: TextAlign.left,
                              ),
                              Text(
                                userSnap.data['carNo'],
                                style: TextStyle(fontSize: 20),
                                textDirection: TextDirection.ltr,
                                textAlign: TextAlign.left,
                              ),
                            ],
                          ),
                        ],
                      )
                    : Container(),
              ],
            ),
          );
        },
      ),
    );
  }

  Future getUserInfo() async {
    DocumentSnapshot documentSnapshot;
    final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    final FirebaseUser currentUser = await firebaseAuth.currentUser();
    if (DataBaseService.isDriver == false)
      documentSnapshot = await Firestore.instance
          .collection('customer')
          .document(currentUser.email)
          .get();
    else
      documentSnapshot = await Firestore.instance
          .collection('driver')
          .document(currentUser.email)
          .get();
    return documentSnapshot;
  }
}
