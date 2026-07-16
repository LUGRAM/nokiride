import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/location/location_service.dart';
import '../model/place_model.dart';

class MiniMapWidget extends StatefulWidget {
  const MiniMapWidget({
    super.key,
    this.pickup,
    this.dropoff,
    this.driverLocation,
    this.routePoints = const <LatLng>[],
    this.showDriver = false,
    this.showHeatmap = false,
  });

  final PlaceModel? pickup;
  final PlaceModel? dropoff;
  final PlaceModel? driverLocation;
  final List<LatLng> routePoints;
  final bool showDriver;
  final bool showHeatmap;

  @override
  State<MiniMapWidget> createState() => _MiniMapWidgetState();
}

class _MiniMapWidgetState extends State<MiniMapWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _driverCtrl;
  late final Animation<double> _driverAnim;
  GoogleMapController? _mapController;
  LatLng? _currentLatLng;
  LatLng? _driverFrom;
  LatLng? _driverTo;

  static const LatLng _librevilleCenter = LatLng(0.3901, 9.4544);

  @override
  void initState() {
    super.initState();
    _driverCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _driverAnim = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _driverCtrl, curve: Curves.easeInOut),
    );
    _driverAnim.addListener(() {
      if (mounted && _supportsGoogleMaps && widget.showDriver) {
        setState(() {});
      }
    });
    _loadCurrentPosition();
  }

  @override
  void dispose() {
    _driverCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_supportsGoogleMaps) {
      return _buildGoogleMap(context);
    }

    return _buildFallbackMap(context);
  }

  bool get _supportsGoogleMaps =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  Widget _buildGoogleMap(BuildContext context) {
    final markers = _markers(context);
    final polylines = _polylines(context);
    final circles = _circles(context);
    final target = _cameraTarget;

    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(target: target, zoom: 13.5),
          markers: markers,
          polylines: polylines,
          circles: circles,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          compassEnabled: false,
          mapToolbarEnabled: false,
          onMapCreated: (controller) {
            _mapController = controller;
            _fitRoute();
          },
        ),
        if (widget.pickup != null)
          Positioned(
            top: 16,
            left: 16,
            child: _LocationBadge(label: widget.pickup!.name),
          ),
        Positioned(
          right: 16,
          bottom: 24,
          child: _LocateButton(onTap: _goToCurrentPosition),
        ),
      ],
    );
  }

  Widget _buildFallbackMap(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return CustomPaint(
      painter: _MapPainter(
        isDark: isDark,
        bgColor: AppColors.background(context),
        routeColor: AppColors.accent(context).withValues(alpha: 0.5),
        showHeatmap: widget.showHeatmap,
      ),
      child: Stack(
        children: [
          // Marqueur départ
          if (widget.pickup != null)
            Positioned(
              left: 80,
              top: 160,
              child: _MapPin(
                  color: AppColors.accent(context),
                  icon: FontAwesomeIcons.circleDot),
            ),

          // Marqueur arrivée
          if (widget.dropoff != null)
            Positioned(
              right: 90,
              top: 280,
              child: _MapPin(
                  color: AppColors.accent(context),
                  icon: FontAwesomeIcons.locationDot),
            ),

          // Marqueur coursier animé
          if (widget.showDriver && widget.driverLocation != null)
            Positioned(
              left: 180,
              top: 220,
              child: _MapPin(
                color: AppColors.accent(context),
                icon: FontAwesomeIcons.motorcycle,
                size: 38,
              ),
            ),

          // Badge lieu départ
          if (widget.pickup != null)
            Positioned(
              top: 16,
              left: 16,
              child: _LocationBadge(
                label: widget.pickup!.name,
              ),
            ),
        ],
      ),
    );
  }

  Set<Marker> _markers(BuildContext context) {
    final markers = <Marker>{};
    final pickup = widget.pickup;
    final dropoff = widget.dropoff;

    if (_currentLatLng != null) {
      markers.add(Marker(
        markerId: const MarkerId('current'),
        position: _currentLatLng!,
        infoWindow: const InfoWindow(title: 'Position actuelle'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ));
    }

    if (pickup != null) {
      markers.add(Marker(
        markerId: const MarkerId('pickup'),
        position: LatLng(pickup.lat, pickup.lng),
        infoWindow: InfoWindow(title: pickup.name, snippet: pickup.address),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ));
    }

    if (dropoff != null) {
      markers.add(Marker(
        markerId: const MarkerId('dropoff'),
        position: LatLng(dropoff.lat, dropoff.lng),
        infoWindow: InfoWindow(title: dropoff.name, snippet: dropoff.address),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose),
      ));
    }

    if (widget.showDriver) {
      final driverPosition = _driverLatLng;
      if (driverPosition != null) {
        markers.add(Marker(
          markerId: const MarkerId('driver'),
          position: driverPosition,
          infoWindow: const InfoWindow(title: 'Coursier'),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
        ));
      }
    }

    if (widget.showHeatmap) {
      // Mock autres chauffeurs à proximité
      markers.addAll({
        Marker(
          markerId: const MarkerId('other_1'),
          position: const LatLng(0.395, 9.460),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        ),
        Marker(
          markerId: const MarkerId('other_2'),
          position: const LatLng(0.385, 9.445),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        ),
      });
    }

    return markers;
  }

  Set<Polyline> _polylines(BuildContext context) {
    final points = widget.routePoints.length >= 2
        ? widget.routePoints
        : _fallbackRoutePoints;
    if (points.length < 2) return {};

    return {
      Polyline(
        polylineId: const PolylineId('route'),
        points: points,
        color: AppColors.accent(context),
        width: 5,
      ),
    };
  }

  List<LatLng> get _fallbackRoutePoints {
    final pickup = widget.pickup;
    final dropoff = widget.dropoff;
    if (pickup == null || dropoff == null) return const <LatLng>[];
    return <LatLng>[
      LatLng(pickup.lat, pickup.lng),
      LatLng(dropoff.lat, dropoff.lng),
    ];
  }

  Set<Circle> _circles(BuildContext context) {
    if (!widget.showHeatmap) return {};

    // Mock zones de forte demande
    return {
      Circle(
        circleId: const CircleId('demand_1'),
        center: const LatLng(0.3901, 9.4544),
        radius: 800,
        fillColor: Colors.orange.withValues(alpha: 0.2),
        strokeColor: Colors.orange.withValues(alpha: 0.5),
        strokeWidth: 2,
      ),
      Circle(
        circleId: const CircleId('demand_2'),
        center: const LatLng(0.4200, 9.4200),
        radius: 1200,
        fillColor: Colors.red.withValues(alpha: 0.15),
        strokeColor: Colors.red.withValues(alpha: 0.4),
        strokeWidth: 2,
      ),
    };
  }

  LatLng get _cameraTarget {
    if (widget.pickup != null) {
      return LatLng(widget.pickup!.lat, widget.pickup!.lng);
    }
    if (_currentLatLng != null) return _currentLatLng!;
    return _librevilleCenter;
  }

  LatLng? get _driverLatLng {
    if (_driverTo == null) return null;
    final from = _driverFrom ?? _driverTo!;
    final to = _driverTo!;
    final t = _driverAnim.value;
    return LatLng(
      from.latitude + ((to.latitude - from.latitude) * t),
      from.longitude + ((to.longitude - from.longitude) * t),
    );
  }

  Future<void> _loadCurrentPosition() async {
    final position = await LocationService.currentPosition();
    if (!mounted || position == null) return;
    setState(() {
      _currentLatLng = LatLng(position.latitude, position.longitude);
    });
  }

  Future<void> _goToCurrentPosition() async {
    if (_currentLatLng == null) await _loadCurrentPosition();
    final target = _currentLatLng;
    if (target == null) return;
    await _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(CameraPosition(target: target, zoom: 16)),
    );
  }

  Future<void> _fitRoute() async {
    final points = widget.routePoints.length >= 2
        ? widget.routePoints
        : _fallbackRoutePoints;
    if (points.length < 2) return;

    var south = points.first.latitude;
    var north = points.first.latitude;
    var west = points.first.longitude;
    var east = points.first.longitude;
    for (final point in points.skip(1)) {
      if (point.latitude < south) south = point.latitude;
      if (point.latitude > north) north = point.latitude;
      if (point.longitude < west) west = point.longitude;
      if (point.longitude > east) east = point.longitude;
    }

    await Future<void>.delayed(const Duration(milliseconds: 250));
    if (south == north && west == east) {
      await _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(points.first, 16),
      );
      return;
    }
    await _mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(south, west),
          northeast: LatLng(north, east),
        ),
        72,
      ),
    );
  }

  @override
  void didUpdateWidget(covariant MiniMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    final driver = widget.driverLocation;
    if (driver != null && oldWidget.driverLocation != driver) {
      _driverFrom = _driverLatLng ?? LatLng(driver.lat, driver.lng);
      _driverTo = LatLng(driver.lat, driver.lng);
      _driverCtrl.forward(from: 0);
    }
    if (oldWidget.pickup != widget.pickup ||
        oldWidget.dropoff != widget.dropoff ||
        !listEquals(oldWidget.routePoints, widget.routePoints)) {
      _fitRoute();
    }
  }
}

