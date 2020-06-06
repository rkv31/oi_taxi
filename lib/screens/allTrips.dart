import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:oitaxi/screens/cardTile.dart';
import 'package:oitaxi/services/database.dart';

class AllTrips extends StatefulWidget {
  @override
  _AllTripsState createState() => _AllTripsState();
}

class _AllTripsState extends State<AllTrips> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Rides'),
      ),
      body: FutureBuilder(
        builder: (context, ridesSnap) {
          if (ridesSnap.connectionState == ConnectionState.none ||
              ridesSnap.hasData == false)
            return Container(
              child: Center(
                child: Text(
                  'No ride details available',
                  style: TextStyle(color: Colors.black26, fontSize: 20),
                ),
              ),
            );
          return ListView.builder(
            scrollDirection: Axis.vertical,
            itemCount: ridesSnap.data.documents.length,
            itemBuilder: (context, index) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Widget to display the list of project
                  CardTile(
                    customerName:
                        ridesSnap.data.documents[index].data['customerName'],
                    driverName:
                        ridesSnap.data.documents[index].data['driverName'],
                    carModel: ridesSnap.data.documents[index].data['carModel'],
                    carNo: ridesSnap.data.documents[index].data['carNo'],
                    pickUpLocation:
                        ridesSnap.data.documents[index].data['pickUpLocation'],
                    dropLocation:
                        ridesSnap.data.documents[index].data['dropLocation'],
                    totalDistance:
                        ridesSnap.data.documents[index].data['distance'],
                    fare: ridesSnap.data.documents[index].data['fare'],
                    pickUpTime: ridesSnap
                        .data.documents[index].data['pickUpTime']
                        .toDate(),
                    dropTime: ridesSnap.data.documents[index].data['dropTime']
                        .toDate(),
                  ),
                ],
              );
            },
          );
        },
        future: getRideData(),
      ),
    );
  }

  Future getRideData() async {
    final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    final FirebaseUser currentUser = await firebaseAuth.currentUser();
    QuerySnapshot querySnapshot;
    if (DataBaseService.isDriver == false) {
      querySnapshot = await Firestore.instance
          .collection('rides')
          .orderBy('pickUpTime', descending: true)
          .where('customerEmail', isEqualTo: currentUser.email)
          .getDocuments();
    } else {
      querySnapshot = await Firestore.instance
          .collection('rides')
          .orderBy('pickUpTime', descending: true)
          .where('driverEmail', isEqualTo: currentUser.email)
          .getDocuments();
    }
    return querySnapshot;
  }
}
