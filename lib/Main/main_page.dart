import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reading_habit_formation_app/Input/input_page.dart';
import 'package:reading_habit_formation_app/Login/login_page.dart';
import 'package:reading_habit_formation_app/Main/main_model.dart';
import 'package:reading_habit_formation_app/Output/output_page.dart';
import 'package:reading_habit_formation_app/Survey/survey_page.dart';

// ignore: must_be_immutable
class MainPage extends StatelessWidget {
  final List<Widget> _pageList = [
    InputPage(),
    OutputPage(),
    SurveyPage(),
  ];
  User userData;
  String name = '';
  String email;
  String photoUrl;

  MainPage({User userData}) {
    this.userData = userData;
    this.name = userData.displayName;
    this.email = userData.email;
    this.photoUrl = userData.photoURL;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.red),
      title: 'メイン画面',
      home: ChangeNotifierProvider<MainModel>(
        create: (_) => MainModel(),
        child: Scaffold(
          appBar: AppBar(
            // leading: Icon(Icons.menu),
            title: Consumer<MainModel>(builder: (context, model, child) {
              return Text(model.appBarTitle);
            }),
          ),
          drawer: Consumer<MainModel>(builder: (context, model, child) {
            return Drawer(
              child: Column(children: [
                UserAccountsDrawerHeader(
                  accountName: Text(name),
                  accountEmail: Text(email),
                  currentAccountPicture: CircleAvatar(
                    backgroundColor: Colors.white,
                    backgroundImage: NetworkImage(photoUrl),
                  ),
                ),
                RaisedButton(
                  child: Text('Sign Out Google'),
                  onPressed: () {
                    model.handleSignOut().catchError((e) => print(e));
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) {
                          return LoginPage();
                        },
                      ),
                    );
                  },
                ),
              ]),
            );
          }),
          bottomNavigationBar: Consumer<MainModel>(
            builder: (context, model, child) {
              return BottomNavigationBar(
                items: const <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                    title: Text('読書記録'),
                    icon: Icon(Icons.book),
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.data_usage),
                    title: Text('カレンダー'),
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.school),
                    title: Text('アンケート'),
                  ),
                ],
                unselectedItemColor: Colors.grey,
                selectedItemColor: Colors.redAccent,
                currentIndex: model.selectedIndex,
                onTap: (int index) {
                  model.selectedIndex = index;
                  if (index == 0) {
                    model.appBarTitle = '習慣実行画面';
                  }
                  if (index == 1) {
                    model.appBarTitle = '習慣達成確認画面';
                  }
                  if (index == 2) {
                    model.appBarTitle = 'アンケート';
                  }
                },
              );
            },
          ),
          body: Consumer<MainModel>(builder: (context, model, child) {
            return IndexedStack(
              index: model.selectedIndex,
              children: _pageList,
            );
          }),
        ),
      ),
    );
  }
}
