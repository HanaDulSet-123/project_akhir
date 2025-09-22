import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tugas_ujk/api/absen_Service.dart';
import 'package:tugas_ujk/models/absen_checkin_model.dart';

class MapCheckInPage extends StatefulWidget {
  const MapCheckInPage({super.key});

  @override
  State<MapCheckInPage> createState() => _MapCheckInPageState();
}

class _MapCheckInPageState extends State<MapCheckInPage> {
  Map<String, dynamic>? _absenTodayData;
  GoogleMapController? _mapController;
  LatLng _currentPosition = const LatLng(-6.200000, 106.816666);
  Marker? _marker;
  String _currentAddress = "Mendapatkan lokasi...";

  final Color primaryColor = const Color(0xFF347338);
  final Color darkColor = const Color(0xFF11261A);

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _currentAddress = "Mencari lokasi...";
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _currentAddress = "Layanan lokasi tidak aktif");
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        setState(() => _currentAddress = "Izin lokasi ditolak");
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _marker = Marker(
          markerId: const MarkerId("lokasi_saya"),
          position: _currentPosition,
          infoWindow: const InfoWindow(title: "Lokasi Anda"),
        );
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          _currentAddress =
              "${place.name}, ${place.street}, ${place.locality}, ${place.country}";
        } else {
          _currentAddress = "Alamat tidak ditemukan";
        }
      });

      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(_currentPosition, 16),
      );
    } catch (e) {
      setState(() => _currentAddress = "Gagal mendapatkan lokasi: $e");
    }
  }

  Future<void> _absenToday() async {
    final response = await AbsenService.getAbsenToday();
    if (response != null && response.data != null) {
      setState(() {
        _absenTodayData = {
          "status": response.data!.status ?? "Belum Absen",
          "check_in": response.data!.checkInTime ?? "-",
          "check_out": response.data!.checkOutTime ?? "Belum Absen",
        };
      });
    } else {
      setState(() {
        _absenTodayData = {
          "status": "Belum Absen",
          "check_in": "-",
          "check_out": "Belum Absen",
        };
      });
    }
  }

  Future<void> _checkIn() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      String address = "Alamat tidak ditemukan";
      String locationName = "Lokasi Tidak Diketahui";
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        address =
            "${place.street}, ${place.subLocality}, ${place.locality}, ${place.administrativeArea}, ${place.country}";
        locationName = place.locality ?? "Lokasi Tidak Diketahui";
      }

      AbsenCheckIn? result = await AbsenService.checkIn(
        checkInLat: position.latitude,
        checkInLng: position.longitude,
        checkInLocation: locationName,
        checkInAddress: address,
      );

      if (!mounted) return;

      if (result != null) {
        await _absenToday();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Check-in berhasil: ${result.message}")),
        );
        Navigator.pop(context, true); // balik ke Dashboard dengan "true"
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Anda sudah melakukan absen hari ini")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Check In Lokasi",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // MAP
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _currentPosition,
                    zoom: 14,
                  ),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  markers: _marker != null ? {_marker!} : {},
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ADDRESS
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Icon(Icons.location_on, color: primaryColor, size: 28),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _currentAddress,
                        style: TextStyle(
                          fontSize: 15,
                          color: darkColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // CHECK IN BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 3,
                ),
                onPressed: _checkIn,
                icon: const Icon(Icons.login),
                label: const Text("Check In Sekarang"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
