import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:google_maps_webservice/places.dart';
import 'package:map_place_picker/src/locaton_helper.dart';

class MapScreen extends StatefulWidget {
  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;

  final LatLng _center = const LatLng(45.521563, -122.677433);
  final LocationHelper _locationHelper = LocationHelper();

  bool isCameraMoving = false;

  @override
  void initState() {
    super.initState();
    isCameraMoving = false;
  }

  LatLng _position = LatLng(45.521563, -122.677433);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Maps POC App'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                GoogleMap(
                  // onMapCreated: _onMapCreated,
                  myLocationEnabled: true,
                  onMapCreated: (controller) => _mapController = controller,
                  initialCameraPosition: CameraPosition(
                    target: _center,
                    zoom: 11.0,
                  ),
                  onCameraMove: (position) {
                    _position = position.target;
                    if (isCameraMoving) {
                      return;
                    }
                    setState(() {
                      isCameraMoving = true;
                    });
                  },
                  onCameraIdle: () {
                    setState(() {
                      isCameraMoving = false;
                    });
                    print(
                        'mjm onCameraIdle position latitude: ${_position.latitude} longitude: ${_position.longitude}');
                  },
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.location_pin, size: 40),
                    SizedBox(height: 35)
                  ],
                ),
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FloatingActionButton(
                        onPressed: () async {
                          Prediction? p = await PlacesAutocomplete.show(
                            context: context,
                            apiKey: 'API_KEY',
                            types: [],
                            strictbounds: false,
                            mode: Mode.fullscreen,
                            language: "en",
                            decoration: InputDecoration(
                              hintText: 'Search',
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            components: [Component(Component.country, "in")],
                          );
                        },
                        child: Icon(Icons.search),
                      ),
                      SizedBox(height: 10),
                      FloatingActionButton(
                        onPressed: () async {
                          var position =
                              await _locationHelper.getCurrentPosition();
                          if (position != null) {
                            _position =
                                LatLng(position.latitude, position.longitude);
                            _mapController?.animateCamera(
                                CameraUpdate.newCameraPosition(
                                    _getCaeraPoition()));
                            _locationHelper.getAddress(
                                position.latitude, position.longitude);
                          }
                        },
                        child: Icon(Icons.gps_fixed),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 150,
            width: double.infinity,
            color: Colors.amber,
          )
        ],
      ),
    );
  }

  CameraPosition _getCaeraPoition() => CameraPosition(
      bearing: 192.8334901395799,
      target: _position,
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);
}
