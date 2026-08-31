import 'package:flutter/material.dart';
import 'package:mobile/theme.dart';
import 'package:mobile/widgets/mf_components.dart';
import 'package:mobile/widgets/tab_icons.dart';

Future<void> showEmployerInviteSheet({
  required BuildContext context,
  required VoidCallback onEmployerSignIn,
  VoidCallback? onContinueBrowsing,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return _MfSheetShell(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const _SheetHandle(),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? MfColors.surfaceDarkElevated
                    : const Color(0xFFEEF2FF),
                shape: BoxShape.circle,
              ),
              child: const MfShopAssistantIcon(
                size: 76,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Are you an employer?',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'Hire verified workers for cleaning, delivery, care, and repairs. '
                'Post a task, review applicants, and pay securely in-app.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark ? MfColors.mutedDark : MfColors.muted,
                  height: 1.45,
                ),
              ),
            ),
            const SizedBox(height: 24),
            MfPrimaryButton(
              label: 'Sign in as employer',
              onPressed: () {
                Navigator.of(context).pop();
                onEmployerSignIn();
              },
            ),
            const SizedBox(height: 10),
            MfSecondaryButton(
              label: 'No, Thanks',
              onPressed: () {
                Navigator.of(context).pop();
                onContinueBrowsing?.call();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      );
    },
  );
}

Future<void> showLoginToGetJobSheet({
  required BuildContext context,
  required VoidCallback onSignIn,
  String? jobTitle,
  String title = 'Sign in to get this job',
  String? message,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final body = message ??
      (jobTitle == null
          ? 'Create or sign in to your MchongoFasta account to continue.'
          : '“$jobTitle” is available nearby. Sign in as a worker to apply, '
              'chat with the employer, and get paid.');

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return _MfSheetShell(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SheetHandle(),
            const SizedBox(height: 12),
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: isDark ? MfColors.surfaceDarkElevated : const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.lock_open_rounded,
                color: isDark ? MfColors.primarySoft : MfColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              body,
              style: TextStyle(
                color: isDark ? MfColors.mutedDark : MfColors.muted,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 22),
            MfPrimaryButton(
              label: 'Sign in to continue',
              onPressed: () {
                Navigator.of(context).pop();
                onSignIn();
              },
            ),
            const SizedBox(height: 10),
            MfSecondaryButton(
              label: 'Not now',
              onPressed: () => Navigator.of(context).pop(),
            ),
            const SizedBox(height: 8),
          ],
        ),
      );
    },
  );
}

class _MfSheetShell extends StatelessWidget {
  const _MfSheetShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(top: false, child: child),
      ),
    );
  }
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Container(
        width: 44,
        height: 5,
        decoration: BoxDecoration(
          color: isDark ? MfColors.lineDark : MfColors.line,
          borderRadius: BorderRadius.circular(99),
        ),
      ),
    );
  }
}

