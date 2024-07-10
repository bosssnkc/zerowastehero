import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapsPage extends StatefulWidget {
    @override
    _MapsPageState createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
    late Position userLocation;
    late GoogleMapController mapController;

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
    }

    @override
    Widget build(BuildContext context) {
        // Build your UI here, including the Google Map widget
        return Scaffold(
            appBar: AppBar(title: Text('Google Maps Example')),
            body: Center(
                child: ElevatedButton(
                    onPressed: _getLocation,
                    child: Text('Get Current Location'),
                ),
            ),
        );
    }
}
