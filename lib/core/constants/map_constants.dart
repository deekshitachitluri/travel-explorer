import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// Centralized configuration for in-app OpenStreetMap-powered maps.
///
/// Adheres strictly to the OpenStreetMap Foundation Tile Usage Policy:
/// - Valid custom HTTP User-Agent identifying the GDGC Travel Explorer App
/// - Legitimate OpenStreetMap tile endpoint (raster tiles)
/// - Visible attribution to © OpenStreetMap contributors
/// - Strictly avoids bulk downloading or policy violations
class MapConstants {
  /// Standard OpenStreetMap raster tile server
  static const String osmTileUrl =
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

  /// Package User-Agent required by OSM tile policy
  static const String userAgentPackageName =
      'com.gdgc.travelexplorer.flutter_app';

  /// Required OSM tile attribution
  static const String osmAttribution =
      '© OpenStreetMap contributors • Open Database License (ODbL)';

  /// Geographic center of India
  static const LatLng indiaCenter = LatLng(22.3511, 78.6677);

  /// Approximate geographic bounds covering India
  static final LatLngBounds indiaBounds = LatLngBounds(
    const LatLng(8.0, 68.0),
    const LatLng(36.0, 97.0),
  );

  /// Default zoom level showing the majority of the Indian subcontinent
  static const double defaultZoom = 4.8;
  static const double minZoom = 3.0;
  static const double maxZoom = 18.0;

  /// Default destination zoom level when focusing on an individual city/spot
  static const double destinationZoom = 12.0;

  /// Calculate bounding box for a collection of LatLng points with padding
  static LatLngBounds boundsFromPoints(List<LatLng> points) {
    if (points.isEmpty) {
      return LatLngBounds(const LatLng(8.0, 68.0), const LatLng(36.0, 97.0));
    }
    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (final p in points) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }

    // Add margin if points are identical or very close
    if ((maxLat - minLat).abs() < 0.05) {
      minLat -= 0.05;
      maxLat += 0.05;
    }
    if ((maxLng - minLng).abs() < 0.05) {
      minLng -= 0.05;
      maxLng += 0.05;
    }

    return LatLngBounds(LatLng(minLat, minLng), LatLng(maxLat, maxLng));
  }
}
