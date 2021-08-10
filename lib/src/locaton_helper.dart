import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationHelper {
  final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;
  Future<Position?> getCurrentPosition() async {
    final hasPermission = await _handlePermission();

    if (!hasPermission) {
      return null;
    }

    final isGpsEnabled = await _isGpsEnabled();

    if (!isGpsEnabled) {
      return null;
    }

    final position = await _geolocatorPlatform.getCurrentPosition();

    return position;
    // _updatePositionList(
    //   _PositionItemType.position,
    //   position.toString(),
    // );
  }

  Future<void> getAddress(
    double latitude,
    double longitude,
  ) async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(latitude, longitude);
    print('getAddress placemarks size: ${placemarks.length}');
    if (placemarks.isNotEmpty) {
      print(
          'getAddress placem name: ${placemarks.first.name} street: ${placemarks.first.street}');
    }
  }

  Future<bool> _handlePermission() async {
    LocationPermission permission = await _geolocatorPlatform.checkPermission();
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      return true;
    } else {
      permission = await _geolocatorPlatform.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      permission = await _geolocatorPlatform.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Geolocator.openAppSettings();
      return false;
    }

    return true;
  }

  Future<bool> _isGpsEnabled() async {
    bool serviceEnabled = await _geolocatorPlatform.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // return await
      _geolocatorPlatform.openLocationSettings();
      return false;
    }
    return true;
  }
}

class MapAddress {}
