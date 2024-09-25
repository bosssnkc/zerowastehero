import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:custom_info_window/custom_info_window.dart';
import 'package:clippy_flutter/triangle.dart';
import 'package:zerowastehero/Routes/routes.dart';

class RecycleLocation extends StatefulWidget {
  const RecycleLocation({super.key});

  @override
  State<RecycleLocation> createState() => _RecycleLocationState();
}

class _RecycleLocationState extends State<RecycleLocation> {
  late GoogleMapController mapController;
  List _locations = [];
  final CustomInfoWindowController _customInfoWindowController =
      CustomInfoWindowController();
  Set<Marker> _markers = {};

  final LatLng _center = const LatLng(13.9018361, 100.6173027);
  Position? userLocation;

  @override
  void initState() {
    super.initState();
    _fetchLocations();
  }

  @override
  void dispose() {
    _customInfoWindowController.dispose();
    super.dispose();
  }

  Future<void> _fetchLocations() async {
    final response = await http.get(
      Uri.parse(getrecyclelocation),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'App-Source': appsource
      },
    );
    if (response.statusCode == 200) {
      final List locations = jsonDecode(response.body);
      setState(() {
        _locations = locations;
        _markers = locations.map((location) {
          return Marker(
            markerId: MarkerId(location['location_name']),
            position: LatLng(
              double.parse(location['location_lat']),
              double.parse(location['location_lon']),
            ),
            onTap: () {
              _customInfoWindowController.addInfoWindow!(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(2, 2),
                          )
                        ],
                      ),
                      width: 200,
                      height: 120,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                location['location_name'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                  'พิกัด: ${location['location_lat']}, ${location['location_lon']}'),
                              const SizedBox(height: 8),
                              Text('ที่อยู่: ${location['location_address']}')
                            ],
                          ),
                        ),
                      ),
                    ),
                    Triangle.isosceles(
                      edge: Edge.BOTTOM,
                      child: Container(
                        color: Colors.white,
                        width: 20.0,
                        height: 10.0,
                      ),
                    )
                  ],
                ),
                LatLng(double.parse(location['location_lat']),
                    double.parse(location['location_lon'])),
              );
            },
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
    _customInfoWindowController.googleMapController = controller;
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
                    child: const Text(
                      'ตกลง',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ))
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
                      child: ExpansionTile(
                        title: Text(recyclelocation['location_name']),
                        leading: const Icon(Icons.map),
                        subtitle: Text(
                            '${recyclelocation['location_lat']} ${recyclelocation['location_lon']}'),
                        children: [
                          ListTile(
                            title: Text(recyclelocation['location_name']),
                            subtitle:
                                recyclelocation['location_address'] != null
                                    ? Text(recyclelocation['location_address'])
                                    : const Text('Null'),
                          )
                        ],
                      ),
                    );
                  },
                ),
              ),
            ));
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
              icon: const Icon(Icons.list)),
        ],
        flexibleSpace: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [Colors.green, Colors.lightGreen.shade300],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight)),
        ),
        title: const Text(
          'สถานที่รับซื้อขยะรีไซเคิล',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
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
              const SizedBox(
                height: 24,
              ),
              const Center(
                child: Text(
                  'แผนที่',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: SizedBox(
                  height: 400,
                  width: MediaQuery.of(context).size.width,
                  child: Stack(
                    children: [
                      GoogleMap(
                        onMapCreated: _onMapCreated,
                        initialCameraPosition:
                            CameraPosition(target: _center, zoom: 12.0),
                        markers: _markers,
                        onTap: (position) {
                          _customInfoWindowController.hideInfoWindow!();
                        },
                        onCameraMove: (position) {
                          _customInfoWindowController.onCameraMove!();
                        },
                      ),
                      CustomInfoWindow(
                        controller: _customInfoWindowController,
                        height: 200,
                        width: 200,
                        offset: 0,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
