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
  List<String> idList;

  Future fetchEvents() async {
    eventList = {};
    final docs = await FirebaseFirestore.instance.collection('events').get();
    final events = docs.docs.map((doc) => UserData(doc)).toList();
    this.events = events;
    dateTimeList = events.map((event) => event.eventTime).toList();
    userEmailList = events.map((event) => event.userEmail).toList();
    idList = events.map((event) => event.documentID).toList();

    print('dateTimeList:${dateTimeList.length}'); //todo リスト数確認
    print('userEmailList:${userEmailList.length}');
    print('idList:${idList.length}');

    for (int i = 0; i < dateTimeList.length; i++) {
      if (userEmailList[i] == userEmail) {
        this.eventList[DateTime.parse(dateTimeList[i])] = [
          userEmailList[i],
          idList[i]
        ];
      }
    }
    print('eventList:${eventList.length}');
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

  Future deleteBook() async {
    DateTime currentTime = DateTime.now();
    DateTime yearToDay =
        DateTime(currentTime.year, currentTime.month, currentTime.day);
    String todayId = eventList[yearToDay][1];
    await FirebaseFirestore.instance.collection('events').doc(todayId).delete();
  }
}
