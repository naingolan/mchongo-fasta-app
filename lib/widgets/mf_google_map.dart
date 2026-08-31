import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mobile/config/maps_config.dart';
import 'package:mobile/config/mf_map_style.dart';
import 'package:mobile/theme.dart';

const kDarCenter = LatLng(-6.7924, 39.2083);

/// Shared Google Map with MchongoFasta styling.
class MfGoogleMap extends StatelessWidget {
  const MfGoogleMap({
    super.key,
    required this.initialTarget,
    this.initialZoom = 13,
    this.markers = const <Marker>{},
    this.onMapCreated,
    this.onCameraMove,
    this.onCameraIdle,
    this.myLocationEnabled = false,
    this.myLocationButtonEnabled = false,
    this.zoomControlsEnabled = false,
    this.scrollGesturesEnabled = true,
    this.zoomGesturesEnabled = true,
    this.rotateGesturesEnabled = false,
    this.tiltGesturesEnabled = false,
    this.liteModeEnabled = false,
    this.onTap,
  });

  final LatLng initialTarget;
  final double initialZoom;
  final Set<Marker> markers;
  final MapCreatedCallback? onMapCreated;
  final ArgumentCallback<CameraPosition>? onCameraMove;
  final VoidCallback? onCameraIdle;
  final bool myLocationEnabled;
  final bool myLocationButtonEnabled;
  final bool zoomControlsEnabled;
  final bool scrollGesturesEnabled;
  final bool zoomGesturesEnabled;
  final bool rotateGesturesEnabled;
  final bool tiltGesturesEnabled;
  final bool liteModeEnabled;
  final ArgumentCallback<LatLng>? onTap;

  @override
  Widget build(BuildContext context) {
    if (!MapsConfig.isAvailable) {
      return Container(
        color: const Color(0xFFE8EEF9),
        alignment: Alignment.center,
        child: const Icon(
          Icons.map_outlined,
          color: MfColors.primary,
          size: 40,
        ),
      );
    }

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: initialTarget,
        zoom: initialZoom,
      ),
      style: mfGoogleMapStyle,
      markers: markers,
      onMapCreated: onMapCreated,
      onCameraMove: onCameraMove,
      onCameraIdle: onCameraIdle,
      onTap: onTap,
      myLocationEnabled: myLocationEnabled,
      myLocationButtonEnabled: myLocationButtonEnabled,
      zoomControlsEnabled: zoomControlsEnabled,
      compassEnabled: false,
      mapToolbarEnabled: false,
      scrollGesturesEnabled: scrollGesturesEnabled,
      zoomGesturesEnabled: zoomGesturesEnabled,
      rotateGesturesEnabled: rotateGesturesEnabled,
      tiltGesturesEnabled: tiltGesturesEnabled,
      liteModeEnabled: liteModeEnabled,
    );
  }
}
