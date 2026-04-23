import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:petixfy/services/tracking_service.dart';
import 'package:petixfy/widgets/vet_warm_theme.dart';

class ClientTrackingScreen extends StatefulWidget {
  const ClientTrackingScreen({
    super.key,
    required this.trackingId,
    this.doctorName = 'Omar',
    this.clientLocation = const LatLng(19.4326, -99.1332),
  });

  final String trackingId;
  final String doctorName;
  final LatLng clientLocation;

  @override
  State<ClientTrackingScreen> createState() => _ClientTrackingScreenState();
}

class _ClientTrackingScreenState extends State<ClientTrackingScreen> {
  final TrackingService _trackingService = TrackingService();

  GoogleMapController? _mapController;
  Timer? _pollingTimer;
  Timer? _interpolationTimer;

  String? _mapStyle;
  BitmapDescriptor _homeIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose);
  BitmapDescriptor _vetIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);

  LatLng? _vetPosition;
  int _etaMinutes = 0;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMapStyle();
    _loadMarkerIcons();
    _refreshTracking();
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) => _refreshTracking());
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _interpolationTimer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _loadMapStyle() async {
    final raw = await rootBundle.loadString('assets/map_styles/warm_map_style.json');
    if (!mounted) return;
    setState(() => _mapStyle = raw);
  }

  Future<void> _loadMarkerIcons() async {
    try {
      final home = await BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(48, 48)),
        'assets/home_pin.png',
      );
      final vet = await BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(48, 48)),
        'assets/vet_car_pin.png',
      );
      if (!mounted) return;
      setState(() {
        _homeIcon = home;
        _vetIcon = vet;
      });
    } catch (_) {
      // Keep warm-colored fallback markers if custom assets are missing.
    }
  }

  Future<void> _refreshTracking() async {
    try {
      final data = await _trackingService.getTrackingSession(widget.trackingId);
      final vetLat = (data['vet_lat'] as num?)?.toDouble();
      final vetLng = (data['vet_lng'] as num?)?.toDouble();
      if (vetLat == null || vetLng == null) return;

      final newPosition = LatLng(vetLat, vetLng);
      if (_vetPosition == null) {
        setState(() => _vetPosition = newPosition);
      } else {
        _animateVetMarker(_vetPosition!, newPosition);
      }

      final distanceMeters = Geolocator.distanceBetween(
        newPosition.latitude,
        newPosition.longitude,
        widget.clientLocation.latitude,
        widget.clientLocation.longitude,
      );
      final computedEta = ((distanceMeters / 1000) / 25 * 60).round();
      setState(() {
        _etaMinutes = computedEta <= 0 ? 1 : computedEta;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'No se pudo actualizar tracking: $e');
    }
  }

  void _animateVetMarker(LatLng from, LatLng to) {
    _interpolationTimer?.cancel();
    const totalFrames = 12;
    var frame = 0;

    _interpolationTimer = Timer.periodic(const Duration(milliseconds: 80), (timer) {
      frame++;
      final t = frame / totalFrames;
      final lat = _lerp(from.latitude, to.latitude, t);
      final lng = _lerp(from.longitude, to.longitude, t);

      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        _vetPosition = LatLng(lat, lng);
      });

      if (frame >= totalFrames) {
        timer.cancel();
      }
    });
  }

  double _lerp(double a, double b, double t) => a + (b - a) * t.clamp(0, 1);

  Set<Marker> _buildMarkers() {
    final markers = <Marker>{
      Marker(
        markerId: const MarkerId('client-home'),
        position: widget.clientLocation,
        icon: _homeIcon,
        infoWindow: const InfoWindow(title: 'Tu domicilio'),
      ),
    };

    if (_vetPosition != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('vet-car'),
          position: _vetPosition!,
          icon: _vetIcon,
          infoWindow: const InfoWindow(title: 'Veterinario en camino'),
        ),
      );
    }
    return markers;
  }

  @override
  Widget build(BuildContext context) {
    final initial = _vetPosition ?? widget.clientLocation;

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(target: initial, zoom: 15.2),
            style: _mapStyle,
            markers: _buildMarkers(),
            onMapCreated: (controller) async {
              _mapController = controller;
            },
          ),
          Positioned(
            top: 54,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: VetWarmTheme.softCardDecoration(color: VetWarmTheme.card),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'El Dr. ${widget.doctorName} llega en $_etaMinutes minutos',
                    style: const TextStyle(
                      color: VetWarmTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      _error!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
