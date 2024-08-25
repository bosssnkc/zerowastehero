import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RecycleLocation extends StatefulWidget {
  const RecycleLocation({super.key});

  @override
  State<RecycleLocation> createState() => _recycleLocationState();
}

class _recycleLocationState extends State<RecycleLocation> {
  late GoogleMapController mapController;

  final LatLng _center = const LatLng(13.736717, 100.523186);
  Position? userLocation;

  // @override
  // void initState() {
  //   super.initState();
  //   _getLocation();
  // }

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
      backgroundColor: Colors.green[50],
      appBar: AppBar(
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
          padding: EdgeInsets.fromLTRB(16, 64, 16, 16),
          child: Column(
            children: [
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
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
                                : Text('ไม่พบตำแหน่งปัจจุบัน'),
                            const SizedBox(height: 10),
                            ElevatedButton(
                                onPressed: _getLocation,
                                child: Text('Get Location'))
                          ],
                        ),
                      ), //Column inside location_now
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24),
              Center(
                child: Text(
                  'แผนที่',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 8),
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
                                    markerId: MarkerId('userLocation'),
                                    position: LatLng(
                                      userLocation!.latitude,
                                      userLocation!.longitude,
                                    ),
                                    infoWindow: InfoWindow(
                                      title: 'ตำนแห่งปัจจุบันของคุณ',
                                    ),
                                  )
                                }
                              : {}) //Text('{location_recycleshop}'),
                      ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
