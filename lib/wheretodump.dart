import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:zerowastehero/testlocator.dart';

class recycleLocation extends StatefulWidget {
  const recycleLocation({super.key});

  @override
  State<recycleLocation> createState() => _recycleLocationState();
}

class _recycleLocationState extends State<recycleLocation> {
  late GoogleMapController mapController;

  final LatLng _center = const LatLng(13.736717, 100.523186);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
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
                      Icon(
                        Icons.location_on,
                        size: 50,
                      ),
                      SizedBox(
                        width: 50,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ตำแหน่งปัจจุบันของคุณ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 10),
                          Text('{location now}'),
                          ElevatedButton(onPressed: () => Navigator.push(context,MaterialPageRoute(builder: (context) => MapsPage())), child: Text('Now'))
                        ],
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
                          initialCameraPosition: CameraPosition(
                              target: _center,
                              zoom: 11.0)) //Text('{location_recycleshop}'),
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

class hazardousLocation extends StatefulWidget {
  const hazardousLocation({super.key});

  @override
  State<hazardousLocation> createState() => _hazardousLocationState();
}

class _hazardousLocationState extends State<hazardousLocation> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
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
          padding: EdgeInsets.fromLTRB(16, 64, 16, 16),
          child: Column(
            children: [
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 50,
                      ),
                      SizedBox(
                        width: 50,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ตำแหน่งปัจจุบันของคุณ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 10),
                          Text('{location now}')
                        ],
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
                      markers: {
                        const Marker(
                            markerId: MarkerId('thisLocation'),
                            icon: BitmapDescriptor.defaultMarker,
                            position: LatLng(13.736717, 100.523186),
                            infoWindow: InfoWindow(title: 'ร้านขายข้าว')),
                        const Marker(
                            markerId: MarkerId('test2'),
                            icon: BitmapDescriptor.defaultMarker,
                            position: LatLng(14.736717, 100.523186))
                      },
                      initialCameraPosition: const CameraPosition(
                          target: LatLng(13.736717, 100.523186), zoom: 11.0),
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
