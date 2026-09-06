import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) {
  return FluentApp(
    home: ScaffoldPage(
      content: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [child],
        ),
      ),
    ),
  );
}

ComboBox<String> _combo({bool isExpanded = false}) {
  return ComboBox<String>(
    isExpanded: isExpanded,
    value: 'A',
    items: const [
      ComboBoxItem(value: 'A', child: Text('A')),
      ComboBoxItem(value: 'B', child: Text('B')),
    ],
    onChanged: (_) {},
  );
}

void main() {
  testWidgets('ComboBox respects external width constraints', (tester) async {
    // Fixed width from the parent.
    await tester.pumpWidget(_wrap(SizedBox(width: 200, child: _combo())));
    expect(
      tester.getSize(find.byType(ComboBox<String>)).width,
      200,
      reason: 'SizedBox should fully determine the width',
    );

    // Content-sized width respects the WinUI minimum of 64.
    await tester.pumpWidget(_wrap(_combo()));
    final contentWidth = tester.getSize(find.byType(ComboBox<String>)).width;
    expect(contentWidth, greaterThanOrEqualTo(64));

    // isExpanded fills the available width.
    await tester.pumpWidget(
      _wrap(SizedBox(width: 300, child: _combo(isExpanded: true))),
    );
    expect(
      tester.getSize(find.byType(ComboBox<String>)).width,
      300,
      reason: 'isExpanded should fill the parent-provided width',
    );
  });

  testWidgets('ComboBox keeps WinUI default metrics under compact density', (
    tester,
  ) async {
    // Windows desktop resolves adaptivePlatformDensity to compact, which must
    // not shrink the fixed WinUI item height.
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    try {
      await tester.pumpWidget(_wrap(_combo()));
      final itemRect = tester.getRect(find.byType(ComboBoxItem<String>).first);
      expect(itemRect.height, 32.0);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });
}
