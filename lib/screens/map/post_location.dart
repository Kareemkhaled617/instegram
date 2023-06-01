import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:instagram_clone_flutter/screens/map/shape.dart';
import 'package:latlong2/latlong.dart';
import 'package:lottie/lottie.dart' as lo;
import 'package:provider/provider.dart';

import '../../providers/map_provider.dart';

class ServicesLocation extends StatefulWidget {
  const ServicesLocation(
      {Key? key, required this.late, required this.long, required this.image})
      : super(key: key);
  final double late;
  final double long;
  final String image;

  @override
  State<ServicesLocation> createState() => _ServicesLocationState();
}

class _ServicesLocationState extends State<ServicesLocation>
    with TickerProviderStateMixin {
  MapController mapController = MapController();

  Timer? timer;

  late AnimationController _controller;

  @override
  void initState() {
    mapController = MapController();
    super.initState();
    _controller = AnimationController(
      vsync: this,
      lowerBound: 0.5,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    timer?.cancel();
    mapController.dispose();
    super.dispose();
  }

  void _animatedMapMove(LatLng destLocation, double destZoom) {
    final latTween = Tween<double>(
        begin: mapController.center.latitude, end: destLocation.latitude);
    final lngTween = Tween<double>(
        begin: mapController.center.longitude, end: destLocation.longitude);
    final zoomTween = Tween<double>(begin: mapController.zoom, end: destZoom);

    final controller = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);

    final Animation<double> animation =
        CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn);

    controller.addListener(() {
      mapController.move(
          LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
          zoomTween.evaluate(animation));
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.dispose();
      } else if (status == AnimationStatus.dismissed) {
        controller.dispose();
      }
    });

    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    var x = Provider.of<ProviderController>(context);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          centerTitle: true,
          title: const Text("Services "),
          elevation: 0,
        ),
        body: Stack(
          children: [
            FutureBuilder(
                future: x.getCurrentLocation(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return FlutterMap(
                      key: ValueKey(MediaQuery.of(context).orientation),
                      options: MapOptions(
                        controller: mapController,
                        onMapCreated: (c) {
                          mapController = c;
                        },
                        maxZoom: 22,
                        minZoom: 3,
                        zoom: 8,
                        onPositionChanged: (center, val) {},
                        plugins: [
                          MarkerClusterPlugin(),
                          const LocationMarkerPlugin(),
                        ],
                        center: LatLng(x.lat!, x.long!),
                      ),
                      layers: [
                        TileLayerOptions(
                          urlTemplate:
                              "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                          subdomains: ['a', 'b', 'c'],
                        ),
                        MarkerLayerOptions(markers: [
                          Marker(
                              width: 50,
                              height: 50,
                              point: LatLng(widget.late, widget.long),
                              builder: (BuildContext context) => InkWell(
                                    onTap: () {},
                                    child: ClipPath(
                                      clipper: HexagonClipper(),
                                      child: Container(
                                        width: 300,
                                        height: 260,
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: NetworkImage(widget.image),
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )),
                          Marker(
                            width: 100,
                            height: 100,
                            point: LatLng(x.lat!, x.long!),
                            builder: (ctx) => AnimatedBuilder(
                                animation: CurvedAnimation(
                                    parent: _controller,
                                    curve: Curves.fastOutSlowIn),
                                builder: (context, child) {
                                  return Stack(
                                    children: [
                                      Center(
                                        child: Container(
                                          width: 20,
                                          height: 20,
                                          decoration: BoxDecoration(
                                              color:
                                                  Colors.green.withOpacity(1),
                                              shape: BoxShape.circle),
                                        ),
                                      ),
                                      lo.Lottie.network(
                                          'https://assets4.lottiefiles.com/packages/lf20_bgmlsv9w.json')
                                    ],
                                  );
                                }),
                          ),
                        ]),
                      ],
                    );
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                }),
            Positioned(
                bottom: 40,
                right: 15,
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  color: Colors.white,
                  elevation: 2,
                  child: IconButton(
                    icon: const Icon(
                      Icons.my_location,
                      size: 26,
                      color: Colors.blue,
                    ),
                    onPressed: () {
                      // x.endValue(true);
                      x.getCurrentLocation().whenComplete(() {
                        _animatedMapMove(LatLng(x.lat!, x.long!), 13);
                        // mapController.move(LatLng(x.lat!, x.long!), 13);
                      });
                      // mapController.move(LatLng(lat, long), 13);
                    },
                  ),
                ))
          ],
        ),
      ),
    );
  }
}
