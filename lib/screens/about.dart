import 'package:flutter/material.dart';

class About extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            height: 100,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              CircleAvatar(
                backgroundImage: AssetImage('images/flutter_logo.png'),
                radius: 50.0,
              ),
              CircleAvatar(
                backgroundImage: AssetImage('images/firebase_logo.png'),
                radius: 50.0,
              ),
            ],
          ),
          SizedBox(
            height: 60,
          ),
          Text('Made with love by-', style: TextStyle(fontSize: 20)),
          SizedBox(
            height: 20,
          ),
          Text('Rajat Kumar Vimal', style: TextStyle(fontSize: 30)),
          SizedBox(
            height: 10,
          ),
          Text('Bhawani Prasad', style: TextStyle(fontSize: 30)),
          SizedBox(
            height: 10,
          ),
          Text('Shreyansh Utkarsh', style: TextStyle(fontSize: 30)),
          SizedBox(
            height: 10,
          ),
          Text('Rishabh Mahanta', style: TextStyle(fontSize: 30)),
          SizedBox(
            height: 10,
          ),
          Text('Adrit Sharma', style: TextStyle(fontSize: 30)),
        ],
      ),
    );
  }
}