class _LocateButton extends StatelessWidget {
  const _LocateButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface(context),
      shape: const CircleBorder(),
      elevation: 4,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 46,
          height: 46,
          child: Icon(Icons.my_location_rounded,
              color: AppColors.accent(context), size: 22),
        ),
      ),
    );
  }
}

// ─── Painter carte stylisée ───────────────────────────────────
class _MapPainter extends CustomPainter {
  const _MapPainter({
    required this.isDark,
    required this.bgColor,
    required this.routeColor,
    this.showHeatmap = false,
  });
  final bool isDark;
  final Color bgColor;
  final Color routeColor;
  final bool showHeatmap;

  @override
  void paint(Canvas canvas, Size size) {
    final gridColor = isDark
        ? Colors.white.withValues(alpha: 0.02)
        : Colors.black.withValues(alpha: 0.03);
    final roadColor = isDark
        ? Colors.white.withValues(alpha: 0.04)
        : Colors.black.withValues(alpha: 0.05);

    // Fond
    canvas.drawRect(Offset.zero & size, Paint()..color = bgColor);

    if (showHeatmap) {
      final hPaint = Paint()..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(size.width * .4, size.height * .4), 60,
          hPaint..color = Colors.orange.withValues(alpha: 0.1));
      canvas.drawCircle(Offset(size.width * .7, size.height * .6), 80,
          hPaint..color = Colors.red.withValues(alpha: 0.1));
    }

