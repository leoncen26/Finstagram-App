import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:finstagram/pages/feed_page.dart';
import 'package:finstagram/pages/profile_page.dart';
import 'package:finstagram/provider/auth_provider.dart';
import 'package:finstagram/services/firebase_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  FirebaseService? firebaseService;
  TextEditingController captionController = TextEditingController();
  List<File> selectedImage = [];

  int _currentPage = 0;

  final List<Widget> _pages = [
    FeedPage(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    firebaseService = GetIt.instance.get<FirebaseService>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: uploadBottomSheet,
        child: const Icon(Icons.add_a_photo),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      appBar: AppBar(
        title: const Text(
          'Finstagram',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.red,
        actions: [
          // GestureDetector(
          //   onTap: _postImage,
          //   child: const Icon(
          //     Icons.add_a_photo,
          //     color: Colors.white,
          //   ),
          // ),
          Padding(
            padding: const EdgeInsets.only(
              left: 8.0,
              right: 8.0,
            ),
            child: GestureDetector(
              onTap: _logout,
              child: const Icon(
                Icons.logout,
                color: Colors.white,
              ),
            ),
          )
        ],
      ),
      body: _pages[_currentPage],
      bottomNavigationBar: _bottomNavigationBar(),
    );
  }

  Widget _bottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentPage,
      onTap: (_index) {
        setState(() {
          _currentPage = _index;
        });
      },
      items: const [
        BottomNavigationBarItem(
          label: 'Feed',
          icon: Icon(
            Icons.feed,
          ),
        ),
        BottomNavigationBarItem(
          label: 'Profile',
          icon: Icon(
            Icons.account_box,
          ),
        ),
      ],
    );
  }

  void uploadBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return StatefulBuilder(builder: (context, StateSetter setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.9,
              ),
              child: Column(
                //mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () async {
                      FilePickerResult? result =
                          await FilePicker.platform.pickFiles(
                        type: FileType.image,
                        allowMultiple: true,
                      );
                      if (result != null) {
                        List<File> images =
                            result.paths.map((path) => File(path!)).toList();
                        setModalState(() {
                          selectedImage = images;
                        });
                        // setModalState((){});
                      }
                    },
                    icon: const Icon(
                      Icons.add_a_photo,
                    ),
                  ),
                  if (selectedImage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: selectedImage.map(
                          (file) {
                            return Image.file(
                              file,
                              height: 100,
                              width: 100,
                            );
                          },
                        ).toList(),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(25.0),
                    child: TextField(
                      controller: captionController,
                      maxLines: null,
                      decoration: const InputDecoration(
                        hintText: 'Masukan Captions',
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            width: 2,
                            color: Colors.grey,
                            style: BorderStyle.solid,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            width: 2,
                            color: Colors.grey,
                            style: BorderStyle.solid,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            width: 2,
                            color: Colors.grey,
                            style: BorderStyle.solid,
                          ),
                        ),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(300, 50),
                      backgroundColor: Colors.red,
                    ),
                    onPressed: () async {
                      if (selectedImage.isNotEmpty &&
                          captionController.text.isNotEmpty) {
                        String caption = captionController.text;
                        final result = await firebaseService!
                            .postImage(selectedImage, caption);
                        if (result) {
                          Navigator.pop(context);
                          captionController.clear();
                          setState(() {
                            selectedImage.clear();
                          });
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Gagal upload gambar')),
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text('Gambar dan Caption tidak boleh kosong'),
                          ),
                        );
                      }
                    }, //upload
                    child: const Text(
                      'Upload',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  // void _postImage() async {
  //   FilePickerResult? _result =
  //       await FilePicker.platform.pickFiles(type: FileType.image);
  //   if (_result != null) {
  //     File _image = File(_result.files.first.path!);
  //     String caption = captionController.text;
  //     await firebaseService!.postImage(_image, caption);
  //   }
  // }

  void _logout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.signOut();
    Navigator.popAndPushNamed(context, 'login');
  }
}
