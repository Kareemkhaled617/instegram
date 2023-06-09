import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../screens/feed_page/blocked_screen.dart';
import '../utils/colors.dart';
import '../utils/global_variable.dart';

class MobileScreenLayout extends StatefulWidget {
  const MobileScreenLayout({Key? key}) : super(key: key);

  @override
  State<MobileScreenLayout> createState() => _MobileScreenLayoutState();
}

class _MobileScreenLayoutState extends State<MobileScreenLayout> {
  int _page = 0;
  late PageController pageController; // for tabs animation

  @override
  void initState() {
    super.initState();
    pageController = PageController();
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }

  void onPageChanged(int page) {
    setState(() {
      _page = page;
    });
  }

  void navigationTapped(int page) {
    //Animating Page
    pageController.jumpToPage(page);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .snapshots(),
        builder: (context,AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            var data = snapshot.data! ;
            if (data['isAccept']) {
              return Scaffold(
                body: PageView(
                  children: homeScreenItems,
                  controller: pageController,
                  onPageChanged: onPageChanged,
                ),
                bottomNavigationBar: CupertinoTabBar(
                  backgroundColor: Colors.transparent,
                  items: <BottomNavigationBarItem>[
                    BottomNavigationBarItem(
                      icon: Icon(
                        Icons.home,
                        color: (_page == 0) ?  const Color(0xfffab585) : secondaryColor,
                      ),
                      label: '',
                      backgroundColor: primaryColor,
                    ),
                    BottomNavigationBarItem(
                        icon: Icon(
                          Icons.search,
                          color: (_page == 1) ? const Color(0xfffab585) : secondaryColor,
                        ),
                        label: '',
                        backgroundColor: primaryColor),
                    BottomNavigationBarItem(
                        icon: Icon(
                          Icons.add_circle,
                          color: (_page == 2) ? const Color(0xfffab585) : secondaryColor,
                        ),
                        label: '',
                        backgroundColor: primaryColor),
                    BottomNavigationBarItem(
                      icon: Icon(
                        Icons.favorite,
                        color: (_page == 3) ? const Color(0xfffab585) : secondaryColor,
                      ),
                      label: '',
                      backgroundColor: primaryColor,
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(
                        Icons.person,
                        color: (_page == 4) ? const Color(0xfffab585) : secondaryColor,
                      ),
                      label: '',
                      backgroundColor: primaryColor,
                    ),
                  ],
                  onTap: navigationTapped,
                  currentIndex: _page,
                ),
              );
            } else {
              return const BlockedScreen();
            }
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        });
  }
}
