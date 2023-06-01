import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/map_provider.dart';
import '../utils/global_variable.dart';
import '../widgets/post_card.dart';

class ReviewPost extends StatefulWidget {
  const ReviewPost({Key? key, required this.data}) : super(key: key);
  final data;

  @override
  State<ReviewPost> createState() => _ReviewPostState();
}

class _ReviewPostState extends State<ReviewPost> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    var con = Provider.of<ProviderController>(context);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 50),
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('posts')
              .where('postId', isEqualTo: widget.data['postId'])
              .snapshots(),
          builder: (context,
              AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (ctx, index) => Container(
                margin: EdgeInsets.symmetric(
                  horizontal: width > webScreenSize ? width * 0.3 : 0,
                  vertical: width > webScreenSize ? 15 : 0,
                ),
                child: PostCard(
                  snap: snapshot.data!.docs[index].data(),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
