import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone_flutter/resources/auth_methods.dart';
import 'package:instagram_clone_flutter/resources/firestore_methods.dart';
import 'package:instagram_clone_flutter/screens/auth/login_screen.dart';
import 'package:instagram_clone_flutter/utils/colors.dart';
import 'package:instagram_clone_flutter/utils/utils.dart';
import 'package:instagram_clone_flutter/widgets/follow_button.dart';

import '../review_post.dart';
import 'edit_profile_page.dart';

class ProfileScreen extends StatefulWidget {
  final String uid;

  const ProfileScreen({Key? key, required this.uid}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  var userData = {};
  int postLen = 0;
  int followers = 0;
  List followersData = [];
  List followingData = [];
  int following = 0;
  bool isFollowing = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    setState(() {
      isLoading = true;
    });
    try {
      var userSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .get();

      // get post lENGTH
      var postSnap = await FirebaseFirestore.instance
          .collection('posts')
          .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .get();
      postLen = postSnap.docs.length;
      userData = userSnap.data()!;
      followers = userSnap.data()!['followers'].length;
      following = userSnap.data()!['following'].length;

      isFollowing = userSnap
          .data()!['followers']
          .contains(FirebaseAuth.instance.currentUser!.uid);
      setState(() {});
    } catch (e) {
      showSnackBar(
        context,
        e.toString(),
      );
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : DefaultTabController(
            length:
                FirebaseAuth.instance.currentUser!.uid == widget.uid ? 2 : 1,
            child: Scaffold(
              appBar: AppBar(
                backgroundColor: mobileBackgroundColor,
                elevation: 0,
                leading: FirebaseAuth.instance.currentUser!.uid != widget.uid
                    ? IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Color(0xfffab585),
                        ),
                      )
                    : Container(),
                title: Text(
                  userData['username'],
                  style: const TextStyle(
                      color: Colors.black, fontWeight: FontWeight.w900),
                ),
                centerTitle: true,
                actions: [
                  FirebaseAuth.instance.currentUser!.uid == widget.uid
                      ? IconButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => EditProfilePage(
                                          currentUser: FirebaseAuth
                                              .instance.currentUser!.uid,
                                          username: userData['username'],
                                          image: userData['photoUrl'],
                                          bio: userData['bio'],
                                          website: '',
                                        )));
                          },
                          icon: const Icon(
                            Icons.settings,
                            color: Color(0xfffab585),
                          ))
                      : Container()
                ],
              ),
              body: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.grey,
                          backgroundImage: NetworkImage(
                            userData['photoUrl'],
                          ),
                          radius: 40,
                        ),
                        Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.only(
                            bottom: 10,
                            top: 15,
                          ),
                          child: Text(
                            userData['username'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.only(
                            bottom: 15,
                            top: 5,
                          ),
                          child: Text(
                            userData['bio'],
                            style: const TextStyle(
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      buildStatColumn(postLen, "Posts"),
                                      buildStatColumn(followers, "Followers"),
                                      buildStatColumn(following, "Following"),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      FirebaseAuth.instance.currentUser!.uid ==
                                              widget.uid
                                          ? FollowButton(
                                              text: 'Sign Out',
                                              backgroundColor:
                                                  mobileBackgroundColor,
                                              textColor: primaryColor,
                                              borderColor: Colors.grey,
                                              function: () async {
                                                await AuthMethods().signOut();
                                                Navigator.of(context)
                                                    .pushReplacement(
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        const LoginScreen(),
                                                  ),
                                                );
                                              },
                                            )
                                          : isFollowing
                                              ? FollowButton(
                                                  text: 'Unfollow',
                                                  backgroundColor: Colors.white,
                                                  textColor: Colors.white,
                                                  borderColor: Colors.grey,
                                                  function: () async {
                                                    await FireStoreMethods()
                                                        .followUser(
                                                      FirebaseAuth.instance
                                                          .currentUser!.uid,
                                                      userData['uid'],
                                                    );

                                                    setState(() {
                                                      isFollowing = false;
                                                      followers--;
                                                    });
                                                  },
                                                )
                                              : FollowButton(
                                                  text: 'Follow',
                                                  backgroundColor: Colors.blue,
                                                  textColor: Colors.white,
                                                  borderColor: Colors.blue,
                                                  function: () async {
                                                    await FireStoreMethods()
                                                        .followUser(
                                                      FirebaseAuth.instance
                                                          .currentUser!.uid,
                                                      userData['uid'],
                                                    );

                                                    setState(() {
                                                      isFollowing = true;
                                                      followers++;
                                                    });
                                                  },
                                                )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  FirebaseAuth.instance.currentUser!.uid == widget.uid
                      ? const TabBar(
                          tabs: [
                            Tab(
                                icon: Icon(
                              Icons.grid_view_rounded,
                              color: Color(0xfffab585),
                            )),
                            Tab(
                                icon: Icon(
                              Icons.save,
                              color: Color(0xfffab585),
                            )),
                          ],
                        )
                      : const TabBar(
                          tabs: [
                            Tab(
                                icon: Icon(
                              Icons.grid_view_rounded,
                              color: Color(0xfffab585),
                            )),
                          ],
                        ),
                  Expanded(
                      child: FirebaseAuth.instance.currentUser!.uid ==
                              widget.uid
                          ? TabBarView(children: [
                              StreamBuilder(
                                stream: FirebaseFirestore.instance
                                    .collection('posts')
                                    .where('uid', isEqualTo: widget.uid)
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  } else {
                                    return GridView.builder(
                                      shrinkWrap: true,
                                      itemCount: (snapshot.data! as dynamic)
                                          .docs
                                          .length,
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 3,
                                        crossAxisSpacing: 5,
                                        mainAxisSpacing: 1.5,
                                        childAspectRatio: 1,
                                      ),
                                      itemBuilder: (context, index) {
                                        DocumentSnapshot snap =
                                            (snapshot.data! as dynamic)
                                                .docs[index];
                                        return InkWell(
                                          onTap: () =>
                                              Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) => ReviewPost(
                                                data:
                                                    (snapshot.data! as dynamic)
                                                        .docs[index],
                                              ),
                                            ),
                                          ),
                                          child: Image(
                                            image:
                                                NetworkImage(snap['postUrl']),
                                            fit: BoxFit.cover,
                                          ),
                                        );
                                      },
                                    );
                                  }
                                },
                              ),
                              StreamBuilder(
                                  stream: FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(FirebaseAuth
                                          .instance.currentUser!.uid)
                                      .collection('saved')
                                      .snapshots(),
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData) {
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    } else {
                                      List data = snapshot.data!.docs;
                                      return GridView.builder(
                                        shrinkWrap: true,
                                        itemCount: data.length,
                                        gridDelegate:
                                            const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 3,
                                          crossAxisSpacing: 5,
                                          mainAxisSpacing: 1.5,
                                          childAspectRatio: 1,
                                        ),
                                        itemBuilder: (context, index1) {
                                          return StreamBuilder(
                                            stream: FirebaseFirestore.instance
                                                .collection('posts')
                                                .doc(data[index1]['postId'])
                                                .snapshots(),
                                            builder: (context,
                                                AsyncSnapshot<DocumentSnapshot>
                                                    snapshot) {
                                              if (snapshot.connectionState ==
                                                  ConnectionState.waiting) {
                                                // Data is still loading
                                                return const Center(
                                                  child:
                                                      CircularProgressIndicator(),
                                                );
                                              } else if (snapshot.hasError) {
                                                // An error occurred while fetching the data
                                                return const Text(
                                                    'Error occurred while loading data');
                                              } else if (snapshot.hasData) {
                                                var postData = snapshot.data;
                                                if (postData!.exists) {
                                                  return InkWell(
                                                    onTap: () =>
                                                        Navigator.of(context)
                                                            .push(
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            ReviewPost(
                                                          data: data[index1],
                                                        ),
                                                      ),
                                                    ),
                                                    child: Image(
                                                      image: NetworkImage(
                                                          postData['postUrl']),
                                                      fit: BoxFit.cover,
                                                    ),
                                                  );
                                                } else {
                                                  // Document does not exist in Firestore
                                                  return InkWell(
                                                    onTap: () async {
                                                      showDialog(
                                                        useRootNavigator: false,
                                                        context: context,
                                                        builder: (context) {
                                                          return Dialog(
                                                            child: ListView(
                                                                padding: const EdgeInsets
                                                                        .symmetric(
                                                                    vertical:
                                                                        16),
                                                                shrinkWrap:
                                                                    true,
                                                                children: [
                                                                  'Delete',
                                                                ]
                                                                    .map(
                                                                      (e) => InkWell(
                                                                          child: Container(
                                                                            padding:
                                                                                const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                                                            child:
                                                                                Text(e),
                                                                          ),
                                                                          onTap: () async {
                                                                            print(data[index1]['postId']);
                                                                            await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).collection('saved').doc(data[index1]['postId']).delete().then((value) {
                                                                              Navigator.of(context).pop();
                                                                            });
                                                                          }),
                                                                    )
                                                                    .toList()),
                                                          );
                                                        },
                                                      );
                                                    },
                                                    child: const Center(
                                                      child: Text(
                                                        'Not Found',
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w800,
                                                            color: Colors.grey),
                                                      ),
                                                    ),
                                                  );
                                                }
                                              } else {
                                                // No data available
                                                return const Text(
                                                    'No data available');
                                              }
                                            },
                                          );
                                        },
                                      );
                                    }
                                  })
                            ])
                          : TabBarView(children: [
                              FutureBuilder(
                                future: FirebaseFirestore.instance
                                    .collection('posts')
                                    .where('uid', isEqualTo: widget.uid)
                                    .get(),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  } else {
                                    return GridView.builder(
                                      shrinkWrap: true,
                                      itemCount: (snapshot.data! as dynamic)
                                          .docs
                                          .length,
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 3,
                                        crossAxisSpacing: 5,
                                        mainAxisSpacing: 1.5,
                                        childAspectRatio: 1,
                                      ),
                                      itemBuilder: (context, index) {
                                        DocumentSnapshot snap =
                                            (snapshot.data! as dynamic)
                                                .docs[index];
                                        return InkWell(
                                          onTap: () =>
                                              Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) => ReviewPost(
                                                data:
                                                    (snapshot.data! as dynamic)
                                                        .docs[index],
                                              ),
                                            ),
                                          ),
                                          child: Image(
                                            image:
                                                NetworkImage(snap['postUrl']),
                                            fit: BoxFit.cover,
                                          ),
                                        );
                                      },
                                    );
                                  }
                                },
                              ),
                            ])),
                ],
              ),
            ),
          );
  }

  Column buildStatColumn(int num, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 4),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ),
        Text(
          num.toString(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
