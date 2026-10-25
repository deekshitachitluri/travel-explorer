import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../core/constants/map_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../models/itinerary_activity.dart';
import '../../models/trip.dart';
import '../../providers/destination_provider.dart';
import '../../widgets/map/itinerary_stop_marker.dart';

/// Embedded interactive map displaying a trip's itinerary activities, stops, and route polyline.
class TripItineraryMapView extends StatefulWidget {
  final Trip trip;
  final List<ItineraryActivity> activities;
  final int? selectedDayNumber;

  const TripItineraryMapView({
    super.key,
    required this.trip,
    required this.activities,
    this.selectedDayNumber,
  });

  @override
  State<TripItineraryMapView> createState() => _TripItineraryMapViewState();
}

class _TripItineraryMapViewState extends State<TripItineraryMapView> {
  late final MapController _mapController;
  int? _activeDayFilter;
  ItineraryActivity? _selectedActivity;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _activeDayFilter = widget.selectedDayNumber;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fitMapToStops();
    });
  }

  @override
  void didUpdateWidget(TripItineraryMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDayNumber != widget.selectedDayNumber) {
      setState(() {
        _activeDayFilter = widget.selectedDayNumber;
      });
      _fitMapToStops();
    }
  }

  void _fitMapToStops() {
    final validPoints = _getFilteredActivities()
        .where((a) => a.latitude != null && a.longitude != null)
        .map((a) => LatLng(a.latitude!, a.longitude!))
        .toList();

    // If destination has base coordinates, include them
    final destProvider = context.read<DestinationProvider>();
    final dest = widget.trip.destinationId != null
        ? destProvider.findById(widget.trip.destinationId!)
        : null;

    if (dest != null) {
      validPoints.add(LatLng(dest.latitude, dest.longitude));
    }

    if (validPoints.isNotEmpty) {
      final bounds = MapConstants.boundsFromPoints(validPoints);
      _mapController.fitCamera(
        CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(40.0)),
      );
    }
  }

  List<ItineraryActivity> _getFilteredActivities() {
    if (_activeDayFilter == null || _activeDayFilter == 0) {
      return widget.activities;
    }
    return widget.activities
        .where((a) => a.dayNumber == _activeDayFilter)
        .toList();
  }

  void _zoomIn() {
    final currentZoom = _mapController.camera.zoom;
    _mapController.move(
      _mapController.camera.center,
      (currentZoom + 1).clamp(MapConstants.minZoom, MapConstants.maxZoom),
    );
  }

  void _zoomOut() {
    final currentZoom = _mapController.camera.zoom;
    _mapController.move(
      _mapController.camera.center,
      (currentZoom - 1).clamp(MapConstants.minZoom, MapConstants.maxZoom),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final destProvider = context.watch<DestinationProvider>();
    final dest = widget.trip.destinationId != null
        ? destProvider.findById(widget.trip.destinationId!)
        : null;

    final filteredActivities = _getFilteredActivities();
    final activitiesWithCoords = filteredActivities
        .where((a) => a.latitude != null && a.longitude != null)
        .toList();

    // Collect sequential coordinates for route polyline
    final routePoints = activitiesWithCoords
        .map((a) => LatLng(a.latitude!, a.longitude!))
        .toList();

    // Initial map center
    final LatLng initialCenter = routePoints.isNotEmpty
        ? routePoints.first
        : (dest != null
              ? LatLng(dest.latitude, dest.longitude)
              : MapConstants.indiaCenter);

    return Stack(
      children: [
        // 1. FlutterMap
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: initialCenter,
            initialZoom: 10.0,
            minZoom: MapConstants.minZoom,
            maxZoom: MapConstants.maxZoom,
            onTap: (_, __) {
              if (_selectedActivity != null) {
                setState(() => _selectedActivity = null);
              }
            },
          ),
          children: [
            TileLayer(
              urlTemplate: MapConstants.osmTileUrl,
              userAgentPackageName: MapConstants.userAgentPackageName,
              tileProvider: NetworkTileProvider(),
            ),

            // Polyline route: Drawn strictly when 2 or more sequential stops have verified coordinates
            if (routePoints.length >= 2)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: routePoints,
                    strokeWidth: 4.0,
                    color: AppColors.forestGreen,
                    pattern: const StrokePattern.solid(),
                  ),
                ],
              ),

            // Markers Layer
            MarkerLayer(
              markers: [
                // Base Destination Pin
                if (dest != null)
                  Marker(
                    point: LatLng(dest.latitude, dest.longitude),
                    width: 70,
                    height: 50,
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 1.5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(AppRadius.xs),
                          ),
                          child: Text(
                            dest.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.location_pin,
                          color: AppColors.primary,
                          size: 28,
                        ),
                      ],
                    ),
                  ),

                // Numbered Itinerary Stop Markers
                ...activitiesWithCoords.asMap().entries.map((entry) {
                  final index = entry.key;
                  final act = entry.value;
                  final isSelected = _selectedActivity?.id == act.id;

                  return Marker(
                    point: LatLng(act.latitude!, act.longitude!),
                    width: 80,
                    height: 60,
                    alignment: Alignment.center,
                    child: ItineraryStopMarker(
                      stopIndex: index,
                      activity: act,
                      isSelected: isSelected,
                      onTap: () {
                        setState(() => _selectedActivity = act);
                        _mapController.move(
                          LatLng(act.latitude!, act.longitude!),
                          13.0,
                        );
                      },
                    ),
                  );
                }),
              ],
            ),

            // Attribution
            const RichAttributionWidget(
              attributions: [
                TextSourceAttribution('OpenStreetMap contributors'),
              ],
            ),
          ],
        ),

        // 2. Top Controls & Day Selector Filter
        Positioned(
          top: 12,
          left: 12,
          right: 12,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Summary Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: (isDark
                          ? AppColors.surfaceDark
                          : AppColors.creamSurface)
                      .withOpacity(0.94),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.route_rounded,
                      size: 16,
                      color:
                          isDark ? AppColors.mutedSage : AppColors.forestGreen,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${activitiesWithCoords.length} mapped stops'
                      '${routePoints.length >= 2 ? ' • Sequential route active' : ''}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Horizontal Day Filter Chips
              SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.trip.totalDays + 1,
                  separatorBuilder: (_, __) => const SizedBox(width: 6),
                  itemBuilder: (context, index) {
                    final isAll = index == 0;
                    final dayNum = isAll ? null : index;
                    final isSelected = _activeDayFilter == dayNum;

                    return FilterChip(
                      label: Text(
                        isAll ? 'All Days' : 'Day $dayNum',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : (isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimaryLight),
                        ),
                      ),
                      selected: isSelected,
                      selectedColor:
                          isDark ? AppColors.mutedSage : AppColors.forestGreen,
                      backgroundColor: isDark
                          ? AppColors.surfaceDark
                          : AppColors.creamSurface.withOpacity(0.9),
                      showCheckmark: false,
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      onSelected: (_) {
                        setState(() {
                          _activeDayFilter = dayNum;
                          _selectedActivity = null;
                        });
                        _fitMapToStops();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        // 3. Floating Map Controls (Zoom In, Zoom Out, Fit)
        Positioned(
          right: 12,
          bottom: _selectedActivity != null ? 150 : 20,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildFloatingBtn(
                icon: Icons.add_rounded,
                tooltip: 'Zoom in',
                onTap: _zoomIn,
                isDark: isDark,
              ),
              const SizedBox(height: 6),
              _buildFloatingBtn(
                icon: Icons.remove_rounded,
                tooltip: 'Zoom out',
                onTap: _zoomOut,
                isDark: isDark,
              ),
              const SizedBox(height: 6),
              _buildFloatingBtn(
                icon: Icons.crop_free_rounded,
                tooltip: 'Fit route in view',
                onTap: _fitMapToStops,
                isDark: isDark,
              ),
            ],
          ),
        ),

        // 4. Selected Activity Detail Card
        if (_selectedActivity != null)
          Positioned(
            left: 12,
            right: 12,
            bottom: 16,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.creamSurface,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.18),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: isDark ? AppColors.dividerDark : AppColors.creamBorder,
                  width: 1.2,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.surfaceDark
                              : AppColors.mutedSageLight,
                          borderRadius: BorderRadius.circular(AppRadius.xs),
                        ),
                        child: Text(
                          'DAY ${_selectedActivity!.dayNumber}',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppColors.mutedSage
                                : AppColors.forestGreen,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () => setState(() => _selectedActivity = null),
                        child: const Icon(Icons.close_rounded, size: 18),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _selectedActivity!.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (_selectedActivity!.locationName.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 13,
                          color: AppColors.textMutedLight,
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            _selectedActivity!.locationName,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (_selectedActivity!.notes != null &&
                      _selectedActivity!.notes!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      _selectedActivity!.notes!,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontStyle: FontStyle.italic,
                        color: isDark
                            ? AppColors.textMutedDark
                            : AppColors.textMutedLight,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ),

        // 5. Empty State (when no activities have coordinates)
        if (activitiesWithCoords.isEmpty)
          Center(
            child: Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: (isDark ? AppColors.surfaceDark : Colors.white)
                    .withOpacity(0.92),
                borderRadius: BorderRadius.circular(AppRadius.lg),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.map_outlined,
                    size: 38,
                    color: AppColors.primaryLight,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'No Mapped Coordinates for this Day',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Activities added with specific attractions or locations will automatically appear with numbered stops and route polylines.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFloatingBtn({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: (isDark ? AppColors.surfaceDark : Colors.white).withOpacity(
          0.92,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 6),
        ],
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(icon, size: 18),
        tooltip: tooltip,
        onPressed: onTap,
      ),
    );
  }
}
