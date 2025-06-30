import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finstagram/component/expand_caption.dart';
import 'package:finstagram/services/firebase_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DetailPage extends StatefulWidget {
  final String postId;
  final String userId;
  const DetailPage({super.key, required this.postId, required this.userId});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  FirebaseService firebaseService = FirebaseService();
  double? _deviceHeight, _deviceWidth;
  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red,
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
              )),
          title: const Text(
            'Detail Page',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                userInDetail(),
                postDetail(),
                nameCaption(),
              ],
            ),
          ),
        ));
  }

  Widget userInDetail() {
    return StreamBuilder<QuerySnapshot>(
        stream: firebaseService.getUserDetail(widget.userId),
        builder:
            (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshots) {
          if (snapshots.hasData) {
            final List data =
                snapshots.data!.docs.map((e) => e.data()).toList();
            if (data.isEmpty) {
              return const Center(
                child: Text(
                  'Data tidak ditemukan',
                  style: TextStyle(color: Colors.black),
                ),
              );
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: data.length,
              itemBuilder: (context, index) {
                final post = data[index];
                return Row(
                  children: [
                    post['image'] != null
                        ? Container(
                            margin: const EdgeInsets.only(left: 5),
                            height: _deviceHeight! * 0.1,
                            width: _deviceWidth! * 0.1,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: NetworkImage(
                                  post['image'],
                                ),
                              ),
                              border: Border.all(color: Colors.grey, width: 2),
                            ),
                          )
                        : const Icon(Icons.image_not_supported),
                    const SizedBox(width: 10),
                    Text(
                      post['name'],
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                      ),
                    )
                  ],
                );
              },
            );
          } else {
            return const Center(
              child: Text('Error Fetching Data user'),
            );
          }
        });
  }

  Widget postDetail() {
    return StreamBuilder<QuerySnapshot>(
      stream: firebaseService.getPost(widget.postId),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshots) {
        if (snapshots.hasData) {
          final List data = snapshots.data!.docs.map((e) => e.data()).toList();
          if (data.isEmpty) {
            return const Center(
              child: Text('Data no found'),
            );
          }
          final post = data[0];
          dynamic imageField = post['image'];
          //String? imageUrl;
          List<String> imageUrl = [];
          if (imageField is List && imageField.isNotEmpty) {
            imageUrl = List<String>.from(imageField);
          } else if (imageField is String) {
            imageUrl = [imageField];
          }
          return Center(
            child: SizedBox(
              height: 300,
              child: PageView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: imageUrl.length,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        Container(
                          height: 300,
                          width: 300,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(
                                imageUrl[index],
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
            ),
          );
        } else {
          return const Center(
            child: Text('Data detail no found'),
          );
        }
      },
    );
  }

  Widget nameCaption() {
    return StreamBuilder<QuerySnapshot>(
        stream: firebaseService.getPost(widget.postId),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            final List postData =
                snapshot.data!.docs.map((e) => e.data()).toList();
            final dataPost = postData[0];
            final caption = dataPost['caption'];
            final timestamp = (dataPost['timestamp'] as Timestamp).toDate();
            final uploadTime =
                DateFormat('dd MMMM yyyy - HH:mm').format(timestamp);
            return StreamBuilder(
                stream: firebaseService.getUserDetail(widget.userId),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> userSnapshot) {
                  if (userSnapshot.hasData &&
                      userSnapshot.data!.docs.isNotEmpty) {
                    final List userData =
                        userSnapshot.data!.docs.map((e) => e.data()).toList();
                    final dataUser = userData[0];
                    final userName = dataUser['name'];
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        height: 300,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  userName,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: ExpandCaption(
                                    text: caption,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              uploadTime,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[500],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    return const Center(
                      child: Text('No user Data'),
                    );
                  }
                });
          } else {
            return const Center(
              child: Text('No data'),
            );
          }
        });
  }
}
