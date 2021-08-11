import 'package:flutter/foundation.dart';
import 'package:map_place_picker/src/locaton_helper.dart' show MapAddress;

class PlaceProvider extends ChangeNotifier {
  MapAddress? _mapAddress;
  PlaceProvider(this._mapAddress);

  MapAddress? get mapAddress => _mapAddress;

  set mapAddress(MapAddress? mapAddress) {
    this._mapAddress = mapAddress;
    notifyListeners();
  }

  void reset() {
    _mapAddress = null;
  }
}
