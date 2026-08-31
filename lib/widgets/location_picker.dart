import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mobile/theme.dart';
import 'package:mobile/widgets/mf_components.dart';
import 'package:mobile/widgets/mf_google_map.dart';

/// Precise pin for where a task happens (not just a neighbourhood name).
class TaskLocation {
  const TaskLocation({
    required this.latitude,
    required this.longitude,
    required this.areaLabel,
    this.landmark = '',
  });

  final double latitude;
  final double longitude;
  final String areaLabel;
  final String landmark;

  LatLng get position => LatLng(latitude, longitude);

  String get shortCoords =>
      '${latitude.toStringAsFixed(5)}, ${longitude.toStringAsFixed(5)}';

  TaskLocation copyWith({
    double? latitude,
    double? longitude,
    String? areaLabel,
    String? landmark,
  }) {
    return TaskLocation(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      areaLabel: areaLabel ?? this.areaLabel,
      landmark: landmark ?? this.landmark,
    );
  }
}

/// Approximate Dar neighbourhood centres used to label a pin.
const kDarAreaCenters = <String, LatLng>{
  'Mikocheni': LatLng(-6.7650, 39.2500),
  'Kariakoo': LatLng(-6.8220, 39.2830),
  'Masaki': LatLng(-6.7450, 39.2800),
  'Kinondoni': LatLng(-6.7860, 39.2660),
  'Upanga': LatLng(-6.8080, 39.2780),
  'Oyster Bay': LatLng(-6.7580, 39.2750),
};

String nearestAreaLabel(LatLng point) {
  var bestLabel = 'Dar es Salaam';
  var bestMeters = double.infinity;
  for (final entry in kDarAreaCenters.entries) {
    final meters = Geolocator.distanceBetween(
      point.latitude,
      point.longitude,
      entry.value.latitude,
      entry.value.longitude,
    );
    if (meters < bestMeters) {
      bestMeters = meters;
      bestLabel = entry.key;
    }
  }
  return bestLabel;
}

Future<LatLng?> resolveDeviceLocation() async {
  final serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) return null;

  var permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }
  if (permission == LocationPermission.denied ||
      permission == LocationPermission.deniedForever) {
    return null;
  }

  final position = await Geolocator.getCurrentPosition(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.high,
    ),
  );
  return LatLng(position.latitude, position.longitude);
}

Future<TaskLocation?> showLocationPicker({
  required BuildContext context,
  TaskLocation? initial,
}) {
  return Navigator.of(context).push<TaskLocation>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => LocationPickerScreen(initial: initial),
    ),
  );
}

class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({super.key, this.initial});

  final TaskLocation? initial;

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  GoogleMapController? _mapController;
  late LatLng _center;
  late String _areaLabel;
  bool _locating = false;

  @override
  void initState() {
    super.initState();
    final seed = widget.initial?.position ??
        kDarAreaCenters[widget.initial?.areaLabel] ??
        kDarCenter;
    _center = seed;
    _areaLabel = widget.initial?.areaLabel ?? nearestAreaLabel(seed);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initial == null) {
        _useMyLocation(silent: true);
      }
    });
  }

  void _onCameraMove(CameraPosition position) {
    _center = position.target;
  }

  void _onCameraIdle() {
    setState(() => _areaLabel = nearestAreaLabel(_center));
  }

  Future<void> _useMyLocation({bool silent = false}) async {
    setState(() => _locating = true);
    try {
      final point = await resolveDeviceLocation();
      if (!mounted) return;
      if (point == null) {
        if (!silent) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Couldn’t get GPS. Drag the map to drop your pin instead.',
              ),
            ),
          );
        }
        return;
      }
      setState(() {
        _center = point;
        _areaLabel = nearestAreaLabel(point);
      });
      await _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(point, 16),
      );
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  void _confirm() {
    Navigator.of(context).pop(
      TaskLocation(
        latitude: _center.latitude,
        longitude: _center.longitude,
        areaLabel: _areaLabel,
        landmark: widget.initial?.landmark ?? '',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MfColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                  const Expanded(
                    child: Text(
                      'Pin task location',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 17,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Text(
                'Drag the map so the pin sits where the worker should arrive. '
                'We’ll also label the nearest Dar area.',
                style: TextStyle(
                  color: MfColors.muted.withValues(alpha: 0.95),
                  height: 1.4,
                ),
              ),
            ),
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  MfGoogleMap(
                    initialTarget: _center,
                    initialZoom: 15.2,
                    onMapCreated: (controller) => _mapController = controller,
                    onCameraMove: _onCameraMove,
                    onCameraIdle: _onCameraIdle,
                    myLocationEnabled: true,
                  ),
                  const IgnorePointer(
                    child: Icon(
                      Icons.location_on_rounded,
                      color: MfColors.primary,
                      size: 48,
                    ),
                  ),
                  Positioned(
                    right: 16,
                    bottom: 16,
                    child: FloatingActionButton.small(
                      heroTag: 'my_location',
                      backgroundColor: Colors.white,
                      foregroundColor: MfColors.primary,
                      onPressed: _locating ? null : () => _useMyLocation(),
                      child: _locating
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.my_location_rounded),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: MfColors.line)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _areaLabel,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_center.latitude.toStringAsFixed(5)}, '
                    '${_center.longitude.toStringAsFixed(5)}',
                    style: const TextStyle(color: MfColors.muted),
                  ),
                  const SizedBox(height: 14),
                  MfPrimaryButton(
                    label: 'Use this location',
                    onPressed: _confirm,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
