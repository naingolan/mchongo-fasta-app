import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mobile/models/job.dart';
import 'package:mobile/models/user_role.dart';
import 'package:mobile/theme.dart';
import 'package:mobile/widgets/mf_components.dart';
import 'package:mobile/widgets/mf_google_map.dart';
import 'package:mobile/widgets/role_sheets.dart';
import 'package:mobile/widgets/tab_icons.dart';

class JobDetailsScreen extends StatefulWidget {
  const JobDetailsScreen({
    super.key,
    required this.job,
    required this.loggedIn,
    required this.role,
    required this.onSignIn,
  });

  final Job job;
  final bool loggedIn;
  final UserRole role;
  final VoidCallback onSignIn;

  @override
  State<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {
  bool _isBookmarked = false;
  bool _isApplying = false;

  String _getEmployerInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return 'VE';
  }

  Future<void> _handleApply() async {
    if (!widget.loggedIn) {
      await showLoginToGetJobSheet(
        context: context,
        jobTitle: widget.job.title,
        onSignIn: widget.onSignIn,
      );
      return;
    }

    if (widget.role == UserRole.employer) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Switch to a worker account to apply for jobs.'),
        ),
      );
      return;
    }

    // Show application confirmation bottom sheet
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final isDark = Theme.of(sheetContext).brightness == Brightness.dark;
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            decoration: BoxDecoration(
              color: Theme.of(sheetContext).cardColor,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: isDark ? MfColors.lineDark : MfColors.line,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Confirm Application',
                    style: Theme.of(sheetContext)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.4,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You are applying for “${widget.job.title}”. The employer will be notified immediately.',
                    style: TextStyle(
                      color: isDark ? MfColors.mutedDark : MfColors.muted,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark
                          ? MfColors.surfaceDarkElevated
                          : const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.verified_outlined,
                          color: isDark ? MfColors.primarySoft : MfColors.primary,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Earn ${widget.job.pay} • Escrow Protected',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? Colors.white
                                  : MfColors.primaryDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  MfPrimaryButton(
                    label: 'Send Application',
                    onPressed: () => Navigator.of(sheetContext).pop(true),
                  ),
                  const SizedBox(height: 10),
                  MfSecondaryButton(
                    label: 'Cancel',
                    onPressed: () => Navigator.of(sheetContext).pop(false),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (confirmed == true && mounted) {
      setState(() => _isApplying = true);
      await Future<void>.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;
      setState(() => _isApplying = false);

      await showMfSuccessDialog(
        context: context,
        title: 'Application Submitted!',
        message:
            'You’ve successfully applied for “${widget.job.title}”. We’ll notify you as soon as the employer accepts.',
        onDone: () => Navigator.of(context).pop(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final job = widget.job;

    final titleWords = job.title.trim().split(RegExp(r'\s+'));
    final shortTitle = titleWords.length <= 2
        ? job.title
        : '${titleWords[0]} ${titleWords[1]}';

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          shortTitle,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: isDark ? MfColors.primarySoft : MfColors.primary,
          ),
        ),
        actions: [
          IconButton(
            tooltip: _isBookmarked ? 'Saved' : 'Save job',
            icon: MfBookmarkRibbonIcon(
              isActive: _isBookmarked,
              size: 22,
            ),
            onPressed: () {
              setState(() => _isBookmarked = !_isBookmarked);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  duration: const Duration(seconds: 1),
                  content: Text(
                    _isBookmarked ? 'Saved to bookmarks' : 'Removed from bookmarks',
                  ),
                ),
              );
            },
          ),
          IconButton(
            tooltip: 'Share',
            icon: const MfShareNetworkIcon(size: 20),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Job link copied to clipboard.'),
                ),
              );
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
              children: [
                // Top Header Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? Colors.black.withValues(alpha: 0.25)
                            : MfColors.ink.withValues(alpha: 0.05),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          StatusPill(
                            icon: Icons.category_outlined,
                            label: job.category,
                          ),
                          const SizedBox(width: 8),
                          if (job.verified)
                            const StatusPill(
                              customIcon: MfVerifiedTaskIcon(size: 16),
                              label: 'Verified Task',
                            ),
                          const Spacer(),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const MfTimeClockIcon(size: 15),
                              const SizedBox(width: 5),
                              Text(
                                job.time,
                                style: TextStyle(
                                  color: isDark
                                      ? MfColors.mutedDark
                                      : MfColors.muted,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        job.title,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? MfColors.primary.withValues(alpha: 0.25)
                                  : const Color(0xFFE3EDFF),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isDark
                                    ? MfColors.primarySoft.withValues(alpha: 0.3)
                                    : const Color(0xFFBFD5FF),
                                width: 1,
                              ),
                            ),
                            child: const MfSafePayIcon(size: 24),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            job.pay,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: isDark
                                  ? MfColors.primarySoft
                                  : MfColors.primary,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.6,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '• Fixed Rate',
                            style: TextStyle(
                              color: isDark
                                  ? MfColors.mutedDark
                                  : MfColors.muted,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Escrow & Safety Reassurance Banner
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? MfColors.surfaceDarkElevated
                        : const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark
                          ? MfColors.primarySoft.withValues(alpha: 0.25)
                          : MfColors.primary.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isDark
                              ? MfColors.primary.withValues(alpha: 0.28)
                              : const Color(0xFFE3EDFF),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark
                                ? MfColors.primarySoft.withValues(alpha: 0.35)
                                : const Color(0xFFBFD5FF),
                            width: 1.5,
                          ),
                        ),
                        child: const MfSafePayIcon(
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Guaranteed Safe Pay',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: isDark
                                    ? Colors.white
                                    : MfColors.primaryDark,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Funds secured in escrow before work begins.',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? MfColors.mutedDark
                                    : MfColors.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Description
                const Text(
                  'Task Description',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  job.fullDescription,
                  style: TextStyle(
                    height: 1.55,
                    fontSize: 15,
                    color: isDark ? Colors.white70 : MfColors.ink,
                  ),
                ),
                const SizedBox(height: 22),

                // Requirements & Guidelines Checklist
                const Text(
                  'Requirements',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 10),
                ...job.requirements.map(
                  (req) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          size: 18,
                          color: isDark
                              ? MfColors.primarySoft
                              : MfColors.primary,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            req,
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.4,
                              color: isDark
                                  ? Colors.white
                                  : MfColors.ink,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 22),

                // Location & Map Preview Card
                const Text(
                  'Location',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? Colors.black.withValues(alpha: 0.25)
                            : MfColors.ink.withValues(alpha: 0.05),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(22),
                        ),
                        child: SizedBox(
                          height: 150,
                          width: double.infinity,
                          child: MfGoogleMap(
                            initialTarget: job.position,
                            initialZoom: 14,
                            scrollGesturesEnabled: false,
                            zoomGesturesEnabled: false,
                            markers: {
                              Marker(
                                markerId: MarkerId(job.title),
                                position: job.position,
                              ),
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? MfColors.surfaceDarkElevated
                                    : const Color(0xFFEEF2FF),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.place_outlined,
                                color: isDark
                                    ? MfColors.primarySoft
                                    : MfColors.primary,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${job.distance} away in Dar es Salaam',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    job.landmark,
                                    style: TextStyle(
                                      color: isDark
                                          ? MfColors.mutedDark
                                          : MfColors.muted,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),

                // Employer Profile Card
                const Text(
                  'About the Employer',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? Colors.black.withValues(alpha: 0.25)
                            : MfColors.ink.withValues(alpha: 0.05),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: isDark
                              ? MfColors.primary.withValues(alpha: 0.25)
                              : const Color(0xFFE3EDFF),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark
                                ? MfColors.primarySoft.withValues(alpha: 0.35)
                                : const Color(0xFFBFD5FF),
                            width: 1.5,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          _getEmployerInitials(job.employerName),
                          style: TextStyle(
                            color: isDark
                                ? MfColors.primarySoft
                                : MfColors.primary,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              job.employerName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Rating: ★ ${job.rating} • Verified member',
                              style: TextStyle(
                                color: isDark
                                    ? MfColors.mutedDark
                                    : MfColors.muted,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),

          // Sticky Bottom Action Bar
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.35)
                      : MfColors.ink.withValues(alpha: 0.08),
                  blurRadius: 18,
                  offset: const Offset(0, -6),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Pay',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? MfColors.mutedDark
                              : MfColors.muted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        job.pay,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: isDark
                              ? MfColors.primarySoft
                              : MfColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: FilledButton(
                        onPressed: _isApplying ? null : _handleApply,
                        child: _isApplying
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Apply',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
