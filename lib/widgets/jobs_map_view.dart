import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mobile/models/job.dart';
import 'package:mobile/theme.dart';
import 'package:mobile/widgets/mf_components.dart';
import 'package:mobile/widgets/mf_google_map.dart';
import 'package:mobile/widgets/tab_icons.dart';

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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: theme.cardColor,
      elevation: 12,
      shadowColor: isDark
          ? Colors.black.withValues(alpha: 0.5)
          : MfColors.ink.withValues(alpha: 0.16),
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (job.verified)
                    const MfVerifiedTaskIcon(size: 20)
                  else
                    Icon(
                      Icons.pending_actions_outlined,
                      color: MfColors.muted,
                      size: 20,
                    ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      job.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.work_outline, size: 14, color: MfColors.primary),
                      const SizedBox(width: 4),
                      Text(
                        job.category,
                        style: TextStyle(
                          color: MfColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.location_on_outlined, size: 14, color: isDark ? MfColors.primarySoft : MfColors.primary),
                      const SizedBox(width: 4),
                      Text(
                        job.distance,
                        style: TextStyle(
                          color: isDark ? MfColors.primarySoft : MfColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_rounded, size: 16, color: Colors.amber),
                      const SizedBox(width: 3),
                      Text(
                        job.rating,
                        style: TextStyle(
                          color: isDark ? Colors.white70 : MfColors.ink,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    job.pay,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: MfColors.primary,
                      fontSize: 20,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const MfTimeClockIcon(size: 14),
                      const SizedBox(width: 4),
                      Text(
                        job.time,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: MfColors.muted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              MfPrimaryButton(label: 'View Job', onPressed: onOpen),
            ],
          ),
        ),
      ),
    );
  }
}

