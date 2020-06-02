import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:oitaxi/screens/sideMenu.dart';
import 'package:oitaxi/shared/loading.dart';
import 'package:provider/provider.dart';
import 'package:oitaxi/states/userMapSate.dart';

class CustomerMapActivity extends StatefulWidget {
  @override
  _CustomerMapActivityState createState() => _CustomerMapActivityState();
}

class _CustomerMapActivityState extends State<CustomerMapActivity> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider.value(value: UserMapState())],
      child: Map(),
    );
  }
}

class Map extends StatefulWidget {
  @override
  _MapState createState() => _MapState();
}

class _MapState extends State<Map> {
  UserMapState userMapState;

  @override
  void dispose() {
    userMapState.cancelSubscription();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    userMapState = Provider.of<UserMapState>(context);
    return SafeArea(
      child: userMapState.initialPosition == null
          ? Container(
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Loading(),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Visibility(
                    visible: userMapState.locationServiceActive == false,
                    child: Text("Please enable location services!",
                        style: TextStyle(color: Colors.grey, fontSize: 18)),
                  ),
                ],
              ),
            )
          : Scaffold(
              appBar: AppBar(),
              drawer: SideMenu(),
              body: Builder(
                builder: (context) => Stack(
                  children: <Widget>[
                    GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: userMapState.initialPosition,
                        zoom: 17,
                      ),
                      onMapCreated: userMapState.onCreated,
                      myLocationEnabled: true,
                      mapType: MapType.normal,
                      compassEnabled: true,
                      zoomControlsEnabled: false,
                      markers: userMapState.markers,
                      onCameraMove: userMapState.onCameraMove,
                      polylines: userMapState.polyLines,
                    ),
                    Positioned(
                      top: 50.0,
                      right: 15.0,
                      left: 15.0,
                      child: Container(
                        height: 50.0,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3.0),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey,
                                offset: Offset(1.0, 5.0),
                                blurRadius: 10,
                                spreadRadius: 3)
                          ],
                        ),
                        child: TextField(
                          cursorColor: Colors.black,
                          controller: userMapState.locationController,
                          decoration: InputDecoration(
                            icon: Container(
                              margin: EdgeInsets.only(left: 20, top: 5),
                              width: 10,
                              height: 10,
                              child: Icon(
                                Icons.location_on,
                                color: Colors.black,
                              ),
                            ),
                            hintText: "pick up",
                            border: InputBorder.none,
                            contentPadding:
                                EdgeInsets.only(left: 15.0, top: 16.0),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 105.0,
                      right: 15.0,
                      left: 15.0,
                      child: Container(
                        height: 50.0,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3.0),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey,
                                offset: Offset(1.0, 5.0),
                                blurRadius: 10,
                                spreadRadius: 3)
                          ],
                        ),
                        child: TextField(
                          /*onTap: () async {
                            Prediction p = await PlacesAutocomplete.show(
                                context: context,
                                apiKey: "AIzaSyAjqioKTkbnsldibaTldD_PNhCyEGQ-4fQ",
                                language: "en",
                                components: [Component(Component.country, "in")]);
                            if (p != null) {
                              appState.sendRequestByPlaceId(p.placeId);
                            }
                          },*/
                          cursorColor: Colors.black,
                          controller: userMapState.destinationController,
                          textInputAction: TextInputAction.go,
                          onSubmitted: (value) {
                            userMapState.sendRequest(value);
                          },
                          decoration: InputDecoration(
                            icon: Container(
                              margin: EdgeInsets.only(left: 20, top: 5),
                              width: 10,
                              height: 10,
                              child: Icon(
                                Icons.local_taxi,
                                color: Colors.black,
                              ),
                            ),
                            hintText: "destination?",
                            border: InputBorder.none,
                            contentPadding:
                                EdgeInsets.only(left: 15.0, top: 16.0),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 15,
                      left: 15,
                      right: 15,
                      child: Visibility(
                        visible: userMapState.findRideButton,
                        child: Container(
                          height: 60.0,
                          child: RaisedButton(
                            child: Text('Find Ride'),
                            onPressed: userMapState.findRide,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 15,
                      left: 15,
                      right: 15,
                      child: Visibility(
                        visible: userMapState.cancelRideButton,
                        child: Container(
                          height: 60.0,
                          child: RaisedButton(
                            child: Text('Cancel Ride'),
                            onPressed: userMapState.cancelRide,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