    // Grille
    final gPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    for (double x = 0; x <= size.width; x += 32) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gPaint);
    }
    for (double y = 0; y <= size.height; y += 32) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gPaint);
    }

    // Routes horizontales
    final rPaint = Paint()
      ..color = roadColor
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(0, size.height * .35),
        Offset(size.width, size.height * .35), rPaint);
    canvas.drawLine(Offset(0, size.height * .60),
        Offset(size.width, size.height * .60), rPaint);
    canvas.drawLine(Offset(0, size.height * .80),
        Offset(size.width, size.height * .80), rPaint);

    // Routes verticales
    canvas.drawLine(Offset(size.width * .28, 0),
        Offset(size.width * .28, size.height), rPaint);
    canvas.drawLine(Offset(size.width * .62, 0),
        Offset(size.width * .62, size.height), rPaint);

    // Tracé de route A→B
    final path = Path()
      ..moveTo(size.width * .22, size.height * .42)
      ..quadraticBezierTo(size.width * .40, size.height * .28, size.width * .62,
          size.height * .45)
      ..quadraticBezierTo(size.width * .78, size.height * .60, size.width * .85,
          size.height * .72);

    canvas.drawPath(
      path,
      Paint()
        ..color = routeColor
        ..strokeWidth = 4
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // Blocs de bâtiments
    _drawBlock(canvas, size, .05, .05, .18, .28, isDark);
    _drawBlock(canvas, size, .32, .05, .58, .28, isDark);
    _drawBlock(canvas, size, .66, .05, .90, .28, isDark);
    _drawBlock(canvas, size, .05, .65, .24, .88, isDark);
    _drawBlock(canvas, size, .66, .48, .90, .55, isDark);
  }

  void _drawBlock(Canvas canvas, Size s, double x1, double y1, double x2,
      double y2, bool dark) {
    canvas.drawRRect(
      RRect.fromLTRBR(
        s.width * x1,
        s.height * y1,
        s.width * x2,
        s.height * y2,
        const Radius.circular(4),
      ),
      Paint()
        ..color = dark
            ? Colors.white.withValues(alpha: .02)
            : Colors.black.withValues(alpha: .03),
    );
  }

  @override
  bool shouldRepaint(_MapPainter old) => old.isDark != isDark;
}

// ─── Pin de localisation ──────────────────────────────────────
class _MapPin extends StatelessWidget {
  const _MapPin({
    required this.color,
    required this.icon,
    this.size = 32,
  });
  final Color color;
  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.25),
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 12,
          ),
        ],
      ),
      child: Center(child: FaIcon(icon, color: color, size: size * .45)),
    );
  }
}

// ─── Badge lieu ───────────────────────────────────────────────
class _LocationBadge extends StatelessWidget {
  const _LocationBadge({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final bg = AppColors.surface(context);
    final textC = AppColors.textPrimary(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(FontAwesomeIcons.locationDot,
              color: AppColors.accent(context), size: 10),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: textC,
            ),
          ),
        ],
      ),
    );
  }
}
