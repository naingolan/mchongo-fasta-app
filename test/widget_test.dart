import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/main.dart';

void main() {
  testWidgets('MchongoFasta home renders marketplace shell', (tester) async {
    await tester.pumpWidget(const MchongoFastaApp(skipIntro: true));

    expect(find.text('MchongoFasta'), findsOneWidget);
    expect(find.text('Worker'), findsOneWidget);
    expect(find.text('Employer'), findsOneWidget);
    expect(find.text('Nearby mchongo'), findsOneWidget);
  });

  testWidgets('Theme toggle is available', (tester) async {
    await tester.pumpWidget(const MchongoFastaApp(skipIntro: true));
    expect(find.byTooltip('Use dark mode'), findsOneWidget);
    expect(find.byTooltip('Profile'), findsOneWidget);
  });
}
