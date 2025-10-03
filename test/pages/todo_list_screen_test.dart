import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safe_list/database/database_helper.dart';
import 'package:safe_list/pages/todo_list_screen.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  group('TodoListScreen Tests', () {
    tearDown(() async {
      await DatabaseHelper.instance.close();
    });

    Future<void> setupWidget(WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: TodoListScreen()),
      );
      await tester.idle();
      await tester.pump();
    }

    testWidgets('should display initial UI elements', (WidgetTester tester) async {
      await setupWidget(tester);

      expect(find.text('Minha Lista de Tarefas'), findsOneWidget);
      expect(find.text('Nenhuma tarefa ainda.\nToque no + para adicionar!'), findsOneWidget);
      expect(find.byIcon(Icons.assignment_outlined), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('should show add task dialog when FAB is pressed', (WidgetTester tester) async {
      await setupWidget(tester);

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();

      expect(find.text('Nova Tarefa'), findsOneWidget);
      expect(find.text('Digite sua tarefa aqui...'), findsOneWidget);
      expect(find.text('Salvar'), findsOneWidget);
      expect(find.text('Cancelar'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byType(AlertDialog), findsOneWidget);
    });

    testWidgets('should close dialog when cancel is pressed', (WidgetTester tester) async {
      await setupWidget(tester);

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();

      expect(find.byType(AlertDialog), findsOneWidget);

      await tester.tap(find.text('Cancelar'));
      await tester.pump();

      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('should not add task when text is empty and save is pressed', (WidgetTester tester) async {
      await setupWidget(tester);

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Salvar'));
      await tester.pump();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Nenhuma tarefa ainda.\nToque no + para adicionar!'), findsOneWidget);
    });

    testWidgets('should add task when valid text is entered and saved', (WidgetTester tester) async {
      await setupWidget(tester);

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      const taskText = 'Minha primeira tarefa';
      await tester.enterText(find.byType(TextField), taskText);
      await tester.tap(find.text('Salvar'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
      expect(find.text(taskText), findsOneWidget);
      expect(find.byType(ListTile), findsOneWidget);
      expect(find.byType(Checkbox), findsOneWidget);
      expect(find.byIcon(Icons.delete), findsOneWidget);
    });

    testWidgets('should toggle task completion when checkbox is pressed', (WidgetTester tester) async {
      await setupWidget(tester);

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();

      const taskText = 'Tarefa para completar';
      await tester.enterText(find.byType(TextField), taskText);
      await tester.tap(find.text('Salvar'));
      await tester.pump();

      final checkbox = find.byType(Checkbox);
      expect(checkbox, findsOneWidget);

      Checkbox checkboxWidget = tester.widget(checkbox);
      expect(checkboxWidget.value, isFalse);

      await tester.tap(checkbox);
      await tester.pump();

      checkboxWidget = tester.widget(checkbox);
      expect(checkboxWidget.value, isTrue);

      await tester.tap(checkbox);
      await tester.pump();

      checkboxWidget = tester.widget(checkbox);
      expect(checkboxWidget.value, isFalse);
    });

    testWidgets('should remove task when delete button is pressed', (WidgetTester tester) async {
      await setupWidget(tester);

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();

      const taskText = 'Tarefa para deletar';
      await tester.enterText(find.byType(TextField), taskText);
      await tester.tap(find.text('Salvar'));
      await tester.pump();

      expect(find.text(taskText), findsOneWidget);
      expect(find.byType(ListTile), findsOneWidget);

      await tester.tap(find.byIcon(Icons.delete));
      await tester.pump();

      expect(find.text(taskText), findsNothing);
      expect(find.byType(ListTile), findsNothing);
      expect(find.text('Nenhuma tarefa ainda.\nToque no + para adicionar!'), findsOneWidget);
    });

    testWidgets('should display multiple tasks correctly', (WidgetTester tester) async {
      await setupWidget(tester);

      const tasks = ['Primeira tarefa', 'Segunda tarefa', 'Terceira tarefa'];

      for (final task in tasks) {
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pump();

        await tester.enterText(find.byType(TextField), task);
        await tester.tap(find.text('Salvar'));
        await tester.pump();
      }

      expect(find.byType(ListTile), findsNWidgets(3));
      expect(find.byType(Checkbox), findsNWidgets(3));
      expect(find.byIcon(Icons.delete), findsNWidgets(3));

      for (final task in tasks) {
        expect(find.text(task), findsOneWidget);
      }
    });

    testWidgets('should show empty state after removing all tasks', (WidgetTester tester) async {
      await setupWidget(tester);

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();

      await tester.enterText(find.byType(TextField), 'Única tarefa');
      await tester.tap(find.text('Salvar'));
      await tester.pump();

      expect(find.text('Nenhuma tarefa ainda.\nToque no + para adicionar!'), findsNothing);

      await tester.tap(find.byIcon(Icons.delete));
      await tester.pump();

      expect(find.text('Nenhuma tarefa ainda.\nToque no + para adicionar!'), findsOneWidget);
      expect(find.byIcon(Icons.assignment_outlined), findsOneWidget);
    });

    testWidgets('should show completed task with line-through decoration', (WidgetTester tester) async {
      await setupWidget(tester);

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();

      const taskText = 'Tarefa completada';
      await tester.enterText(find.byType(TextField), taskText);
      await tester.tap(find.text('Salvar'));
      await tester.pump();

      await tester.tap(find.byType(Checkbox));
      await tester.pump();

      final textWidget = tester.widget<Text>(find.text(taskText));
      expect(textWidget.style?.decoration, TextDecoration.lineThrough);
      expect(textWidget.style?.color, Colors.grey);
    });

    testWidgets('should trim whitespace from task text before saving', (WidgetTester tester) async {
      await setupWidget(tester);

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();

      await tester.enterText(find.byType(TextField), '   Tarefa com espaços   ');
      await tester.tap(find.text('Salvar'));
      await tester.pump();

      expect(find.text('Tarefa com espaços'), findsOneWidget);
    });

    testWidgets('should not add task with only whitespace', (WidgetTester tester) async {
      await setupWidget(tester);

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();

      await tester.enterText(find.byType(TextField), '   ');
      await tester.tap(find.text('Salvar'));
      await tester.pump();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Nenhuma tarefa ainda.\nToque no + para adicionar!'), findsOneWidget);
    });
  });
}