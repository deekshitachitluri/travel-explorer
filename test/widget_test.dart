import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_explorer/app.dart';
import 'package:travel_explorer/data/local/local_storage_service.dart';
import 'package:travel_explorer/services/auth_service.dart';
import 'package:travel_explorer/widgets/category_chip.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Travel Explorer App launches and renders Home screen', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final storage = await LocalStorageService.init();
    final authService = LocalAuthService(prefs);

    // Set phone viewport
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      TravelExplorerApp(storageService: storage, authService: authService),
    );

    await tester.pumpAndSettle();

    // Verify header greetings
    expect(find.textContaining('Namaste'), findsOneWidget);
    expect(
      find.textContaining('Where would you like to explore next?'),
      findsOneWidget,
    );

    // Verify search field trigger
    expect(find.byIcon(Icons.search_rounded), findsWidgets);

    // Verify bottom navigation bar destinations
    expect(find.widgetWithText(BottomNavigationBar, 'Home'), findsOneWidget);
    expect(find.widgetWithText(BottomNavigationBar, 'Explore'), findsOneWidget);
    expect(
      find.widgetWithText(BottomNavigationBar, 'My Trips'),
      findsOneWidget,
    );
    expect(
      find.widgetWithText(BottomNavigationBar, 'Wishlist'),
      findsOneWidget,
    );
    expect(find.widgetWithText(BottomNavigationBar, 'Profile'), findsOneWidget);

    // Verify discovery sections
    expect(find.text('Popular in India'), findsOneWidget);
    expect(find.text('Trending Right Now'), findsOneWidget);
  });

  testWidgets('Category chips render and handle taps', (
    WidgetTester tester,
  ) async {
    bool tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CategoryChip(
            label: 'Beaches',
            isSelected: false,
            onTap: () {
              tapped = true;
            },
          ),
        ),
      ),
    );

    expect(find.text('Beaches'), findsOneWidget);
    expect(find.byIcon(Icons.beach_access_rounded), findsOneWidget);

    await tester.tap(find.text('Beaches'));
    await tester.pump();

    expect(tapped, isTrue);
  });
}
