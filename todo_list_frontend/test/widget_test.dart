import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_list_frontend/main.dart';

void main() {
  testWidgets('TodoListApp loads main screen', (WidgetTester tester) async {
    await tester.pumpWidget(const TodoListApp());
    expect(find.text('Todos'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });

  testWidgets('Adding a new task shows it in the list', (WidgetTester tester) async {
    await tester.pumpWidget(const TodoListApp());
    // Tap the add FAB
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // Enter a new task name
    await tester.enterText(find.byType(TextFormField), 'Test Task');
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    expect(find.text('Test Task'), findsOneWidget);
  });
}
