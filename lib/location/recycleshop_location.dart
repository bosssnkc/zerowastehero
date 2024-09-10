import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:zerowastehero/Routes/routes.dart';

class RecycleLocation extends StatefulWidget {
  const RecycleLocation({super.key});

  @override
  State<RecycleLocation> createState() => _RecycleLocationState();
}

class _RecycleLocationState extends State<RecycleLocation> {
  late GoogleMapController mapController;
  List _locations = [];

  Set<Marker> _markers = {};

  final LatLng _center = const LatLng(13.9018361, 100.6173027);
  Position? userLocation;

  @override
  void initState() {
    super.initState();
    // fetchRecyclingCenters(_center).then((markers) {
    //   setState(() {
    //     _markers.addAll(markers);
    //   });
    // });
    _fetchLocations();
  }

  Future<void> _getRecycleLocationList() async {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              actions: [
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('ตกลง',style: TextStyle(fontWeight: FontWeight.bold),))
              ],
              title: const Text('สถานที่'),
              content: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 400,
                child: ListView.builder(
                  physics: const ScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: _locations.length,
                  itemBuilder: (context, index) {
                    final recyclelocation = _locations[index];
                    return Card(
                      child: ListTile(
                        title: Text(recyclelocation['location_name']),
                        leading: const Icon(Icons.map),
                        subtitle: Text(
                            '${recyclelocation['location_lat']} ${recyclelocation['location_lon']}'),
                      ),
                    );
                  },
                ),
              ),
            ));
  }

  Future<void> _fetchLocations() async {
    final response = await http.get(Uri.parse(getrecyclelocation));
    if (response.statusCode == 200) {
      final List locations = jsonDecode(response.body);
      setState(() {
        _locations = locations;
        _markers = locations.map((location) {
          return Marker(
            markerId: MarkerId(location['location_name']),
            position: LatLng(double.parse(location['location_lat']),
                double.parse(location['location_lon'])),
            infoWindow: InfoWindow(
              title: location['location_name'],
            ),
          );
        }).toSet();
      });
    } else {
      throw Exception('Failed to load locations');
    }
  }

  Future<void> _getLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Handle location services disabled
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Handle permission denied
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Handle permission denied permanently
      return;
    }

    final position = await Geolocator.getCurrentPosition();
    setState(() {
      userLocation = position;
    });

    mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(userLocation!.latitude, userLocation!.longitude),
        zoom: 15.0)));
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                _getRecycleLocationList();
              },
              icon: Icon(Icons.list))
        ],
        flexibleSpace: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [Colors.green, Colors.lightGreen.shade300],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight)),
        ),
        elevation: 0,
        backgroundColor: Colors.green[300],
        title: const Text(
          'สถานที่รับซื้อขยะรีไซเคิล',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 64, 16, 16),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 50,
                        ),
                        const SizedBox(
                          width: 50,
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'ตำแหน่งปัจจุบันของคุณ',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              userLocation != null
                                  ? Text(
                                      'Lat: ${userLocation!.latitude} Lon: ${userLocation!.longitude}')
                                  : const Text('ไม่พบตำแหน่งปัจจุบัน'),
                              const SizedBox(height: 10),
                              ElevatedButton(
                                  onPressed: _getLocation,
                                  child: const Text('Get Location'))
                            ],
                          ),
                        ), //Column inside location_now
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Center(
                  child: Text(
                    'แผนที่',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  child: SizedBox(
                    height: 300,
                    child: Center(
                      child: GoogleMap(
                          onMapCreated: _onMapCreated,
                          initialCameraPosition:
                              CameraPosition(target: _center, zoom: 11.0),
                          markers: userLocation != null
                              ? {
                                  Marker(
                                    markerId: const MarkerId('userLocation'),
                                    position: LatLng(
                                      userLocation!.latitude,
                                      userLocation!.longitude,
                                    ),
                                    infoWindow: const InfoWindow(
                                      title: 'ตำแหน่งปัจจุบันของคุณ',
                                    ),
                                  )
                                }
                              : _markers //Text('{location_recycleshop}'),
                          ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
