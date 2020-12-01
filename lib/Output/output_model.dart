import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:reading_habit_formation_app/User/user_data.dart';

class OutputModel extends ChangeNotifier {
  List<UserData> events = [];
  List<UserData> users = [];
  Map<DateTime, List> eventList = {};
  String userEmail;
  List<String> dateTimeList;
  List<String> userEmailList;

  Future fetchEvents() async {
    final docs = await FirebaseFirestore.instance.collection('events').get();
    final events = docs.docs.map((doc) => UserData(doc)).toList();
    this.events = events;
    dateTimeList = events.map((event) => event.eventTime).toList();
    userEmailList = events.map((event) => event.userEmail).toList();

    print(dateTimeList.length); //todo リスト数確認
    print(userEmailList.length);

    for (int i = 0; i < dateTimeList.length; i++) {
      if (userEmailList[i] == userEmail) {
        // DateTime dateTime = DateTime.parse(dateTimeList[i]);
        // this.eventList[dateTime] = [userEmailList[i]];//todo ここへんじゃね？
        this.eventList[DateTime.parse(dateTimeList[i])] = [userEmailList[i]];
      }
    }
    print(eventList.length);
    notifyListeners();
  }

  Future addEventToFirebase() async {
    DateTime currentTime = DateTime.now();
    DateTime yearToDay =
        DateTime(currentTime.year, currentTime.month, currentTime.day);
    FirebaseFirestore.instance.collection('events').add(
      {
        'eventTime': yearToDay.toString(),
        'createdUser': userEmail,
      },
    );
  }

  Future deleteBook(UserData userdata) async {
    DateTime currentTime = DateTime.now();
    DateTime yearToDay =
        DateTime(currentTime.year, currentTime.month, currentTime.day);
    await FirebaseFirestore.instance
        .collection('events')
        .doc(userdata.eventTime)
        .delete();
  }
}
