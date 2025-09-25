import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safe_list/pages/license_screen.dart';

void main() {
  group('LicenseScreen Tests', () {
    setUp(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null);
    });

    Future<void> setupWidget(
      WidgetTester tester, {
      bool withRoutes = false,
      VoidCallback? onNavigate,
    }) async {
      Widget app;

      if (onNavigate != null) {
        app = MaterialApp(
          home: const LicenseScreen(),
          routes: {
            '/todo-list': (context) {
              onNavigate();
              return const Scaffold(body: Text('Todo List'));
            },
          },
        );
      } else if (withRoutes) {
        app = MaterialApp(
          home: const LicenseScreen(),
          routes: {
            '/todo-list': (context) => const Scaffold(body: Text('Todo List')),
          },
        );
      } else {
        app = const MaterialApp(home: LicenseScreen());
      }

      await tester.pumpWidget(app);
      await tester.idle();
      await tester.pump();
    }

    testWidgets('should display initial UI elements', (WidgetTester tester) async {
      await setupWidget(tester);

      expect(find.text('Safe List'), findsOneWidget);
      expect(find.text('Toque na tela para colar sua licença'), findsOneWidget);
      expect(find.text('Copie sua licença e toque em qualquer lugar da tela'), findsOneWidget);
      expect(find.byIcon(Icons.security), findsOneWidget);
      expect(find.byType(GestureDetector), findsOneWidget);
    });

    testWidgets('should show success message and license preview when clipboard has content',
        (WidgetTester tester) async {
      const testLicense = 'TEST-LICENSE-123456';

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        SystemChannels.platform,
        (MethodCall methodCall) async {
          if (methodCall.method == 'Clipboard.getData') {
            return <String, dynamic>{'text': testLicense};
          }
          return null;
        },
      );

      await setupWidget(tester, withRoutes: true);

      await tester.tap(find.byType(GestureDetector));
      await tester.pump();

      expect(find.text('Licença colada com sucesso!'), findsOneWidget);
      expect(find.text('Licença: $testLicense'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);

      await tester.pump(const Duration(seconds: 2));
    });

    testWidgets('should show error message when clipboard is empty',
        (WidgetTester tester) async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        SystemChannels.platform,
        (MethodCall methodCall) async {
          if (methodCall.method == 'Clipboard.getData') {
            return null;
          }
          return null;
        },
      );

      await setupWidget(tester);

      await tester.tap(find.byType(GestureDetector));
      await tester.pump();

      expect(find.text('Nenhuma licença encontrada na área de transferência'),
          findsOneWidget);
    });

    testWidgets('should truncate long license preview', (WidgetTester tester) async {
      const longLicense = 'THIS-IS-A-VERY-LONG-LICENSE-KEY-THAT-SHOULD-BE-TRUNCATED';

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        SystemChannels.platform,
        (MethodCall methodCall) async {
          if (methodCall.method == 'Clipboard.getData') {
            return <String, dynamic>{'text': longLicense};
          }
          return null;
        },
      );

      await setupWidget(tester, withRoutes: true);

      await tester.tap(find.byType(GestureDetector));
      await tester.pump();

      expect(find.textContaining('Licença:'), findsOneWidget);
      expect(find.textContaining('...'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);

      await tester.pump(const Duration(seconds: 2));
    });

    testWidgets('should attempt navigation after successful license paste',
        (WidgetTester tester) async {
      const testLicense = 'TEST-LICENSE';
      bool navigationCalled = false;

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        SystemChannels.platform,
        (MethodCall methodCall) async {
          if (methodCall.method == 'Clipboard.getData') {
            return <String, dynamic>{'text': testLicense};
          }
          return null;
        },
      );

      await setupWidget(
        tester,
        onNavigate: () => navigationCalled = true,
      );

      await tester.tap(find.byType(GestureDetector));
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));

      expect(navigationCalled, isTrue);
    });

    testWidgets('should not show license preview when no license is set',
        (WidgetTester tester) async {
      await setupWidget(tester);

      expect(find.byIcon(Icons.check_circle), findsNothing);
      expect(find.textContaining('Licença:'), findsNothing);
    });

    testWidgets('should handle empty clipboard text', (WidgetTester tester) async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        SystemChannels.platform,
        (MethodCall methodCall) async {
          if (methodCall.method == 'Clipboard.getData') {
            return <String, dynamic>{'text': ''};
          }
          return null;
        },
      );

      await setupWidget(tester);

      await tester.tap(find.byType(GestureDetector));
      await tester.pump();

      expect(find.text('Nenhuma licença encontrada na área de transferência'),
          findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsNothing);
    });
  });
}