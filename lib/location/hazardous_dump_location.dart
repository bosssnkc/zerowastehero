import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HazardousLocation extends StatefulWidget {
  const HazardousLocation({super.key});

  @override
  State<HazardousLocation> createState() => _HazardousLocationState();
}

class _HazardousLocationState extends State<HazardousLocation> {
  late GoogleMapController mapController;
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
          'สถานที่กำจัดขยะอันตราย',
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
                      markers: {
                        userLocation != null
                            ? Marker(
                                markerId: const MarkerId('userLocation'),
                                position: LatLng(
                                  userLocation!.latitude,
                                  userLocation!.longitude,
                                ),
                                infoWindow: const InfoWindow(
                                  title: 'ตำแหน่งปัจจุบันของคุณ',
                                ),
                              )
                            : const Marker(
                                markerId: MarkerId('thisLocation'),
                                icon: BitmapDescriptor.defaultMarker,
                                position: LatLng(13.736717, 100.523186),
                                infoWindow: InfoWindow(title: 'ร้านขายข้าว')),
                        const Marker(
                            markerId: MarkerId('test2'),
                            icon: BitmapDescriptor.defaultMarker,
                            position: LatLng(14.736717, 100.523186))
                      },
                      initialCameraPosition: CameraPosition(
                          target: userLocation != null
                              ? LatLng(
                                  userLocation!.latitude,
                                  userLocation!.longitude,
                                )
                              : const LatLng(13.736717, 100.523186),
                          // target: LatLng(
                          //   userLocation!.latitude,
                          //   userLocation!.longitude,
                          // ),
                          // target: LatLng(13.736717, 100.523186),
                          zoom: 11.0),
                    ),
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
