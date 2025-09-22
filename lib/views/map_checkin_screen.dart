import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
// Ganti dengan path project Anda yang benar
import 'package:tugas_ujk/api/absen_Service.dart';
import 'package:tugas_ujk/models/absen_checkin_model.dart';
import 'package:tugas_ujk/models/absen_checkout_model.dart';

class MapCheckInPage extends StatefulWidget {
  const MapCheckInPage({super.key});

  @override
  State<MapCheckInPage> createState() => _MapCheckInPageState();
}

class _MapCheckInPageState extends State<MapCheckInPage> {
  Map<String, dynamic>? _absenTodayData;
  GoogleMapController? _mapController;
  LatLng _currentPosition = const LatLng(
    -6.200000,
    106.816666,
  ); // Default Jakarta
  Marker? _marker;
  String _currentAddress = "Mendapatkan lokasi...";
  bool _isLoading = true;

  // Palet Warna Sesuai Dashboard
  final Color _backgroundColor = const Color(0xFFF8F9FD);
  final Color _primaryBlue = const Color(0xFF3E8DE8);
  final Color _darkTextColor = const Color(0xFF2D3035);
  final Color _lightTextColor = Colors.grey.shade600;

  @override
  void initState() {
    super.initState();
    _initializePage();
  }

  Future<void> _initializePage() async {
    await _absenToday();
    await _getCurrentLocation();
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _currentAddress = "Mencari lokasi...");
    try {
      Position position = await _determinePosition();
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (mounted) {
        setState(() {
          _currentPosition = LatLng(position.latitude, position.longitude);
          _marker = Marker(
            markerId: const MarkerId("lokasi_saya"),
            position: _currentPosition,
            infoWindow: const InfoWindow(title: "Lokasi Anda Saat Ini"),
          );
          _currentAddress = _formatAddress(placemarks.first);
        });
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(_currentPosition, 16),
        );
      }
    } catch (e) {
      if (mounted) setState(() => _currentAddress = e.toString());
    }
  }

  String _formatAddress(Placemark place) {
    return "${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}";
  }

  Future<void> _absenToday() async {
    final response = await AbsenService.getAbsenToday();
    if (mounted) {
      setState(() {
        if (response != null && response.data != null) {
          _absenTodayData = {
            "check_in": response.data!.checkInTime ?? "--:--",
            "check_out": response.data!.checkOutTime ?? "--:--",
          };
        } else {
          _absenTodayData = {"check_in": "--:--", "check_out": "--:--"};
        }
      });
    }
  }

  Future<void> _performCheckIn() async {
    try {
      AbsenCheckIn? result = await AbsenService.checkIn(
        checkInLat: _currentPosition.latitude,
        checkInLng: _currentPosition.longitude,
        checkInLocation:
            (await placemarkFromCoordinates(
              _currentPosition.latitude,
              _currentPosition.longitude,
            )).first.locality ??
            "N/A",
        checkInAddress: _currentAddress,
      );

      if (!mounted) return;

      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Check-in berhasil: ${result.message}"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Anda sudah melakukan absen hari ini"),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _performCheckOut() async {
    try {
      AbsenCheckOut? result = await AbsenService.checkOut(
        checkOutLat: _currentPosition.latitude,
        checkOutLng: _currentPosition.longitude,
        checkOutLocation:
            (await placemarkFromCoordinates(
              _currentPosition.latitude,
              _currentPosition.longitude,
            )).first.locality ??
            "N/A",
        checkOutAddress: _currentAddress,
      );

      if (!mounted) return;

      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Check-out berhasil: ${result.message}"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Gagal melakukan check-out"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: const Text(
          "Lokasi Absen",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: _backgroundColor,
        foregroundColor: _darkTextColor,
        elevation: 0,
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentPosition,
              zoom: 14,
            ),
            myLocationEnabled: false,
            myLocationButtonEnabled: false,
            markers: _marker != null ? {_marker!} : {},
            onMapCreated: (controller) {
              _mapController = controller;
            },
          ),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
          _buildInfoPanel(),
        ],
      ),
    );
  }

  Widget _buildInfoPanel() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: const EdgeInsets.all(20).copyWith(bottom: 30),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Lokasi Anda Saat Ini",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _darkTextColor,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.location_on, color: _primaryBlue, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _currentAddress,
                    style: TextStyle(fontSize: 15, color: _lightTextColor),
                  ),
                ),
                IconButton(
                  onPressed: _getCurrentLocation,
                  icon: const Icon(Icons.refresh),
                  color: _primaryBlue,
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildActionButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    if (_absenTodayData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final bool hasCheckedIn = _absenTodayData!['check_in'] != "--:--";
    final bool hasCheckedOut = _absenTodayData!['check_out'] != "--:--";

    String buttonText = "Check In Sekarang";
    VoidCallback? onPressedAction = _performCheckIn;
    Color buttonColor = _primaryBlue;
    IconData icon = Icons.login;

    if (hasCheckedIn && !hasCheckedOut) {
      buttonText = "Check Out Sekarang";
      onPressedAction = _performCheckOut;
      buttonColor = Colors.orange;
      icon = Icons.logout;
    } else if (hasCheckedIn && hasCheckedOut) {
      buttonText = "Absensi Hari Ini Selesai";
      onPressedAction = null; // Tombol nonaktif
      buttonColor = Colors.grey;
      icon = Icons.check_circle;
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 3,
        ),
        onPressed: onPressedAction,
        icon: Icon(icon),
        label: Text(buttonText),
      ),
    );
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Layanan lokasi tidak aktif.');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Izin lokasi ditolak.');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'Izin lokasi ditolak permanen, buka pengaturan untuk mengaktifkan.',
      );
    }
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }
}
