import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:myindustryhouse_mobile/main.dart';

void main() {
  testWidgets('app boots to the login gate without crashing', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyIndustryHouseApp()));
    await tester.pump();
    expect(find.byType(MyIndustryHouseApp), findsOneWidget);
  });
}
