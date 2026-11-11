import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakao_book_app/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  SharedPreferences.setMockInitialValues({});

  testWidgets('formats author and sale price for a book', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Home(
          initialBooks: [
            {
              'thumbnail': '',
              'title': 'Sample Book',
              'authors': ['Jane Doe'],
              'sale_price': 10000,
              'status': 'Available',
              'publisher': 'Sample Publisher',
              'datetime': '2026-09-07T00:00:00.000+09:00',
              'isbn': '9781234567890',
              'contents': 'Sample introduction',
              'url': 'https://example.com/book',
            },
            {
              'thumbnail': '',
              'title': 'No Price Book',
              'authors': ['John Doe'],
              'sale_price': -1,
              'status': '\u{C815}\u{C0C1}\u{D310}\u{B9E4}',
            },
          ],
        ),
      ),
    );

    expect(find.byKey(const Key('bookSearchField')), findsOneWidget);
    expect(find.byKey(const Key('searchTargetDropdown')), findsOneWidget);
    expect(find.byKey(const Key('sortDropdown')), findsOneWidget);
    expect(find.text('\u{AE30}\u{BCF8} \u{C815}\u{B82C}'), findsOneWidget);
    expect(find.byKey(const Key('minimumPriceField')), findsOneWidget);
    expect(find.byKey(const Key('maximumPriceField')), findsOneWidget);
    expect(find.byKey(const Key('normalSaleFilter')), findsOneWidget);
    expect(find.byKey(const Key('loadMoreButton')), findsNothing);
    expect(find.text('Jane Doe'), findsOneWidget);
    expect(find.text('[Jane Doe]'), findsNothing);
    expect(find.text('10,000\u{C6D0}'), findsOneWidget);
    expect(
      find.text(
        '\u{D310}\u{B9E4}\u{AC00}\u{ACA9} \u{C815}\u{BCF4} \u{C5C6}\u{C74C}',
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Sample Book'));
    await tester.pumpAndSettle();

    expect(find.text('\u{CC45} \u{C0C1}\u{C138}'), findsOneWidget);
    expect(find.text('Sample Publisher'), findsOneWidget);
    expect(find.text('2026-09-07'), findsOneWidget);
    expect(find.text('9781234567890'), findsOneWidget);
    expect(find.text('Sample introduction'), findsOneWidget);
    expect(find.text('https://example.com/book'), findsOneWidget);

    await tester.tap(find.byKey(const Key('favoriteToggleButton')));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.favorite), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('favoriteBooksButton')));
    await tester.pumpAndSettle();
    expect(find.text('Sample Book'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('minimumPriceField')), '5000');
    await tester.pump();
    expect(find.text('Sample Book'), findsOneWidget);
    expect(find.text('No Price Book'), findsNothing);

    await tester.enterText(find.byKey(const Key('minimumPriceField')), '');
    await tester.pump();

    await tester.tap(find.byKey(const Key('normalSaleFilter')));
    await tester.pump();

    expect(find.text('Sample Book'), findsNothing);
    expect(find.text('No Price Book'), findsOneWidget);
  });
}
