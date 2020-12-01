import 'package:cloud_firestore/cloud_firestore.dart';

class UserData {
  String documentID; //todo 使ってないよ
  String eventTime;
  String userEmail;
  UserData(DocumentSnapshot doc) {
    documentID = doc.id; //todo 使ってないよ
    eventTime = doc.data()['eventTime'];
    userEmail = doc.data()['createdUser'];
  }
}
