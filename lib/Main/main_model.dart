import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class MainModel extends ChangeNotifier {
  String appBarTitle = 'Timeline';
  int _selectedIndex = 0;
  get selectedIndex => _selectedIndex;
  set selectedIndex(value) {
    _selectedIndex = value;
    notifyListeners();
  }

  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<void> handleSignOut() async {
    await FirebaseAuth.instance.signOut();
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      print(e);
    }
  }
}
