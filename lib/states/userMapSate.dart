import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:oitaxi/request/google_map_requests.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'dart:math' show cos, sqrt, asin;

const apiKey = "AIzaSyCpCmEqTPe2QAMuUvG2zbYgWxMU9ug9kGA";

class UserMapState with ChangeNotifier {
  static LatLng _initialPosition;
  LatLng _lastPosition = _initialPosition;
  LatLng _pickUpLocation;
  bool locationServiceActive = true;
  bool findRideButton = false;
  Set<Marker> _markers = {};
  Set<Polyline> _polyLines = {};
  GoogleMapController _mapController;
  GoogleMapServices _googleMapsServices = GoogleMapServices();
  TextEditingController locationController = TextEditingController();
  TextEditingController destinationController = TextEditingController();
  LatLng get initialPosition => _initialPosition;
  LatLng get lastPosition => _lastPosition;
  GoogleMapServices get googleMapsServices => _googleMapsServices;
  GoogleMapController get mapController => _mapController;
  Set<Marker> get markers => _markers;
  Set<Polyline> get polyLines => _polyLines;
  List<LatLng> routeCoords = [];
  GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: apiKey);
  Firestore _firestore = Firestore.instance;
  Geoflutterfire geo = Geoflutterfire();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  double _radius = 1;
  StreamSubscription _driverSubscription;
  StreamSubscription _driverLocationSubscription;
  StreamSubscription _driverCustomerStream;
  String status;
  String _driverEmail = '';
  bool cancelRideButton = false;
  LatLng destination;

  UserMapState() {
    _getUserLocation();
    _loadingInitialPosition();
  }

  void cancelRide() async {
    status = null;
    _radius = 1;
    routeCoords = [];
    _polyLines = {};
    _markers = {};
    cancelSubscription();
    final FirebaseUser currentUser = await _firebaseAuth.currentUser();
    _firestore
        .collection('customerRequest')
        .document(currentUser.email)
        .delete();
    _firestore
        .collection('driverCustomerCommon')
        .document(_driverEmail)
        .updateData({'customerEmail': FieldValue.delete()});
    _driverEmail = '';
    if (cancelRideButton == true) {
      cancelRideButton = false;
    }
    destinationController.clear();
    notifyListeners();
  }

  void cancelSubscription() {
    if (_driverSubscription != null) _driverSubscription.cancel();
    if (_driverLocationSubscription != null)
      _driverLocationSubscription.cancel();
    notifyListeners();
  }

  void findRide() async {
    if (findRideButton == true) {
      findRideButton = false;
      cancelRideButton = true;
    }
    final FirebaseUser currentUser = await _firebaseAuth.currentUser();
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    GeoFirePoint geoFirePoint =
        geo.point(latitude: position.latitude, longitude: position.longitude);
    GeoFirePoint geoFirePointDestination = geo.point(
        latitude: destination.latitude, longitude: destination.longitude);
    _firestore
        .collection('customerRequest')
        .document(currentUser.email)
        .setData({
      'pickUplocation': geoFirePoint.data,
      'droplocation': geoFirePointDestination.data
    });
    _pickUpLocation = LatLng(position.latitude, position.longitude);
    _markers.add(Marker(
        markerId: MarkerId(_lastPosition.toString()),
        position: _pickUpLocation,
        infoWindow: InfoWindow(title: 'Pickup Here'),
        icon: BitmapDescriptor.defaultMarker));
    status = 'Getting Nearest Driver.................';
    print(status);
    getClosestDriver();
    notifyListeners();
  }

  void getClosestDriver() async {
    GeoFirePoint center = geo.point(
        latitude: _pickUpLocation.latitude,
        longitude: _pickUpLocation.longitude);
    CollectionReference reference = _firestore.collection('driverAvailable');
    String field = 'location';
    Stream<List<DocumentSnapshot>> stream = geo
        .collection(collectionRef: reference)
        .within(
            center: center, radius: _radius, field: field, strictMode: true);
    final FirebaseUser currentUser = await _firebaseAuth.currentUser();
    _driverSubscription = stream.listen((List<DocumentSnapshot> documentList) {
      // doSomething()
      if (documentList.length == 0) {
        _driverSubscription.cancel();
        _radius++;
        getClosestDriver();
      } else {
        print(_radius);
        _driverSubscription.cancel();
        _driverEmail = documentList[0].data['email'];
        _firestore
            .collection('driverCustomerCommon')
            .document(_driverEmail)
            .updateData({'customerEmail': currentUser.email});
        getDriverLocation();
        status = 'Looking for Driver Location......';
        print(status);
      }
    });
  }

  void getDriverLocation() async {
    Stream<DocumentSnapshot> stream = _firestore
        .collection('driverWorking')
        .document(_driverEmail)
        .snapshots();
    LatLng driverLocation;
    _driverLocationSubscription =
        stream.listen((DocumentSnapshot driverLocationDocument) {
      if (driverLocationDocument.data != null) {
        GeoPoint point = driverLocationDocument.data['location']['geopoint'];
        driverLocation = LatLng(point.latitude, point.longitude);
        _markers.removeWhere((m) => m.markerId.value == 'DriverLocation');
        _markers.add(Marker(
            markerId: MarkerId('DriverLocation'),
            position: driverLocation,
            infoWindow: InfoWindow(title: 'Your Driver'),
            icon: BitmapDescriptor.defaultMarker));
        double distance = calculateDistance(
            _pickUpLocation.latitude,
            _pickUpLocation.longitude,
            driverLocation.latitude,
            driverLocation.longitude);
        if (distance < 100) {
          status = 'Driver arrived at pickup location';
          print(status);
        }
        endRide();
        notifyListeners();
      }
    });
  }

  void endRide() {
    Stream<DocumentSnapshot> stream = _firestore
        .collection('driverCustomerCommon')
        .document(_driverEmail)
        .snapshots();
    _driverCustomerStream = stream.listen((DocumentSnapshot documentSnapshot) {
      if (!documentSnapshot.data.containsKey('customerEmail')) {
        status = 'Ride Ended';
        print(status);
        cancelRide();
        if (_driverCustomerStream != null) _driverCustomerStream.cancel();
      }
    });
  }

  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

