import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:oitaxi/screens/sideMenu.dart';
import 'package:oitaxi/shared/loading.dart';
import 'package:oitaxi/states/driverMapSate.dart';
import 'package:provider/provider.dart';

class DriverMapActivity extends StatefulWidget {
  @override
  _DriverMapActivityState createState() => _DriverMapActivityState();
}

class _DriverMapActivityState extends State<DriverMapActivity> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: DriverMapState(context: context))
      ],
      child: Map(),
    );
  }
}

class Map extends StatefulWidget {
  @override
  _MapState createState() => _MapState();
}

class _MapState extends State<Map> {
  DriverMapState driverMapState;

  @override
  void dispose() {
    driverMapState.cancelSubscription();
    driverMapState.removeAvailableDriver();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    driverMapState = Provider.of<DriverMapState>(context);
    return SafeArea(
      child: driverMapState.initialPosition == null
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
                    visible: driverMapState.locationServiceActive == false,
                    child: Text("Please enable location services!",
                        style: TextStyle(color: Colors.grey, fontSize: 18)),
                  ),
                ],
              ),
            )
          : Scaffold(
              appBar: AppBar(
                title: Text('Driver Map'),
              ),
              drawer: SideMenu(),
              body: Builder(
                builder: (context) => Stack(
                  children: <Widget>[
                    GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: driverMapState.initialPosition,
                        zoom: 17,
                      ),
                      onMapCreated: driverMapState.onCreated,
                      myLocationEnabled: true,
                      compassEnabled: true,
                      zoomControlsEnabled: false,
                      mapType: MapType.normal,
                      markers: driverMapState.markers,
//                      circles: Set.of((driverMapState.circle != null)
//                          ? [driverMapState.circle]
//                          : []),
                      onCameraMove: driverMapState.onCameraMove,
                    ),
                    Positioned(
                      bottom: 15,
                      left: 15,
                      right: 15,
                      child: Visibility(
                        visible: driverMapState.endTripButton,
                        child: Container(
                          height: 60.0,
                          child: RaisedButton(
                            child: Text('End Ride'),
                            onPressed: driverMapState.updateRideDatabase,
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
