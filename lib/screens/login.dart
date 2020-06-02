import 'package:flutter/material.dart';
import 'package:oitaxi/services/auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final AuthService _auth = AuthService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(
        builder: (context) => Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Image.network(
                'https://images.unsplash.com/photo-1586712762548-9fa10a195532?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=967&q=80',
                fit: BoxFit.cover,
                color: Color.fromRGBO(255, 255, 255, 0.6),
                colorBlendMode: BlendMode.modulate,
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: 10.0),
                Container(
                  width: 250.0,
                  child: Align(
                    alignment: Alignment.center,
                    child: RaisedButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      color: Color(0xffffffff),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Icon(FontAwesomeIcons.google,
                              color: Color(0xffCE107C)),
                          SizedBox(width: 10.0),
                          Text(
                            'Sign in with Google',
                            style:
                                TextStyle(color: Colors.black, fontSize: 18.0),
                          ),
                        ],
                      ),
                      onPressed: () async {
                        Scaffold.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Sign in'),
                          ),
                        );
                        _auth.signInWithGoogle(context);
                      },
                    ),
                  ),
                ),
                SizedBox(height: 10.0),
                Container(
                  width: 250.0,
                  child: Align(
                    alignment: Alignment.center,
                    child: RaisedButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      color: Color(0xffffffff),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Icon(FontAwesomeIcons.facebook,
                              color: Colors.blue.shade900),
                          SizedBox(width: 10.0),
                          Text(
                            'Sign in with Facebook',
                            style:
                                TextStyle(color: Colors.black, fontSize: 18.0),
                          ),
                        ],
                      ),
                      onPressed: () {},
                    ),
                  ),
                ),
                SizedBox(height: 10.0),
                Container(
                  width: 250.0,
                  child: Align(
                    alignment: Alignment.center,
                    child: RaisedButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      color: Color(0xffffffff),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Icon(FontAwesomeIcons.solidEnvelope,
                              color: Color(0xff4caf50)),
                          SizedBox(width: 10.0),
                          Text(
                            'Sign in with Email',
                            style:
                                TextStyle(color: Colors.black, fontSize: 18.0),
                          ),
                        ],
                      ),
                      onPressed: () {},
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
