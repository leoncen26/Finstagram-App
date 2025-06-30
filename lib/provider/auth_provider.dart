import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier{
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore db = FirebaseFirestore.instance;
  User? _user;
  Map<String, dynamic>? _userData;

  AuthProvider(){
    _user = auth.currentUser;
    auth.authStateChanges().listen((user){
      _user = user;
      notifyListeners();
    });
  }

  User? get user => _user;
  bool get isLoggin => _user != null;

  Future<void> signOut() async{
    await auth.signOut();
  }

  Map<String, dynamic>? get userData => _userData;

  Future<void> fetchUserData() async{
    final userId = auth.currentUser?.uid;
    if(userId != null){
      final doc = await db.collection('users').doc(userId).get();
      _userData = doc.data();
      notifyListeners();
    }
  }
}