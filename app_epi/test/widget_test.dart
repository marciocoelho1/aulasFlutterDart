import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_epi/main.dart';
import 'package:app_epi/models/usuario.dart';
import 'package:app_epi/screens/cadastrar_funcionario_screen.dart';

void main() {
  testWidgets('a tela de login é exibida ao abrir o app', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Matrícula'), findsOneWidget);
    expect(find.text('Senha'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
  });

  testWidgets('Enter no campo de senha aciona o login', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    await tester.enterText(find.byType(TextField).at(0), '1001');
    await tester.enterText(find.byType(TextField).at(1), '1234');

    // Simula o "Enter" (action "done") no campo de senha.
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    // Sem backend disponível no teste, o login falha e mostra o SnackBar;
    // o importante é que o handler do Enter foi executado.
    expect(find.byType(SnackBar), findsOneWidget);
  });

  testWidgets('Enter no campo de matrícula também aciona o login', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    await tester.enterText(find.byType(TextField).at(0), '1001');

    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(SnackBar), findsOneWidget);
  });

  testWidgets('tela de adicionar funcionário tem os campos', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CadastrarFuncionarioScreen(
          usuario: Usuario(
            id: 1,
            matricula: '1001',
            nome: 'Ana Souza',
            setor: 'Manutenção',
            perfil: 'ADMIN',
          ),
        ),
      ),
    );

    expect(find.text('Adicionar funcionário'), findsOneWidget);
    expect(find.text('Matrícula *'), findsOneWidget);
    expect(find.text('Nome *'), findsOneWidget);
    expect(find.text('Setor *'), findsOneWidget);
    expect(find.text('Perfil *'), findsOneWidget);
    expect(find.text('Senha *'), findsOneWidget);
    expect(find.text('Cadastrar'), findsOneWidget);
  });
}
