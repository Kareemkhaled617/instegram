import 'package:flutter/material.dart';

import '../../../utils/consts.dart';
import '../../../widgets/profile_widget.dart';

class ProfileMainWidget extends StatefulWidget {
  final currentUser;

  const ProfileMainWidget({Key? key, required this.currentUser})
      : super(key: key);

  @override
  State<ProfileMainWidget> createState() => _ProfileMainWidgetState();
}

class _ProfileMainWidgetState extends State<ProfileMainWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: backGroundColor,
        appBar: AppBar(
          backgroundColor: backGroundColor,
          title: Text(
            "${widget.currentUser.username}",
            style: const TextStyle(color: primaryColor),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: InkWell(
                  onTap: () {
                    _openBottomModalSheet(context);
                  },
                  child: const Icon(
                    Icons.menu,
                    color: primaryColor,
                  )),
            )
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(40),
                        child: profileWidget(
                            imageUrl: widget.currentUser.profileUrl),
                      ),
                    ),
                    Row(
                      children: [
                        Column(
                          children: [
                            Text(
                              "${widget.currentUser.totalPosts}",
                              style: const TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.bold),
                            ),
                            sizeVer(8),
                            const Text(
                              "Posts",
                              style: TextStyle(color: primaryColor),
                            )
                          ],
                        ),
                        sizeHor(25),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                                context, PageConst.followersPage,
                                arguments: widget.currentUser);
                          },
                          child: Column(
                            children: [
                              Text(
                                "${widget.currentUser.totalFollowers}",
                                style: const TextStyle(
                                    color: primaryColor,
                                    fontWeight: FontWeight.bold),
                              ),
                              sizeVer(8),
                              const Text(
                                "Followers",
                                style: TextStyle(color: primaryColor),
                              )
                            ],
                          ),
                        ),
                        sizeHor(25),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                                context, PageConst.followingPage,
                                arguments: widget.currentUser);
                          },
                          child: Column(
                            children: [
                              Text(
                                "${widget.currentUser.totalFollowing}",
                                style: const TextStyle(
                                    color: primaryColor,
                                    fontWeight: FontWeight.bold),
                              ),
                              sizeVer(8),
                              const Text(
                                "Following",
                                style: TextStyle(color: primaryColor),
                              )
                            ],
                          ),
                        )
                      ],
                    )
                  ],
                ),
                sizeVer(10),
                Text(
                  "${widget.currentUser.name == "" ? widget.currentUser.username : widget.currentUser.name}",
                  style: const TextStyle(
                      color: primaryColor, fontWeight: FontWeight.bold),
                ),
                sizeVer(10),
                Text(
                  "${widget.currentUser.bio}",
                  style: const TextStyle(color: primaryColor),
                ),
                sizeVer(10),
                GridView.builder(
                    itemCount: 1,
                    physics: const ScrollPhysics(),
                    shrinkWrap: true,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 5,
                            mainAxisSpacing: 5),
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          // Navigator.pushNamed(context, PageConst.postDetailPage, arguments: posts[index].postId);
                        },
                        child: SizedBox(
                          width: 100,
                          height: 100,
                          child: profileWidget(imageUrl: ''),
                        ),
                      );
                    }),
              ],
            ),
          ),
        ));
  }

  _openBottomModalSheet(BuildContext context) {
    return showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            height: 150,
            decoration: BoxDecoration(color: backGroundColor.withOpacity(.8)),
            child: SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 10.0),
                      child: Text(
                        "More Options",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: primaryColor),
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    const Divider(
                      thickness: 1,
                      color: secondaryColor,
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                              context, PageConst.editProfilePage,
                              arguments: widget.currentUser);
                          // Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfilePage()));
                        },
                        child: const Text(
                          "Edit Profile",
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              color: primaryColor),
                        ),
                      ),
                    ),
                    sizeVer(7),
                    const Divider(
                      thickness: 1,
                      color: secondaryColor,
                    ),
                    sizeVer(7),
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: InkWell(
                        onTap: () {
                          Navigator.pushNamedAndRemoveUntil(
                              context, PageConst.signInPage, (route) => false);
                        },
                        child: const Text(
                          "Logout",
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              color: primaryColor),
                        ),
                      ),
                    ),
                    sizeVer(7),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
