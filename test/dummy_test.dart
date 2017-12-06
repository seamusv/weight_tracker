import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test/test.dart' as unitTest;
import 'package:weight_tracker/main.dart';

void main() {
  test('my first unit test', () {
    var answer = 42;
    unitTest.expect(answer, 42);
  });

  testWidgets('my first widget test', (WidgetTester tester) async {
    // You can use keys to locate the widget you need to test
    var sliderKey = new UniqueKey();
    var value = 0.0;

    // Tells the tester to build a UI based on the widget tree passed to it
    await tester.pumpWidget(
      new StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return new MyApp();
        },
      ),
    );
    expect(value, equals(0.0));
  });

}
