import 'package:geocoding/geocoding.dart';

Future<Map> getLocationAddress(double lat, double long) async {
  List<Placemark> places = await placemarkFromCoordinates(lat, long);
  Map address = {
    'street': places[0].street,
    'locationName': places[0].name,
    'country': places[0].country,
    'postalCode': places[0].postalCode,
    'locality': places[0].locality,
    'subLocality': places[0].subLocality,
  };
  return address;
}
