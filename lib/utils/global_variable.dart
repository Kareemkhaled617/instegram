import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone_flutter/screens/feed_page/add_post_screen.dart';
import 'package:instagram_clone_flutter/screens/feed_page/feed_screen.dart';
import 'package:instagram_clone_flutter/screens/profile/profile_screen.dart';
import 'package:instagram_clone_flutter/screens/search_screen.dart';

import '../screens/notification_page.dart';

const webScreenSize = 600;

List<Widget> homeScreenItems = [
  const FeedScreen(),
  const SearchScreen(),
  const AddPostScreen(),
  const NotificationPage(),
  ProfileScreen(
    uid: FirebaseAuth.instance.currentUser!.uid,
  ),
];
