import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const apiKey = "AIzaSyCpCmEqTPe2QAMuUvG2zbYgWxMU9ug9kGA";

class GoogleMapServices {
  Future<String> getRouteCoordinates(LatLng l1, LatLng l2) async {
    String url =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${l1.latitude},${l1.longitude}&destination=${l2.latitude},${l2.longitude}&key=$apiKey";
    http.Response response = await http.get(url);
    Map values = jsonDecode(response.body);
    print(values["error_message"]);
    return values["routes"][0]["overview_polyline"]["points"];
  }

  Future<String> getRouteCoordinatesFromPlaceId(
      LatLng l1, String placeId) async {
    String url =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${l1.latitude},${l1.longitude}&destination=place_id:$placeId&key=$apiKey";
    http.Response response = await http.get(url);
    Map values = jsonDecode(response.body);
    return values["routes"][0]["overview_polyline"]["points"];
  }
}
