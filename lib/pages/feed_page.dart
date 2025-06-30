import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finstagram/pages/detail_page.dart';
import 'package:finstagram/services/firebase_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  double? _deviceHeight, _deviceWidth;

  FirebaseService? firebaseService;

  @override
  void initState() {
    super.initState();
    firebaseService = GetIt.instance.get<FirebaseService>();
  }

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    return Container(
      height: _deviceHeight!,
      width: _deviceWidth!,
      child: _postListView(),
    );
  }

  Widget _postListView() {
    return StreamBuilder<QuerySnapshot>(
      stream: firebaseService!.getLastestPost(), 
      builder: (BuildContext context, AsyncSnapshot snapshots) {
        if (snapshots.hasData) {
          List _post = snapshots.data!.docs.map((e) => e.data()).toList();
          return ListView.builder(
            itemBuilder: (BuildContext _context, int index) {
              Map _posts = _post[index];
              dynamic imageField = _posts['image'];
              String? imageUrl;
              if(imageField is List && imageField.isNotEmpty){
                imageUrl = imageField[0];
              }else if(imageField is String){
                imageUrl = imageField;
              }
              return GestureDetector(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context){
                    return DetailPage(postId: _posts['postId'], userId: _posts['userId'],);
                  }));
                },
                child:  Container(
                  height: _deviceHeight! * 0.30,
                  margin: EdgeInsets.symmetric(
                    vertical: _deviceHeight! * 0.01,
                    horizontal: _deviceWidth! * 0.05,
                  ),
                  decoration: BoxDecoration(
                    image: imageUrl != null 
                    ? DecorationImage(
                      fit: BoxFit.cover,
                      image: NetworkImage(
                        imageUrl,
                      ),
                    ) : null,
                    color: Colors.grey[200],
                  ),
                ),
              );
            },
            itemCount: _post.length,
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.red,
            ),
          );
        }
      },
    );
  }
}
