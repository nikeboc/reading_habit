import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reading_habit_formation_app/Login/login_model.dart';
import 'package:reading_habit_formation_app/Main/main_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(LoginPage());
}

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.red),
      title: 'readingHabitFormationApp',
      home: ChangeNotifierProvider<LoginModel>(
        create: (_) => LoginModel(),
        child: Scaffold(
          appBar: AppBar(
            title: Text('googleアカウントでログインしてください。'),
          ),
          body: Consumer<LoginModel>(builder: (context, model, child) {
            return Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    RaisedButton(
                      child: Text('Sign in Google'),
                      onPressed: () async {
                        await model
                            .handleSignIn()
                            .then((User user) => {
                                  if (user == null)
                                    {}
                                  else
                                    {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  MainPage(userData: user)))
                                    },
                                })
                            .catchError((e) => print(e));
                      },
                    ),
                  ]),
            );
          }),
        ),
      ),
    );
  }
}
