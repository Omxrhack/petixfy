import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:petixfy/services/tracking_service.dart';
import 'package:petixfy/widgets/vet_warm_theme.dart';

class VetActiveRouteScreen extends StatefulWidget {
  const VetActiveRouteScreen({
    super.key,
    required this.trackingId,
    this.patientName = 'Luna',
    this.ownerName = 'Familia Perez',
    this.clientLocation = const LatLng(19.4326, -99.1332),
  });

  final String trackingId;
  final String patientName;
  final String ownerName;
  final LatLng clientLocation;

  @override
  State<VetActiveRouteScreen> createState() => _VetActiveRouteScreenState();
}

class _VetActiveRouteScreenState extends State<VetActiveRouteScreen> {
  final TrackingService _trackingService = TrackingService();
  GoogleMapController? _mapController;
  StreamSubscription<Position>? _positionSubscription;
  String? _mapStyle;

  Position? _currentPosition;
  bool _isSending = false;
  String? _sendError;

  @override
  void initState() {
    super.initState();
    _loadMapStyle();
    _startLocationStream();
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _loadMapStyle() async {
    final raw = await rootBundle.loadString('assets/map_styles/warm_map_style.json');
    if (!mounted) return;
    setState(() => _mapStyle = raw);
  }

  Future<void> _startLocationStream() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => _sendError = 'Activa tu GPS para compartir ubicacion.');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      setState(() => _sendError = 'Permiso de ubicacion denegado.');
      return;
    }

    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 8,
    );

    _positionSubscription = Geolocator.getPositionStream(locationSettings: locationSettings).listen(
      (position) async {
        setState(() {
          _currentPosition = position;
          _sendError = null;
        });

        final eta = _estimateEtaMinutes(position);
        await _sendLocationToBackend(position: position, etaMinutes: eta);

        await _mapController?.animateCamera(
          CameraUpdate.newLatLng(LatLng(position.latitude, position.longitude)),
        );
      },
      onError: (_) {
        if (!mounted) return;
        setState(() => _sendError = 'No se pudo leer la ubicacion en tiempo real.');
      },
    );
  }

  int _estimateEtaMinutes(Position position) {
    final meters = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      widget.clientLocation.latitude,
      widget.clientLocation.longitude,
    );
    final km = meters / 1000;
    final hours = km / 25; // Average city route speed
    final minutes = (hours * 60).round();
    return minutes < 1 ? 1 : minutes;
  }

  Future<void> _sendLocationToBackend({
    required Position position,
    required int etaMinutes,
  }) async {
    if (_isSending) return;
    _isSending = true;
    try {
      await _trackingService.patchVetLocation(
        trackingId: widget.trackingId,
        latitude: position.latitude,
        longitude: position.longitude,
        etaMinutes: etaMinutes,
      );
    } catch (e) {
      if (mounted) {
        setState(() => _sendError = 'Error enviando ubicacion: $e');
      }
    } finally {
      _isSending = false;
    }
  }

  Set<Marker> _buildMarkers() {
    final markers = <Marker>{
      Marker(
        markerId: const MarkerId('client-home'),
        position: widget.clientLocation,
        infoWindow: const InfoWindow(title: 'Domicilio del cliente'),
      ),
    };

    if (_currentPosition != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('vet-live'),
          position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          infoWindow: const InfoWindow(title: 'Veterinario'),
          rotation: _currentPosition!.heading,
        ),
      );
    }
    return markers;
  }

  @override
  Widget build(BuildContext context) {
    final initialLocation = _currentPosition == null
        ? widget.clientLocation
        : LatLng(_currentPosition!.latitude, _currentPosition!.longitude);

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(target: initialLocation, zoom: 15.5),
            style: _mapStyle,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            markers: _buildMarkers(),
            onMapCreated: (controller) async {
              _mapController = controller;
            },
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: VetWarmTheme.softCardDecoration(color: VetWarmTheme.card),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Paciente: ${widget.patientName}',
                    style: const TextStyle(
                      color: VetWarmTheme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Tutor: ${widget.ownerName}',
                    style: const TextStyle(color: VetWarmTheme.textSecondary),
                  ),
                  if (_sendError != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _sendError!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 52),
                        backgroundColor: VetWarmTheme.amber,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: const Text('Llegue al domicilio'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
