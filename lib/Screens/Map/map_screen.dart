import 'dart:async';

import 'package:flutter/material.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';

import '../../Core/route_path.dart';
import '../../Models/user_model.dart';
import '../../Provider/auth_provider.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  String mapNightTheme = '';
  final Completer<GoogleMapController> _controller = Completer();
  LocationData? currentLocation;
  BitmapDescriptor currentLocationIcon = BitmapDescriptor.defaultMarker;

  StreamSubscription<LocationData>? locationSubscription;

  void getUserCurrentLocation() async {
    Location location = Location();

    location.getLocation().then((locationData) async {
      currentLocation = locationData;
      setState(() {});
    });
    final GoogleMapController controller = await _controller.future;

    locationSubscription = location.onLocationChanged.listen((newLoc) async {
      // if (!mounted) return;
      currentLocation = newLoc;
      controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(newLoc.latitude!, newLoc.longitude!),
        zoom: 17.151926040649414,
      )));
      Provider.of<AuthProvider>(context, listen: false)
          .userLatLongUpdate(context, newLoc.latitude!, newLoc.longitude!);
    });
    setState(() {});
    // if ((await Geolocator.checkPermission()) != LocationPermission.whileInUse) {
    //   await Geolocator.requestPermission()
    //       .then((value) {

    //       })
    //       .onError((error, stackTrace) async {
    //     await Geolocator.requestPermission();
    //     print("ERROR" + error.toString());
    //   });
    // }
    // return await Geolocator.getCurrentPosition();
  }

  void setCustommarkerIcon() {
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration.empty, "assets/images/location.png")
        .then((icon) {
      currentLocationIcon = icon;
    });
  }

  @override
  void deactivate() {
    locationSubscription?.cancel();
    super.deactivate();
  }

  @override
  void initState() {
    DefaultAssetBundle.of(context)
        .loadString('assets/map_theme/map_night.json')
        .then((value) {
      mapNightTheme = value;
    });
    getUserCurrentLocation();
    setCustommarkerIcon();
    super.initState();
  }

  getMarkerData(List<Users?> userDetails) async {
    Provider.of<AuthProvider>(context, listen: true).markers.clear();
    // String imgurl = "https://www.fluttercampus.com/img/car.png";

    // Uint8List bytes = (await NetworkAssetBundle(Uri.parse(imgurl)).load(imgurl))
    //     .buffer
    //     .asUint8List();
    // final Uint8List defaultMarkerIcon =
    //     await getBytesFromAsset('assets/images/avatar.png', 100);
    for (int i = 0; i < userDetails.length; i++) {
      // final Uint8List markIcons = await getImages(images[i], 100);

      Provider.of<AuthProvider>(context, listen: false).markers.add(Marker(
            markerId: MarkerId(i.toString()),
            icon: currentLocationIcon,
            // BitmapDescriptor.defaultMarker,
            // userDetails[i].userPic == "" || userDetails[i].userPic == null
            //     ?
            // await BitmapDescriptor.fromAssetImage(
            //     const ImageConfiguration(), "assets/images/avatar.png"),
            // :
            // BitmapDescriptor.defaultMarker,

            position:
                LatLng(userDetails[i]!.latitude!, userDetails[i]!.longitude!),
            infoWindow: InfoWindow(
              title: userDetails[i]!.firstname,
            ),
          ));
      // setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(backgroundColor: Colors.transparent),
      body: Stack(
        children: [
          StreamBuilder<List<Users>?>(
              stream: Provider.of<AuthProvider>(context, listen: false)
                  .getLatLongUsers(),
              builder: (context, snapshot) {
                if (snapshot.data == null) {
                  return Container();
                } else {
                  var userDetails = snapshot.data!;
                  getMarkerData(userDetails);

                  return currentLocation == null
                      ? const Center(child: CircularProgressIndicator())
                      : GoogleMap(
                          mapType: MapType.normal,
                          initialCameraPosition: CameraPosition(
                            target: LatLng(currentLocation!.latitude!,
                                currentLocation!.longitude!),
                            zoom: 17.151926040649414,
                          ),
                          onMapCreated:
                              (GoogleMapController mapController) async {
                            mapController.setMapStyle(mapNightTheme);
                            _controller.complete(mapController);
                          },
                          markers: Set<Marker>.of(
                              Provider.of<AuthProvider>(context, listen: true)
                                  .markers),
                          myLocationEnabled: true,
                          myLocationButtonEnabled: false,
                          zoomControlsEnabled: false,
                        );
                }
              }),
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: EdgeInsets.only(
                  left: 16, top: MediaQuery.of(context).padding.top + 16),
              child: FloatingActionButton(
                  heroTag: 'person',
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person_outline_rounded,
                    size: 35,
                    color: Colors.amber[800],
                  ),
                  onPressed: () {}),
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: EdgeInsets.only(
                  right: 16, top: MediaQuery.of(context).padding.top + 16),
              child: FloatingActionButton(
                  heroTag: 'setting',
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.settings_outlined,
                    size: 35,
                    color: Colors.amber[800],
                  ),
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.mapsettings,
                    );
                  }),
            ),
          )
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: FloatingActionButton(
          backgroundColor: Colors.white,
          heroTag: 'map',
          onPressed: () async {
            // getUserCurrentLocation()
            // .then((value) async {
            // specified current users location
            CameraPosition cameraPosition = CameraPosition(
              target: LatLng(
                  currentLocation!.latitude!, currentLocation!.longitude!),
              zoom: 17.151926040649414,
            );

            final GoogleMapController controller = await _controller.future;
            controller
                .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
            if (mounted) {
              setState(() {});
            }
            //   });
          },
          child: Icon(
            Icons.location_on,
            size: 40,
            color: Colors.amber[800],
          ),
        ),
      ),
    );
  }

  // Future<void> _goToTheLake() async {
  //   final GoogleMapController controller = await _controller.future;
  //   controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
  // }
}
