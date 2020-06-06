import 'dart:async';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math' show cos, sqrt, asin;

import 'package:oitaxi/screens/tripReport.dart';

class DriverMapState with ChangeNotifier {
  final BuildContext context;
  static LatLng _initialPosition;
  LatLng get initialPosition => _initialPosition;
  LatLng _lastPosition = _initialPosition;
  LatLng get lastPosition => _lastPosition;
  bool locationServiceActive = true;
  Set<Marker> _markers = {};
  Set<Marker> get markers => _markers;
  Circle _circle;
  Circle get circle => _circle;
  GoogleMapController _mapController;
  StreamSubscription _locationSubscription;
  StreamSubscription _customerAssignedStream;
  StreamSubscription _assignedCustomerDocumentStream;
  Firestore _firestore = Firestore.instance;
  Geoflutterfire geo = Geoflutterfire();
  String _customerEmail = '';
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  LatLng pickupLocation;
  LatLng dropLocation;
  DateTime dropTime;
  DateTime pickUpTime;
  bool endTripButton = false;

  DriverMapState({this.context}) {
    _loadingInitialPosition();
    _getDriverLocation();
    _getAssignedCustomer();
  }

  void updateRideDatabase() async {
    FirebaseUser currentUser = await firebaseAuth.currentUser();
    DocumentSnapshot driverDocumentSnapshot =
        await _firestore.collection('driver').document(currentUser.email).get();
    DocumentSnapshot customerDocumentSnapshot =
        await _firestore.collection('customer').document(_customerEmail).get();
    List<Placemark> pickUpPlacemark = await Geolocator()
        .placemarkFromCoordinates(
            pickupLocation.latitude, pickupLocation.longitude);
    List<Placemark> dropPlacemark = await Geolocator().placemarkFromCoordinates(
        dropLocation.latitude, dropLocation.longitude);
    String pickUpPlaceName = pickUpPlacemark[0].name;
    String dropPlaceName = dropPlacemark[0].name;
    double distance = calculateDistance(
        pickupLocation.latitude,
        pickupLocation.longitude,
        dropLocation.latitude,
        dropLocation.longitude);
    double pricePerKilometer = 17.0;
    double finalFare = distance * pricePerKilometer;
    dropTime = DateTime.now();
    _firestore.collection('rides').add({
      'customerEmail': _customerEmail,
      'driverEmail': currentUser.email,
      'customerName': customerDocumentSnapshot.data['name'],
      'driverName': driverDocumentSnapshot.data['name'],
      'customerPhoneNo': customerDocumentSnapshot.data['phoneNumber'],
      'driverPhoneNo': driverDocumentSnapshot.data['phoneNumber'],
      'carModel': driverDocumentSnapshot.data['carModel'],
      'carNo': driverDocumentSnapshot.data['carNo'],
      'pickUpLocation': pickUpPlaceName,
      'dropLocation': dropPlaceName,
      'distance': distance,
      'fare': finalFare,
      'pickUpTime': pickUpTime,
      'dropTime': dropTime
    });
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TripReport(
          customerName: customerDocumentSnapshot.data['name'],
          driverName: driverDocumentSnapshot.data['name'],
          carNo: driverDocumentSnapshot.data['carNo'],
          carModel: driverDocumentSnapshot.data['carModel'],
          pickUpLocation: pickUpPlaceName,
          dropLocation: dropPlaceName,
          totalDistance: distance,
          fare: finalFare,
          pickUpTime: pickUpTime,
          dropTime: dropTime,
        ),
      ),
    );
    endTrip();
  }

  void endTrip() async {
    _markers.removeWhere((m) => m.markerId.value == 'pickUp');
    _markers.removeWhere((m) => m.markerId.value == 'Drop');
    if (_assignedCustomerDocumentStream != null)
      _assignedCustomerDocumentStream.cancel();
    FirebaseUser currentUser = await firebaseAuth.currentUser();
    _firestore
        .collection('driverCustomerCommon')
        .document(currentUser.email)
        .updateData({'customerEmail': FieldValue.delete()});
    _firestore.collection('customerRequest').document(_customerEmail).delete();
    _customerEmail = '';
    endTripButton = false;
    notifyListeners();
  }

  void _getAssignedCustomer() async {
    FirebaseUser currentUser = await firebaseAuth.currentUser();
    Stream<DocumentSnapshot> stream = _firestore
        .collection('driverCustomerCommon')
        .document(currentUser.email)
        .snapshots();
    _customerAssignedStream = stream.listen((DocumentSnapshot document) {
      if (document.data.containsKey('customerEmail')) {
        _customerEmail = document.data['customerEmail'];
        _getAssignedCustomerPickupLocation();
      } else {
        _customerEmail = '';
        if (_assignedCustomerDocumentStream != null)
          _assignedCustomerDocumentStream.cancel();
        _markers.removeWhere((m) => m.markerId.value == 'pickUp');
        _markers.removeWhere((m) => m.markerId.value == 'Drop');
        endTripButton = false;
        notifyListeners();
      }
    });
  }

  void _getAssignedCustomerPickupLocation() async {
    Stream<DocumentSnapshot> stream = _firestore
        .collection('customerRequest')
        .document(_customerEmail)
        .snapshots();
    _assignedCustomerDocumentStream =
        stream.listen((DocumentSnapshot assignedCustomerDocument) {
      if (assignedCustomerDocument.data != null) {
        GeoPoint pickUpPoint =
            assignedCustomerDocument.data['pickUplocation']['geopoint'];
        GeoPoint dropPoint =
            assignedCustomerDocument.data['droplocation']['geopoint'];
        if (assignedCustomerDocument.data.containsKey('pickUpTime'))
          pickUpTime = (assignedCustomerDocument.data['pickUpTime']).toDate();
        pickupLocation = LatLng(pickUpPoint.latitude, pickUpPoint.longitude);
        dropLocation = LatLng(dropPoint.latitude, dropPoint.longitude);
        _addMarker(pickupLocation, dropLocation);
        endTripButton = true;
      }
    });
    notifyListeners();
  }

  void _addMarker(LatLng pickUpLocation, LatLng dropLocation) {
    _markers.removeWhere((m) => m.markerId.value == 'pickUp');
    _markers.add(Marker(
        markerId: MarkerId('pickUp'),
        position: pickUpLocation,
        infoWindow: InfoWindow(title: 'Pickup Location'),
        icon: BitmapDescriptor.defaultMarker));
    _markers.removeWhere((m) => m.markerId.value == 'Drop');
    _markers.add(Marker(
        markerId: MarkerId('Drop'),
        position: dropLocation,
        infoWindow: InfoWindow(title: 'Drop Location'),
        icon: BitmapDescriptor.defaultMarker));
    notifyListeners();
  }

  // ! ON CAMERA MOVE
  void onCameraMove(CameraPosition position) {
    _lastPosition = position.target;
    notifyListeners();
  }

  // ! ON CREATE
  void onCreated(GoogleMapController controller) {
    _mapController = controller;
    notifyListeners();
  }

  void cancelSubscription() {
    if (_locationSubscription != null) {
      _locationSubscription.cancel();
    }
    if (_assignedCustomerDocumentStream != null) {
      _assignedCustomerDocumentStream.cancel();
    }
    if (_customerAssignedStream != null) {
      _customerAssignedStream.cancel();
    }
  }

  void removeAvailableDriver() async {
    final FirebaseUser currentUser = await firebaseAuth.currentUser();
    CollectionReference reference = _firestore.collection('driverAvailable');
    DocumentReference documentReference = reference.document(currentUser.email);
    documentReference.delete();
    _customerEmail = '';
    _firestore.collection('driverWorking').document(currentUser.email).delete();
  }

  // TO GET THE DRIVER LOCATION
  void _getDriverLocation() async {
    try {
      print("GET USER METHOD RUNNING =========");
      Uint8List imageData = await getMarker();
      Position position = await Geolocator()
          .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      _initialPosition = LatLng(position.latitude, position.longitude);
      print(
          "for driver the latitude is: ${position.latitude} and th longitude is: ${position.longitude} ");
      print("initial position is : ${_initialPosition.toString()}");
      updateMarkerAndCircle(position, imageData);
      if (_locationSubscription != null) {
        _locationSubscription.cancel();
      }
      final FirebaseUser currentUser = await firebaseAuth.currentUser();
      _locationSubscription =
          Geolocator().getPositionStream().listen((newLocalData) {
        print(
            "New position: Latitude- ${newLocalData.latitude}, Longitude- ${newLocalData.longitude}");
        GeoFirePoint geoFirePoint = geo.point(
            latitude: newLocalData.latitude, longitude: newLocalData.longitude);
        if (_customerEmail == '') {
          _firestore
              .collection('driverWorking')
              .document(currentUser.email)
              .delete();
          _firestore
              .collection('driverAvailable')
              .document(currentUser.email)
              .setData(
                  {'email': currentUser.email, 'location': geoFirePoint.data});
        } else {
          _firestore
              .collection('driverAvailable')
              .document(currentUser.email)
              .delete();
          _firestore
              .collection('driverWorking')
              .document(currentUser.email)
              .setData(
                  {'email': currentUser.email, 'location': geoFirePoint.data});
        }
        if (_mapController != null) {
          _mapController.animateCamera(CameraUpdate.newCameraPosition(
              CameraPosition(
                  bearing: 0.0,
                  target: LatLng(newLocalData.latitude, newLocalData.longitude),
                  tilt: 0,
                  zoom: 18.00)));
          updateMarkerAndCircle(newLocalData, imageData);
        }
      });
      notifyListeners();
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        debugPrint("Permission Denied");
      }
    }
  }

  //  LOADING INITIAL POSITION
  void _loadingInitialPosition() async {
    await Future.delayed(Duration(seconds: 5)).then((v) {
      if (_initialPosition == null) {
        locationServiceActive = false;
        notifyListeners();
      }
    });
  }

  void updateMarkerAndCircle(Position newLocalData, Uint8List imageData) {
    LatLng latlng = LatLng(newLocalData.latitude, newLocalData.longitude);
    _markers.removeWhere((m) => m.markerId.value == 'home');
    _markers.add(Marker(
        markerId: MarkerId("home"),
        position: latlng,
        rotation: newLocalData.heading,
        draggable: false,
        zIndex: 2,
        flat: true,
        anchor: Offset(0.5, 0.5),
        icon: BitmapDescriptor.fromBytes(imageData)));
    /*  _circle = Circle(
        circleId: CircleId("car"),
        radius: newLocalData.accuracy,
        zIndex: 1,
        strokeColor: Colors.blue,
        center: latlng,
        fillColor: Colors.blue.withAlpha(70));*/
    notifyListeners();
  }

  Future<Uint8List> getMarker() async {
    ByteData byteData =
        await DefaultAssetBundle.of(context).load("images/car_icon.png");
    return byteData.buffer.asUint8List();
  }

  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }
}
