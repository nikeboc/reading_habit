import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reading_habit_formation_app/Login/login_page.dart';
import 'package:reading_habit_formation_app/Main/main_model.dart';
import 'package:reading_habit_formation_app/Output/output_model.dart';
import 'package:reading_habit_formation_app/User/user_data.dart';
import 'package:table_calendar/table_calendar.dart';

// ignore: must_be_immutable
class MainPage extends StatelessWidget {
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
            title: Text('短時間読書習慣'),
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
          body: MyHomePage(email: email),
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.email}) : super(key: key);

  final String email;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  AnimationController _animationController;
  CalendarController _calendarController;
  String email;
  Map<DateTime, List> events = {};

  @override
  void initState() {
    super.initState();
    print('userEmail:${widget.email}');
    email = widget.email;
    _calendarController = CalendarController();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _calendarController.dispose();
    super.dispose();
  }

  // void _onDaySelected(DateTime day, List events, List holidays) {
  //   print('CALLBACK: 日付変わりました');
  //   setState(() {});
  // } //todo 日付選択時に機能するよ
  //
  // void _onVisibleDaysChanged(
  //     DateTime first, DateTime last, CalendarFormat format) {
  //   print('CALLBACK: 表示するページが変わりました');
  // } //todo 月が変わっと時に機能するよ
  //
  // void _onCalendarCreated(
  //     DateTime first, DateTime last, CalendarFormat format) {
  //   print('CALLBACK: カレンダー作成しました');
  // } //todo カレンダー作成時に機能するよ
  //
  // void _onDayLongPressed(DateTime day, List events, List holidays) {
  //   print('長押しされました');
  // }
  //
  // void reload(DateTime day, List events, List holidays) {
  //   print('更新しました');
  // }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<OutputModel>(
      create: (_) => OutputModel()..fetchEvents(),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Consumer<OutputModel>(builder: (context, model, child) {
            events = {};
            events.addAll(model.eventList);
            model.userEmail = email;

            print(events);
            print('currentUserEvents${events.length}');

            return TableCalendar(
              events: events,
              headerVisible: true,
              // todo header表示するかどうか
              calendarController: _calendarController,
              startingDayOfWeek: StartingDayOfWeek.sunday,
              //todo 月曜日からスタートする
              calendarStyle: CalendarStyle(
                selectedColor: Colors.red[600],
                todayColor: Colors.red[300],
                outsideDaysVisible: false,
              ),
              headerStyle: HeaderStyle(
                centerHeaderTitle: true,
                formatButtonVisible: false, //todo 右側にあったボタンの有無
                formatButtonTextStyle:
                    TextStyle().copyWith(color: Colors.white, fontSize: 15.0),
                formatButtonDecoration: BoxDecoration(
                  color: Colors.deepOrange[400],
                  borderRadius: BorderRadius.circular(16.0),
                ),
              ),
              builders: CalendarBuilders(
                markersBuilder: (context, date, events, holidays) {
                  final children = <Widget>[];

                  if (events.isNotEmpty) {
                    children.add(
                      Positioned(
                        right: 1,
                        bottom: 1,
                        child: _buildEventsMarker(date, events),
                      ),
                    );
                  }

                  return children;
                },
              ),
              // onDaySelected: _onDaySelected, //todo 日付チェンジ
              // onVisibleDaysChanged: _onVisibleDaysChanged, //todo 月チェンジor表示範囲変更
              // onCalendarCreated: _onCalendarCreated, //todo カレンダー起動
              // onDayLongPressed: _onDayLongPressed,
            );
          }),
          SizedBox(height: 16.0),
          Center(
            child: Consumer<OutputModel>(builder: (context, model, child) {
              return Text('習慣達成日数：' + events.length.toString());
            }),
          ),
          SizedBox(height: 16.0),
          Consumer<OutputModel>(
            builder: (context, model, child) {
              return RaisedButton(
                onPressed: () async {
                  DateTime now = DateTime.now();
                  DateTime yearToDay = DateTime(now.year, now.month, now.day);
                  if (events.containsKey(yearToDay)) {
                    await existEvent(context);
                  } else {
                    await addEvent(model, context);
                    await model.fetchEvents();
                  }
                },
                child: Text('習慣達成ボタン'),
                color: Colors.red[200],
                highlightElevation: 16,
                highlightColor: Colors.red,
                onHighlightChanged: (value) {},
              );
            },
          ),
          SizedBox(height: 16.0),
          Center(
            child: Text('↓当日に限り習慣達成を訂正できます↓'),
          ),
          SizedBox(height: 16.0),
          Consumer<OutputModel>(builder: (context, model, child) {
            return RaisedButton(
              child: Text('習慣削除ボタン'),
              onPressed: () async {
                DateTime now = DateTime.now();
                DateTime yearToDay = DateTime(now.year, now.month, now.day);
                if (events.containsKey(yearToDay)) {
                  events.remove(yearToDay);
                  await deleteEvent(model, context);
                  await model.fetchEvents();
                } else {
                  await noFoundedEvent(context);
                }
              },
              color: Colors.red[200],
              highlightElevation: 16,
              highlightColor: Colors.red,
              onHighlightChanged: (value) {},
            );
          }),
        ],
      ),
    );
  }

  Future addEvent(OutputModel model, BuildContext context) async {
    await model.addEventToFirebase();

    await showDialog<void>(
      context: context, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('読書習慣達成です！'),
          actions: <Widget>[
            FlatButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future deleteEvent(OutputModel model, BuildContext context) async {
    await model.deleteBook();
    await showDialog<void>(
      context: context, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('本日の読書習慣を削除しました！'),
          actions: <Widget>[
            FlatButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future existEvent(BuildContext context) async {
    await showDialog<void>(
      context: context, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('本日は既に習慣達成済です！'),
          actions: <Widget>[
            FlatButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future noFoundedEvent(BuildContext context) async {
    await showDialog<void>(
      context: context, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('本日は読書をしていません。ぜひ１ページでも良いので読んでください。'),
          actions: <Widget>[
            FlatButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildEventsMarker(DateTime date, List events) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: _calendarController.isSelected(date)
            ? Colors.green[500]
            : _calendarController.isToday(date)
                ? Colors.green[300]
                : Colors.blue[500],
      ),
      width: 16.0,
      height: 16.0,
      child: Center(
        child: Text(
          '読',
          style: TextStyle().copyWith(
            color: Colors.white,
            fontSize: 12.0,
          ),
        ),
      ),
    );
  }
}
