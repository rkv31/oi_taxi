import 'package:flutter/material.dart';
import 'package:oitaxi/services/auth.dart';

class MobileAuth extends StatefulWidget {
  static bool isUsed = false;
  @override
  _MobileAuthState createState() => _MobileAuthState();
}

class _MobileAuthState extends State<MobileAuth> {
  final _phoneController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Please enter your phone number for authentication',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                            borderSide: BorderSide(color: Colors.grey[200])),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                            borderSide: BorderSide(color: Colors.grey[300])),
                        filled: true,
                        fillColor: Colors.grey[100],
                        hintText: "Mobile Number"),
                  ),
                  Container(
                    width: double.infinity,
                    child: FlatButton(
                      child: Text("LOGIN"),
                      textColor: Colors.white,
                      padding: EdgeInsets.all(16),
                      onPressed: () {
                        final String phone = _phoneController.text.trim();
                        print(phone);
                        AuthService().phoneAuth(phone, context);
                      },
                      color: Colors.blue,
                    ),
                  ),
                  MobileAuth.isUsed
                      ? Text(
                    'This mobile number is already used!',
                    style: TextStyle(color: Colors.red),
                  )
                      : Container(),
                ],
              ),
            ),
          )),
    );
  }
}
