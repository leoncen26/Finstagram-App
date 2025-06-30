import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as p;

final String Collection_user = 'users';
final String Collection_post = 'posts';

class FirebaseService {
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseStorage _storage = FirebaseStorage.instance;
  FirebaseFirestore _db = FirebaseFirestore.instance;

  Map? currentUsers;

  FirebaseService();

  Future<bool> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential _userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      if (_userCredential.user != null) {
        currentUsers = await getUserData(uid: _userCredential.user!.uid);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<Map?> getUserData({required String uid}) async {
    try {
      DocumentSnapshot _doc =
          await _db.collection(Collection_user).doc(uid).get();
      if (_doc.exists && _doc.data() != null) {
        return _doc.data() as Map;
      } else {
        print("Dokumen dengan UID $uid tidak ditemukan atau kosong");
        return null;
      }
    } catch (e) {
      print("Error saat mengambil data user: $e");
      return null;
    }
  }
  // Future<Map> getUserData({required String uid}) async {
  //   DocumentSnapshot _doc =
  //       await _db.collection(Collection_user).doc(uid).get();
  //   return _doc.data() as Map;
  // }

  Future<bool> registerUser(
      {required String name,
      required String email,
      required String password,
      required File image}) async {
    try {
      UserCredential _userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      String _userId = _userCredential.user!.uid;
      String _fileName = Timestamp.now().millisecondsSinceEpoch.toString() +
          p.extension(image.path);
      UploadTask _task =
          _storage.ref('images/$_userId/$_fileName').putFile(image);
      return _task.then((_snapshot) async {
        String _donwloadURL = await _snapshot.ref.getDownloadURL();
        DocumentReference docRef = _db.collection(Collection_user).doc(_userId);
        String newId = docRef.id;
        await docRef.set({
          'userId': newId,
          'name': name,
          'email': email,
          'image': _donwloadURL,
        });
        return true;
      });
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> postImage(List<File> images, String captions) async {
    try {
      List<String> multiImages = [];
      String _userId = _auth.currentUser!.uid;

      for (File image in images) {
        String _fileName = Timestamp.now().millisecondsSinceEpoch.toString() +
            p.extension(image.path);

        UploadTask _task =
            _storage.ref('images/$_userId/$_fileName').putFile(image);
        TaskSnapshot snapshot = await _task;
        String urls = await snapshot.ref.getDownloadURL();
        multiImages.add(urls);
      }

      DocumentReference docRef = _db.collection(Collection_post).doc();
      String newId = docRef.id;
      await docRef.set({
        'postId': newId,
        'userId': _userId,
        'timestamp': Timestamp.now(),
        'image': multiImages,
        'caption': captions,
      });
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Stream<QuerySnapshot> getPostCurrentUser() {
    String _userId = _auth.currentUser!.uid;
    return _db
        .collection(Collection_post)
        .where('userId', isEqualTo: _userId)
        .snapshots();
  }

  Stream<QuerySnapshot> getLastestPost() {
    return _db
        .collection(Collection_post)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> getPost(String postId) {
    return _db
        .collection(Collection_post)
        .where('postId', isEqualTo: postId)
        .snapshots();
  }

  Stream<QuerySnapshot> getUserDetail(String userId) {
    return _db
        .collection(Collection_user)
        .where('userId', isEqualTo: userId)
        .snapshots();
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<bool> updateProfileImage(File _image) async {
    try {
      String _userId = _auth.currentUser!.uid;
      String _fileName = Timestamp.now().millisecondsSinceEpoch.toString() +
          p.extension(_image.path);
      UploadTask _task =
          _storage.ref('profile_images/$_userId/$_fileName').putFile(_image);
      return await _task.then((_snapshot) async {
        String _donwloadURL = await _snapshot.ref.getDownloadURL();
        await _db.collection(Collection_user).doc(_userId).update({
          'image': _donwloadURL,
        });
        return true;
      });
    } catch (e) {
      print(e);
      return false;
    }
  }
}
