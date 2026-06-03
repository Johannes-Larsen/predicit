import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../data/permission_service.dart';

class LocationModel extends ChangeNotifier {
  LocationModel({required PermissionService permissionService})
      : _permissionService = permissionService;

  final PermissionService _permissionService;

  Position? _position;
  bool _isLoading = false;
  String? _message;

  Position? get position => _position;
  bool get isLoading => _isLoading;
  String? get message => _message;
  bool get hasLocation => _position != null;

  /// Refreshes the user's location after permission is granted. This method is
  /// intentionally not called before runApp; GPS must never block startup.
  Future<void> refresh() async {
    if (_isLoading) return;
    _isLoading = true;
    _message = null;
    notifyListeners();

    final PermissionOutcome outcome = await _permissionService.requestLocation();
    if (outcome != PermissionOutcome.granted) {
      _position = null;
      _message = outcome == PermissionOutcome.permanentlyDenied
          ? 'Location is blocked in Settings.'
          : 'Location permission was not granted.';
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      _position = await Geolocator.getCurrentPosition().timeout(
        const Duration(seconds: 10),
      );
      _message = null;
    } catch (_) {
      _position = null;
      _message = "Couldn't get a location right now.";
    }

    _isLoading = false;
    notifyListeners();
  }
}
