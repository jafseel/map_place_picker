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

  Future<MapAddress?> getAddress(
      {double? latitude, double? longitude, String? address}) async {
    if (latitude != null && longitude != null) {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        print(
            'getAddress placem name: ${placemarks.first.name} street: ${placemarks.first.street}');

        return MapAddress.formatAddress(latitude, longitude, placemarks.first);
      }
    }

    if (address != null) {
      List<Location> placemarks = await locationFromAddress(address);
      if (placemarks.isNotEmpty) {
        print(
            'getAddress place $address latiude: ${placemarks.first.latitude} longitude: ${placemarks.first.longitude}');
        return MapAddress(
            placemarks.first.latitude, placemarks.first.longitude, address);
      }
    }
    return null;
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

class MapAddress {
  final double latitude, longitude;
  final String address;

  MapAddress(this.latitude, this.longitude, this.address);
  factory MapAddress.formatAddress(
      double latitude, double longitude, Placemark placemark) {
    String _address =
        '${placemark.name.addCommaToEnd()}${placemark.thoroughfare.addCommaToEnd()}${placemark.subLocality.addCommaToEnd()}${placemark.locality.addCommaToEnd()}${placemark.subAdministrativeArea.addCommaToEnd()}${placemark.postalCode.addCommaToEnd()}${placemark.administrativeArea.addCommaToEnd(isWant: false)}';
    // "${placemark.name.addCommaToEnd()}${placemark.subLocality.addCommaToEnd()}${placemark.locality.addCommaToEnd()}${placemark.administrativeArea.addCommaToEnd()}${placemark.postalCode.addCommaToEnd()}${placemark.country.addCommaToEnd(isWant: false)}";
    return MapAddress(latitude, longitude, _address.removeMultipleComma.trim());
  }

  factory MapAddress.fromJson(Map<String, dynamic> json) {
    return MapAddress(
      json['latitude'],
      json['longitude'],
      json['address'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "latitude": this.latitude,
      "longitude": this.longitude,
      "address": this.address,
    };
  }
}

extension StringNullOrEmpty on String? {
  bool get isNullOrEmpty => this == null || this!.trim().isEmpty;
  bool get isNotNullOrEmpty => this != null && this!.trim().isNotEmpty;
  String addCommaToEnd({bool isWant = true}) =>
      this.isNotNullOrEmpty ? this! + (isWant ? ',' : '') : '';
  String get removeMultipleComma {
    String _str = this
            ?.split(',')
            .where((element) => element.isNotNullOrEmpty)
            // .map((e) => e.trim())
            .join(', ') ??
        '';
    return _str;
  }
}
