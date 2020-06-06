import 'package:flutter/material.dart';

class TripReport extends StatelessWidget {
  final String customerName;
  final String driverName;
  final String carModel;
  final String carNo;
  final String pickUpLocation;
  final String dropLocation;
  final double totalDistance;
  final double fare;
  final DateTime pickUpTime;
  final DateTime dropTime;
  TripReport(
      {this.customerName,
      this.driverName,
      this.carNo,
      this.carModel,
      this.pickUpLocation,
      this.dropLocation,
      this.totalDistance,
      this.fare,
      this.pickUpTime,
      this.dropTime});

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text('Trip Report'),
      ),
      body: Padding(
        padding: EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text('Trip Completed', style: TextStyle(fontSize: 18)),
            SizedBox(height: 15),
            Image.asset(
              'images/correct_mark.png',
              height: screenSize.height / 5,
              width: screenSize.height / 5,
            ),
            SizedBox(height: 10),
            Text('Your fare', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Rs. ${this.fare.toStringAsFixed(2)}',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 40)),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Customer',
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: 20),
                ),
                Text(
                  this.customerName,
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
                  'Driver',
                  style: TextStyle(fontSize: 20),
                  textAlign: TextAlign.left,
                ),
                Text(
                  this.driverName,
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
                  'Car Model',
                  style: TextStyle(fontSize: 20),
                  textAlign: TextAlign.left,
                ),
                Text(
                  this.carModel,
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
                  'Car No.',
                  style: TextStyle(fontSize: 20),
                  textAlign: TextAlign.left,
                ),
                Text(
                  this.carNo,
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
                  'PickUp Location',
                  style: TextStyle(fontSize: 20),
                  textAlign: TextAlign.left,
                ),
                Text(
                  this.pickUpLocation,
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
                  'Drop Location',
                  style: TextStyle(fontSize: 20),
                  textAlign: TextAlign.left,
                ),
                Text(
                  this.dropLocation,
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
                  'Total Distance',
                  style: TextStyle(fontSize: 20),
                  textAlign: TextAlign.left,
                ),
                Text(
                  this.totalDistance.toStringAsFixed(2) + ' km',
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
                  'Time of journey',
                  style: TextStyle(fontSize: 20),
                  textAlign: TextAlign.left,
                ),
                Text(
                  dropTime.difference(pickUpTime).inMinutes.toString() +
                      ' minutes',
                  style: TextStyle(fontSize: 20),
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.left,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
