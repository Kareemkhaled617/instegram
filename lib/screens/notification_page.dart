import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:instagram_clone_flutter/screens/profile/profile_screen.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          title: const Text(
            "Activity",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          centerTitle: false,
        ),
        body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .collection('notification')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List data = snapshot.data!.docs;
              return ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    return Slidable(
                      actionPane: const SlidableDrawerActionPane(),
                      actionExtentRatio: 0.25,
                      child: notificationItem(data[index]),
                      secondaryActions: <Widget>[
                        Container(
                            height: 60,
                            color: Colors.grey.shade500,
                            child: const Icon(
                              Icons.info_outline,
                              color: Colors.black,
                            )),
                        Container(
                            height: 60,
                            color: Colors.red,
                            child: const Icon(
                              Icons.delete_outline_sharp,
                              color: Colors.black,
                            )),
                      ],
                    );
                  });
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ));
  }

  notificationItem(notification) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                InkWell(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ProfileScreen(
                        uid: notification['uid'],
                      ),
                    ),
                  ),
                  child: Container(
                    width: 50,
                    height: 50,
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                        gradient: LinearGradient(
                            colors: [Colors.red, Colors.orangeAccent],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomLeft),
                        // border: Border.all(color: Colors.red),
                        shape: BoxShape.circle),
                    child: Container(
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border:
                              Border.all(color: Colors.redAccent, width: 3)),
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Image.network(notification['image'])),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Flexible(
                  child: RichText(
                      text: TextSpan(children: [
                    TextSpan(
                        text: notification['name'],
                        style: const TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold)),
                    TextSpan(
                        text: '  ${notification['message']}',
                        style: const TextStyle(color: Colors.black)),
                  ])),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class InstagramNotification {
  final String name;
  final String profilePic;
  final String content;
  final String postImage;
  final String timeAgo;
  final bool hasStory;

  InstagramNotification(this.name, this.profilePic, this.content,
      this.postImage, this.timeAgo, this.hasStory);

  factory InstagramNotification.fromJson(Map<String, dynamic> json) {
    return InstagramNotification(json['name'], json['profilePic'],
        json['content'], json['postImage'], json['timeAgo'], json['hasStory']);
  }
}
