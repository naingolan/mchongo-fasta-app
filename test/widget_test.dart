import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/config/maps_config.dart';
import 'package:mobile/main.dart';
import 'package:mobile/models/user_role.dart';
import 'package:mobile/theme.dart';

void main() {
  setUp(() {
    MapsConfig.forceDisable = true;
  });

  testWidgets('MchongoFasta home renders marketplace shell', (tester) async {
    await tester.pumpWidget(const MchongoFastaApp(skipIntro: true));

    expect(find.text('Mchongo Fasta'), findsOneWidget);
    expect(find.text('Map'), findsOneWidget);
    expect(find.text('List'), findsOneWidget);
    expect(find.text('Employer?'), findsOneWidget);
  });

  testWidgets('Theme toggle and tabs switch smoothly in dark mode', (tester) async {
    await tester.pumpWidget(const MchongoFastaApp(skipIntro: true));

    // Toggle dark mode
    final themeToggle = find.byTooltip('Use dark mode');
    expect(themeToggle, findsOneWidget);
    await tester.tap(themeToggle);
    await tester.pumpAndSettle();

    // Tap List tab
    await tester.tap(find.text('List'));
    await tester.pumpAndSettle();
    expect(find.textContaining('House cleaning'), findsOneWidget);

    // Tap Map tab
    await tester.tap(find.text('Map'));
    await tester.pumpAndSettle();

    // Verify dark mode toggle icon updated
    expect(find.byTooltip('Use light mode'), findsOneWidget);
  });

  testWidgets('Worker logged-in shell renders all tabs in dark mode', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.dark,
        home: HomeShell(
          onThemeToggle: () {},
          skipEmployerSheet: true,
          loggedIn: true,
          role: UserRole.worker,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Worker'), findsOneWidget);
    expect(find.text('Find'), findsOneWidget);
    expect(find.text('Verify'), findsOneWidget);
    expect(find.text('Wallet'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);

    // Switch to Verify tab
    await tester.tap(find.text('Verify'));
    await tester.pumpAndSettle();
    expect(find.text('National ID'), findsOneWidget);

    // Switch to Wallet tab
    await tester.tap(find.text('Wallet'));
    await tester.pumpAndSettle();
    expect(find.text('M-Pesa wallet'), findsWidgets);

    // Switch to Profile tab
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(find.text('Asha Mwinyi'), findsOneWidget);
  });

  testWidgets('Tapping a job opens JobDetailsScreen before applying', (tester) async {
    await tester.pumpWidget(const MchongoFastaApp(skipIntro: true));

    // Switch to List tab to see jobs
    await tester.tap(find.text('List'));
    await tester.pumpAndSettle();

    // Tap on the job card
    await tester.tap(find.textContaining('House cleaning'));
    await tester.pumpAndSettle();

    // Verify Job Details screen is shown with short job title in AppBar
    expect(find.text('Task Description'), findsOneWidget);
    expect(find.text('Requirements'), findsOneWidget);
    expect(find.text('Apply for Mchongo'), findsOneWidget);

    // Tap apply as guest -> opens sign in sheet
    await tester.tap(find.text('Apply for Mchongo'));
    await tester.pumpAndSettle();
    expect(find.text('Sign in to get this job'), findsOneWidget);
  });
}