// ! TO GET THE USERS LOCATION
  void _getUserLocation() async {
    print("GET USER METHOD RUNNING =========");
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placemark = await Geolocator()
        .placemarkFromCoordinates(position.latitude, position.longitude);
    _initialPosition = LatLng(position.latitude, position.longitude);
    print(
        "the latitude is: ${position.longitude} and th longitude is: ${position.longitude} ");
    print("initial position is : ${_initialPosition.toString()}");
    locationController.text = placemark[0].name;
    notifyListeners();
  }

  // ! TO CREATE ROUTE
  void createRoute(String encondedPoly) {
    PolylinePoints polylinePoints = PolylinePoints();
    print(encondedPoly);
    List<PointLatLng> result = polylinePoints.decodePolyline(encondedPoly);
    for (int i = 0; i < result.length; i++) {
      LatLng route = LatLng(result[i].latitude, result[i].longitude);
      routeCoords.add(route);
    }
    _polyLines.add(Polyline(
        polylineId: PolylineId(_lastPosition.toString()),
        width: 10,
        points: routeCoords,
        color: Colors.black));
    notifyListeners();
  }

  // ! ADD A MARKER ON THE MAO
  void _addMarker(LatLng location, String address) {
    _markers.add(Marker(
        markerId: MarkerId(address),
        position: location,
        infoWindow: InfoWindow(title: address, snippet: "go here"),
        icon: BitmapDescriptor.defaultMarker));
    notifyListeners();
  }

  /* // ! CREATE LATLNG LIST
  List<LatLng> _convertToLatLng(List points) {
    List<LatLng> result = <LatLng>[];
    for (int i = 0; i < points.length; i++) {
      if (i % 2 != 0) {
        result.add(LatLng(points[i - 1], points[i]));
      }
    }
    return result;
  }

  // !DECODE POLY
  List _decodePoly(String poly) {
    var list = poly.codeUnits;
    var lList = new List();
    int index = 0;
    int len = poly.length;
    int c = 0;
// repeating until all attributes are decoded
    do {
      var shift = 0;
      int result = 0;

      // for decoding value of one attribute
      do {
        c = list[index] - 63;
        result |= (c & 0x1F) << (shift * 5);
        index++;
        shift++;
      } while (c >= 32);
      */ /* if value is negative then bitwise not the value */ /*
      if (result & 1 == 1) {
        result = ~result;
      }
      var result1 = (result >> 1) * 0.00001;
      lList.add(result1);
    } while (index < len);

*/ /*adding to previous value as done in encoding */ /*
    for (var i = 2; i < lList.length; i++) lList[i] += lList[i - 2];

    print(lList.toString());

    return lList;
  }*/

  // ! SEND REQUEST
  void sendRequest(String intendedLocation) async {
    List<Placemark> placemark =
        await Geolocator().placemarkFromAddress(intendedLocation);
    if (destinationController.text != '')
      findRideButton = true;
    else
      findRideButton = false;
    double latitude = placemark[0].position.latitude;
    double longitude = placemark[0].position.longitude;
    destination = LatLng(latitude, longitude);
    _addMarker(destination, intendedLocation);
    /*String route = await _googleMapsServices.getRouteCoordinates(
        _initialPosition, destination);
    createRoute(route);*/
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

//  LOADING INITIAL POSITION
  void _loadingInitialPosition() async {
    await Future.delayed(Duration(seconds: 5)).then((v) {
      if (_initialPosition == null) {
        locationServiceActive = false;
        notifyListeners();
      }
    });
  }

  void sendRequestByPlaceId(String placeId) async {
    PlacesDetailsResponse detail = await _places.getDetailsByPlaceId(placeId);
    final lat = detail.result.geometry.location.lat;
    final lng = detail.result.geometry.location.lng;
    LatLng destination = LatLng(lat, lng);
    _addMarker(destination, detail.result.name);
    String route = await _googleMapsServices.getRouteCoordinatesFromPlaceId(
        _initialPosition, placeId);
    createRoute(route);
    notifyListeners();
  }
}
