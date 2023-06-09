import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'upload_services.dart';

class ServiceScreen extends StatelessWidget {
  const ServiceScreen({super.key, required this.postId});

  final String postId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: const Text(
          "Services ",
          style: TextStyle(color: Colors.black),
        ),
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xfffab585),
          ),
        ),
        actions: [
          IconButton(
              onPressed: () async {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => UploadServices(
                              postId: postId,
                            )));
              },
              icon: const Icon(
                Icons.add,
                color: Color(0xfffab585),
              ))
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .doc(postId)
            .collection('services')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List data = snapshot.data!.docs;
            return ListView.builder(
              itemCount: data.length,
              shrinkWrap: true,
              itemBuilder: (BuildContext context, int index) => Container(
                width: MediaQuery.of(context).size.width,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10.0, vertical: 7.0),
                child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    elevation: 5,
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(15),
                                topRight: Radius.circular(15),
                              ),
                              child: Image.network(
                                data[index]['postUrl'],
                                height: 250,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            )
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              InkWell(
                                child: Row(
                                  children: [
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    CircleAvatar(
                                      backgroundColor: Colors.white,
                                      backgroundImage: NetworkImage(
                                        data[index]['profImage'],
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Text(data[index]['username'],
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 15.0)),
                                  ],
                                ),
                              ),
                              StreamBuilder(
                                  stream: FirebaseFirestore.instance.collection('users').doc(data[index]['uid']).snapshots(),
                                  builder: (context,AsyncSnapshot snapshot){
                                if(snapshot.hasData){
                                  var data=snapshot.data ;
                                  return InkWell(
                                    onTap: () {
                                      launchUrl(Uri.parse('tel:/${data['phone']}'));
                                    },
                                    child: Row(
                                      children: const [
                                        Icon(Icons.done_all),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text("Order Now",
                                            style: TextStyle(
                                                color: Colors.blueAccent,
                                                fontSize: 15.0)),
                                      ],
                                    ),
                                  );
                                }else{
                                  return Container();
                                }
                              })
                            ],
                          ),
                        )
                      ],
                    )),
              ),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
