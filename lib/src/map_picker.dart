library map_place_picker.src;

import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:google_maps_webservice/places.dart';
import 'package:map_place_picker/src/locaton_helper.dart';
import 'package:map_place_picker/src/providers/place_provider.dart';
import 'package:provider/provider.dart';

class MapPicker {
  static void show(
      BuildContext context, String mapApiKey, PlaceSelected placeSelected,
      {LatLng? initialLocation, String? title}) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => _MapScreen(
        mapApiKey: mapApiKey,
        placeSelected: placeSelected,
        defaultLocation:
            initialLocation ?? const LatLng(45.521563, -122.677433),
        title: title,
      ),
    ));
  }
}

class _MapScreen extends StatelessWidget {
  final String mapApiKey;
  final String? title;
  GoogleMapController? _mapController;
  final PlaceSelected placeSelected;

  final LocationHelper _locationHelper = LocationHelper();

  bool isCameraMoving = false, _isFromPlacePicker = false;

  LatLng _position = LatLng(45.521563, -122.677433);

  PlaceProvider? _placeProvider;

  _MapScreen(
      {Key? key,
      required this.mapApiKey,
      required this.placeSelected,
      required this.title,
      required LatLng defaultLocation})
      : super(key: key) {
    _position = defaultLocation;
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _mapController?.dispose();
        print('MapScreen WillPopScope');
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(title ?? 'Maps Picker'),
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
                    initialCameraPosition: _getCaeraPoition(),
                    onCameraMove: (position) {
                      _position = position.target;
                      if (isCameraMoving) {
                        return;
                      }
                      // setState(() {
                      //   isCameraMoving = true;
                      // });
                    },
                    onCameraIdle: () {
                      // setState(() {
                      //   isCameraMoving = false;
                      // });
                      if (_isFromPlacePicker) {
                        _isFromPlacePicker = false;
                        return;
                      }
                      _getAddress(
                          latitude: _position.latitude,
                          longitude: _position.longitude);
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
                          heroTag: null,
                          onPressed: () async {
                            Prediction? p = await PlacesAutocomplete.show(
                              context: context,
                              apiKey: mapApiKey,
                              types: [],
                              strictbounds: false,
                              mode: Mode.fullscreen,
                              language: "en",
                              components: [Component(Component.country, "in")],
                            );
                            if (p?.description != null &&
                                p!.description!.trim().isNotEmpty) {
                              _isFromPlacePicker = true;
                              _getAddress(address: p.description);
                            }

                            print(
                                'Prediction Id : ${p?.id}, placeId : ${p?.placeId}, placeId : ${p?.description}');
                          },
                          child: Icon(Icons.search),
                        ),
                        SizedBox(height: 10),
                        FloatingActionButton(
                          heroTag: null,
                          onPressed: () async {
                            var position =
                                await _locationHelper.getCurrentPosition();
                            if (position != null) {
                              _position =
                                  LatLng(position.latitude, position.longitude);
                              print(
                                  'currentLocation lat: ${_position.latitude} ${_mapController == null}');

                              _mapController?.animateCamera(
                                  CameraUpdate.newLatLng(_position));
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
              height: 110,
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              // color: Colors.amber,
              alignment: Alignment.center,
              child: ChangeNotifierProvider<PlaceProvider>(
                create: (context) {
                  _placeProvider = PlaceProvider(_mapAddress);
                  return _placeProvider!;
                },
                child: _MapAddressWidget(placeSelected),
              ),
            )
          ],
        ),
      ),
    );
  }

  MapAddress? _mapAddress;
  void _getAddress(
      {double? latitude, double? longitude, String? address}) async {
    if (latitude != null && longitude != null) {
      _mapAddress = await _locationHelper.getAddress(
          latitude: _position.latitude, longitude: _position.longitude);
    } else if (address != null) {
      _mapAddress = await _locationHelper.getAddress(address: address);
      if (_mapAddress != null) {
        _position = LatLng(_mapAddress!.latitude, _mapAddress!.longitude);
        if (_isFromPlacePicker) {
          _mapController?.animateCamera(CameraUpdate.newLatLng(_position));
        }
      }
    }
    if (_mapAddress != null) {
      _placeProvider?.mapAddress = _mapAddress;
    }
    return;
  }

  CameraPosition _getCaeraPoition() => CameraPosition(
      bearing: 192.8334901395799,
      target: _position,
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);
}

class _MapAddressWidget extends StatelessWidget {
  final PlaceSelected placeSelected;
  const _MapAddressWidget(this.placeSelected, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _provider = context.watch<PlaceProvider>();
    final MapAddress? _mapAddress = _provider.mapAddress;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _mapAddress?.address ?? 'Address',
          maxLines: 2,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
          ),
        ),
        SizedBox(height: 3),
        ElevatedButton(
          onPressed: () {
            placeSelected(_mapAddress);
            Navigator.pop(context);
          },
          child: Text('Select'),
          style:
              ElevatedButton.styleFrom(primary: Theme.of(context).buttonColor),
        )
      ],
    );
  }
}

typedef PlaceSelected = void Function(MapAddress?);
