import 'package:flutter/material.dart';
import 'package:oitaxi/screens/ProfileScreen.dart';
import 'package:oitaxi/screens/about.dart';
import 'package:oitaxi/screens/allTrips.dart';
import 'package:oitaxi/screens/login.dart';
import 'package:oitaxi/services/auth.dart';
import 'package:oitaxi/services/database.dart';
import 'package:oitaxi/shared/loading.dart';
import 'package:provider/provider.dart';
import 'package:oitaxi/models/customer.dart';
import 'package:oitaxi/models/driver.dart';

class SideMenu extends StatefulWidget {
  @override
  _SideMenuState createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  String email;
  @override
  Widget build(BuildContext context) {
    email = Provider.of<String>(context);
    if (DataBaseService.isDriver == false) {
      return StreamBuilder<Customer>(
          stream: DataBaseService(email: email).customerData,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              Customer userData = snapshot.data;
              return Drawer(
                child: ListView(
                  children: <Widget>[
                    UserAccountsDrawerHeader(
                      accountName: Text(userData.displayName),
                      accountEmail: Text(userData.email),
                      currentAccountPicture: CircleAvatar(
                        backgroundImage: NetworkImage(userData.photoUrl),
                        radius: 50.0,
                      ),
                    ),
                    _sharedWidgets(context),
                  ],
                ),
              );
            } else
              return Loading();
          });
    } else
      return StreamBuilder<Driver>(
          stream: DataBaseService(email: email).driverData,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              Driver userData = snapshot.data;
              return Drawer(
                child: ListView(
                  children: <Widget>[
                    UserAccountsDrawerHeader(
                      accountName: Text(userData.displayName),
                      accountEmail: Text(userData.email),
                      currentAccountPicture: CircleAvatar(
                        backgroundImage: NetworkImage(userData.photoUrl),
                        radius: 50.0,
                      ),
                    ),
                    _sharedWidgets(context),
                  ],
                ),
              );
            } else
              return Loading();
          });
  }

  Widget _sharedWidgets(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
          title: Text('Your Rides'),
          onTap: () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => AllTrips()));
          },
        ),
        ListTile(
          title: Text('Profile'),
          onTap: () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => ProfileScreen()));
          },
        ),
        ListTile(
          title: Text('Logout'),
          onTap: () async {
            await AuthService().signOutGoogle();
            Navigator.of(context).pop();
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => Login()));
          },
        ),
        ListTile(
          title: Text('About OiTaxi'),
          onTap: () {
            Navigator.of(context).pop();
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => About()));
          },
        ),
      ],
    );
  }
}
