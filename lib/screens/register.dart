import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oitaxi/screens/driverMapsActivity.dart';
import 'package:oitaxi/screens/userMapsActivity.dart';
import 'package:oitaxi/services/database.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final formKey = GlobalKey<FormState>();
  String _address1, _address2, _finalAddress, _carNo, _carModel, _gender;
  bool isDriver = false;

  setUserType(bool val) {
    setState(() {
      isDriver = val;
    });
  }

  setGender(String val) {
    setState(() {
      _gender = val;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Register"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6.0),
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            Card(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      TextFormField(
                        decoration: InputDecoration(
                            labelText: 'Address line 1',
                            prefixIcon: Icon(Icons.home)),
                        validator: (input) =>
                            input.isEmpty ? 'Please provide address' : null,
                        onSaved: (input) => _address1 = input,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                            labelText: 'Address line 2',
                            prefixIcon: Icon(Icons.home)),
                        onSaved: (input) => _address2 = input,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        "Select your Gender:",
                        style: TextStyle(
                          color: Colors.black54,
                        ),
                      ),
                      RadioListTile(
                        value: 'Male',
                        groupValue: _gender,
                        title: Text('Male'),
                        onChanged: (value) {
                          print('Radio tile pressed $value');
                          setGender(value);
                        },
                      ),
                      RadioListTile(
                        value: 'Female',
                        groupValue: _gender,
                        title: Text('Female'),
                        onChanged: (value) {
                          print('Radio tile pressed $value');
                          setGender(value);
                        },
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Select your Category:",
                        style: TextStyle(
                          color: Colors.black54,
                        ),
                      ),
                      RadioListTile(
                        value: false,
                        groupValue: isDriver,
                        title: Text('Customer'),
                        onChanged: (value) {
                          print('Radio tile pressed $value');
                          setUserType(value);
                        },
                      ),
                      RadioListTile(
                        value: true,
                        groupValue: isDriver,
                        title: Text('Driver'),
                        onChanged: (value) {
                          print('Radio tile pressed $value');
                          setUserType(value);
                        },
                      ),
                      driverInfoWidget(),
                      RaisedButton(
                        onPressed: _submit,
                        child: Text('Submit'),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() async {
    if (formKey.currentState.validate()) {
      formKey.currentState.save();
      if (!_address2.isEmpty)
        _finalAddress = _address1 + ', ' + _address2;
      else
        _finalAddress = _address1;
//      print(_finalAddress);
//      print(_carNo);
//      print(_carModel);
      final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
      FirebaseUser currentUser = await firebaseAuth.currentUser();
      final DataBaseService db = DataBaseService(email: currentUser.email);
      if (isDriver == false) {
        await db.updateCustomerData(
            currentUser.displayName,
            currentUser.email,
            currentUser.photoUrl,
            currentUser.phoneNumber,
            currentUser.uid,
            _finalAddress,
            _gender);
        DataBaseService.isDriver = false;
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => CustomerMapActivity()));
      } else {
        await db.updateDriverData(
            currentUser.displayName,
            currentUser.email,
            currentUser.photoUrl,
            currentUser.phoneNumber,
            currentUser.uid,
            _finalAddress,
            _carModel,
            _carNo,
            _gender);
        DataBaseService.isDriver = true;
        Firestore _firestore = Firestore.instance;
        _firestore
            .collection('driverCustomerCommon')
            .document(currentUser.email)
            .setData({'driverEmail': currentUser.email});
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => DriverMapActivity()));
      }
    }
  }

  Widget driverInfoWidget() {
    if (isDriver == true)
      return Column(
        children: <Widget>[
          TextFormField(
            decoration: InputDecoration(
                labelText: 'Car Model', prefixIcon: Icon(Icons.drive_eta)),
            validator: (input) =>
                input.isEmpty ? 'Please provide Car Model' : null,
            onSaved: (input) => _carModel = input,
          ),
          TextFormField(
            decoration: InputDecoration(
                labelText: 'Car Number', prefixIcon: Icon(Icons.payment)),
            validator: (input) =>
                input.isEmpty ? 'Please provide Car Number' : null,
            onSaved: (input) => _carNo = input,
          ),
          SizedBox(height: 10)
        ],
      );
    else
      return Container();
  }
}
