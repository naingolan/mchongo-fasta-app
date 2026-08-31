import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mobile/models/job.dart';
import 'package:mobile/theme.dart';
import 'package:mobile/widgets/mf_components.dart';
import 'package:mobile/widgets/mf_google_map.dart';

class JobsMapView extends StatefulWidget {
  const JobsMapView({
    super.key,
    required this.jobs,
    required this.onJobTap,
  });

  final List<Job> jobs;
  final ValueChanged<Job> onJobTap;

  @override
  State<JobsMapView> createState() => _JobsMapViewState();
}

class _JobsMapViewState extends State<JobsMapView> {
  Job? _selected;
  GoogleMapController? _controller;

  @override
  void didUpdateWidget(covariant JobsMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_selected != null && !widget.jobs.contains(_selected)) {
      _selected = widget.jobs.isEmpty ? null : widget.jobs.first;
    }
  }

  Future<void> _focusJob(Job job) async {
    setState(() => _selected = job);
    await _controller?.animateCamera(
      CameraUpdate.newLatLngZoom(job.position, 14.2),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selected =
        _selected ?? (widget.jobs.isEmpty ? null : widget.jobs.first);

    final markers = widget.jobs.map((job) {
      final isSelected = identical(job, selected) ||
          (selected != null && job.title == selected.title);
      return Marker(
        markerId: MarkerId(job.title),
        position: job.position,
        icon: BitmapDescriptor.defaultMarkerWithHue(
          isSelected ? BitmapDescriptor.hueAzure : BitmapDescriptor.hueBlue,
        ),
        onTap: () => _focusJob(job),
        infoWindow: InfoWindow(
          title: job.title,
          snippet: '${job.pay} · ${job.distance}',
        ),
      );
    }).toSet();

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: MfGoogleMap(
            initialTarget: selected?.position ?? kDarCenter,
            initialZoom: 12.2,
            markers: markers,
            onMapCreated: (controller) => _controller = controller,
          ),
        ),
        if (selected != null)
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: _SelectedJobCard(
              job: selected,
              onOpen: () => widget.onJobTap(selected),
            ),
          ),
      ],
    );
  }
}

class _SelectedJobCard extends StatelessWidget {
  const _SelectedJobCard({required this.job, required this.onOpen});

  final Job job;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: Theme.of(context).cardColor,
      elevation: 8,
      shadowColor: isDark
          ? Colors.black.withValues(alpha: 0.4)
          : MfColors.ink.withValues(alpha: 0.18),
      borderRadius: BorderRadius.circular(22),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    job.title,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                Text(
                  job.pay,
                  style: TextStyle(
                    color: isDark ? MfColors.primarySoft : MfColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '${job.category} • ${job.distance} • ${job.time}',
              style: TextStyle(
                color: isDark ? MfColors.mutedDark : MfColors.muted,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 12),
            MfPrimaryButton(label: 'View job', onPressed: onOpen),
          ],
        ),
      ),
    );
  }
}

