// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hyuga_app/screens/authenticate/sign_in.dart';
import 'package:hyuga_app/services/auth_service.dart';

void main() {
  testWidgets('Sign In Page UI renders correctly', (WidgetTester tester) async {
    // Helper method that creates a testable Widget from the given Widget
    Widget createWidgetForTesting(Widget child){
      return MaterialApp(
        home: child,
      );
    }

    // Build our app and trigger a frame.
    await tester.pumpWidget(createWidgetForTesting(SignIn()));
    
    // Verify the title is rendered.
    expect(find.text('wine street'), findsOneWidget);

    // Verify the logo is rendered
    var logo = Image.asset(
      'assets/images/wine-street-logo.png',
      width: 80,
    );
    expect(find.byType(Image), findsNWidgets(2));
    
    // Verify that buttons are rendered
    expect(find.text('Sari peste'), findsOneWidget);
    expect(find.text('Continuă prin Google'), findsOneWidget);
    expect(find.text('Continuă prin Facebook'), findsOneWidget);
    expect(find.text('Continuă prin email'), findsOneWidget);

    // Verify that sign-in moves to the next screen
    MaterialButton buildButton(BuildContext context) => MaterialButton(
      splashColor: Theme.of(context).accentColor,
      //splashColor: Colors.orange[100],
      color: Theme.of(context).accentColor,
      minWidth: 150,
      height: 35,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        "Sari peste", 
        style: TextStyle(
          fontSize: 13,
          color: Colors.white
        ),
      ),
      onPressed: () async{
          dynamic signInResult = await authService.signInAnon(); // it either returns a user
          if(signInResult == null)
            print('sign-in failed');
          else {
            print(signInResult.user.uid);
          }
      }
    );

    var findButton = find.ancestor(
      of: find.text("Sari peste"), 
      matching: find.byType(MaterialButton)
    );
    tester.printToConsole(findButton.description);
    await tester.press(findButton);
    await tester.pump(Duration(seconds: 10));
    expect(find.text('Sari peste'), findsOneWidget);
  });
}
