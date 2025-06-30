import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:finstagram/services/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:finstagram/provider/auth_provider.dart' as MyAuth;
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<StatefulWidget> createState() {
    return _ProfilePageState();
  }
}

class _ProfilePageState extends State<ProfilePage> {
  double? _deviceHeight, _deviceWidth;

  FirebaseService? firebaseService;
  File? _image;

  @override
  void initState() {
    super.initState();
    firebaseService = GetIt.instance.get<FirebaseService>();
  }

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    final userData = Provider.of<MyAuth.AuthProvider>(context).userData;
    final name = userData != null ? userData['name'] : null;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _deviceWidth! * 0.05,
        vertical: _deviceHeight! * 0.02,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _profileimage(),
          nameUser(name),
          _postsGridView(),
        ],
      ),
    );
  }

  Widget _profileimage() {
    final userData = Provider.of<MyAuth.AuthProvider>(context).userData;
    final String? imageUser = userData?['image'];
    ImageProvider imageProvider;
    if (_image != null) {
      imageProvider = FileImage(_image!);
    } else if (imageUser != null && imageUser.isNotEmpty) {
      imageProvider = NetworkImage(imageUser);
    } else {
      imageProvider = NetworkImage('https://i.pravatar.cc/150?img=58');
    }
    return Center(
      child: GestureDetector(
        onTap: () async {
          final result =
              await FilePicker.platform.pickFiles(type: FileType.image);
          if (result != null && result.files.first.path != null) {
            setState(() {
              _image = File(result.files.first.path!);
            });
            bool success = await firebaseService!.updateProfileImage(_image!);
            if (success) {
              final userId = FirebaseAuth.instance.currentUser!.uid;
              final updatedUserData =
                  await firebaseService!.getUserData(uid: userId);
              setState(() {
                firebaseService!.currentUsers = updatedUserData;
                _image = null;
              });
            }
          }
        },
        child: Container(
          margin: EdgeInsets.only(bottom: _deviceHeight! * 0.02),
          height: _deviceHeight! * 0.15,
          width: _deviceHeight! * 0.15,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            image: DecorationImage(
              fit: BoxFit.cover,
              image: imageProvider,
            ),
          ),
        ),
      ),
    );
  }

  Widget nameUser(String? name) {
    return Text(
      name ?? 'Guest',
      style: const TextStyle(
        color: Colors.black,
        fontSize: 30,
      ),
    );
  }

  Widget _postsGridView() {
    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream: firebaseService!.getPostCurrentUser(),
        builder: (BuildContext _context, AsyncSnapshot snapshots) {
          if (snapshots.hasData) {
            List _post = snapshots.data!.docs.map((e) => e.data()).toList();
            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 2,
                crossAxisSpacing: 2,
              ),
              itemCount: _post.length,
              itemBuilder: (BuildContext context, int index) {
                Map _posts = _post[index];
                dynamic imageField = _posts['image'];
                String? imageUrl;
                if (imageField is List && imageField.isNotEmpty) {
                  imageUrl = imageField[0];
                } else if (imageField is String) {
                  imageUrl = imageField;
                }
                return Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: NetworkImage(
                        imageUrl!,
                      ),
                    ),
                  ),
                );
              },
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.red,
              ),
            );
          }
        },
      ),
    );
  }
}
