import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';
import 'package:lottie/lottie.dart' as lo;
import 'package:provider/provider.dart';

import '../../providers/map_provider.dart';
import '../../utils/custom_shape.dart';

class MapPage extends StatefulWidget {
  MapPage({Key? key}) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> with TickerProviderStateMixin {
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
        body: Stack(
          children: [
            FutureBuilder(
                future: x.getDataLocation(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    List data = snapshot.data as List;
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
                        // center: LatLng(30.635478259074432, 31.0902948107),
                        // interactiveFlags: InteractiveFlag.drag |
                        //     InteractiveFlag.pinchMove |
                        //     InteractiveFlag.pinchZoom
                      ),
                      layers: [
                        TileLayerOptions(
                          urlTemplate:
                              "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                          subdomains: ['a', 'b', 'c'],
                        ),
                        MarkerLayerOptions(markers: [
                          ...data.map((e) => Marker(
                              width: 50,
                              height: 50,
                              point: LatLng(double.parse('${e['late']}'),
                                  double.parse('${e['long']}')),
                              builder: (BuildContext context) => InkWell(
                                    onTap: () {},
                                    child: Stack(
                                      children: [
                                        CustomPaint(
                                          size: const Size(180, 110),
                                          painter: RPSCustomPainter(
                                              color: Colors.redAccent),
                                        ),
                                        const Positioned(
                                          right: 11,
                                          top: 5,
                                          child: Icon(
                                            Icons.local_hospital,
                                            color: Colors.white,
                                            size: 27.0,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ))),
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
                    return const CircularProgressIndicator();
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
