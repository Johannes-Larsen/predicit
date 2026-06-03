import 'package:permission_handler/permission_handler.dart';

/// App-level permission states. Widgets depend on this small enum instead of
/// importing permission_handler directly, keeping plugin details behind a seam.
enum PermissionOutcome {
  granted,
  denied,
  permanentlyDenied,
}

class PermissionService {
  Future<PermissionOutcome> requestCamera() => _request(Permission.camera);

  Future<PermissionOutcome> requestPhotos() => _request(Permission.photos);

  Future<PermissionOutcome> requestLocation() =>
      _request(Permission.locationWhenInUse);

  Future<PermissionOutcome> _request(Permission permission) async {
    final PermissionStatus status = await permission.request();
    if (status.isGranted || status.isLimited) return PermissionOutcome.granted;
    if (status.isPermanentlyDenied || status.isRestricted) {
      return PermissionOutcome.permanentlyDenied;
    }
    return PermissionOutcome.denied;
  }

  Future<bool> openSettings() => openAppSettings();
}
