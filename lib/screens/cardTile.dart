import 'package:flutter/material.dart';
import 'package:oitaxi/screens/tripReport.dart';

class CardTile extends StatelessWidget {
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

  CardTile(
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
    return Container(
      margin: EdgeInsets.all(5.0),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        elevation: 2,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => TripReport(
                  customerName: this.customerName,
                  driverName: this.driverName,
                  carNo: this.carNo,
                  carModel: this.carModel,
                  pickUpLocation: this.pickUpLocation,
                  dropLocation: this.dropLocation,
                  totalDistance: this.totalDistance,
                  fare: this.fare,
                  pickUpTime: this.pickUpTime,
                  dropTime: this.dropTime,
                ),
              ),
            );
          },
          child: Padding(
            padding: EdgeInsets.all(15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                        '${pickUpTime.day}-${pickUpTime.month}-${pickUpTime.year}, ${pickUpTime.hour}:${pickUpTime.minute}'),
                    SizedBox(height: 10),
                    Text('PickUp : $pickUpLocation'),
                    SizedBox(height: 10),
                    Text('Drop : $dropLocation'),
                  ],
                ),
                Center(
                  child: Text(
                    'Rs. ${this.fare.toStringAsFixed(2)}',
                    textDirection: TextDirection.ltr,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 20),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
