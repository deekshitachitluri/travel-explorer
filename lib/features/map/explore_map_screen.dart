import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/map_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../data/local/shopping_spots_data.dart';
import '../../models/destination.dart';
import '../../models/shopping_spot.dart';
import '../../providers/destination_provider.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/map/attraction_map_marker.dart';
import '../../widgets/map/attraction_map_preview_card.dart';
import '../../widgets/map/destination_map_marker.dart';
import '../../widgets/map/destination_map_preview_card.dart';
import '../../widgets/map/shopping_spot_map_marker.dart';
import '../../widgets/map/shopping_spot_preview_card.dart';

/// Full-screen interactive map displaying destinations and attractions across India.
class ExploreMapScreen extends StatefulWidget {
  final String? initialDestinationId;
  final String? initialSpotId;
  final String? attractionName;
  final double? attractionLatitude;
  final double? attractionLongitude;
  final String? parentDestinationName;
  final String? attractionDescription;
  final String? attractionImageUrl;

  const ExploreMapScreen({
    super.key,
    this.initialDestinationId,
    this.initialSpotId,
    this.attractionName,
    this.attractionLatitude,
    this.attractionLongitude,
    this.parentDestinationName,
    this.attractionDescription,
    this.attractionImageUrl,
  });

  @override
  State<ExploreMapScreen> createState() => _ExploreMapScreenState();
}

class _ExploreMapScreenState extends State<ExploreMapScreen> {
  late final MapController _mapController;
  String? _selectedDestinationId;
  String _selectedCategory = 'All';
  bool _isMapReady = false;
  bool _hasTileError = false;

  // Attraction state
  bool _showAttractionCard = false;
  bool _isFallbackCoordinates = false;
  LatLng? _attractionPoint;

  // Shopping Spots state
  ShoppingSpot? _selectedShoppingSpot;
  bool _showShoppingSpots = true;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _selectedDestinationId = widget.initialDestinationId;

    _setupInitialTarget();
  }

  void _setupInitialTarget() {
    if (widget.initialSpotId != null) {
      final matches = ShoppingSpotsData.allSpots.where(
        (s) => s.id == widget.initialSpotId,
      );
      if (matches.isNotEmpty) {
        _selectedShoppingSpot = matches.first;
        _attractionPoint = LatLng(
          _selectedShoppingSpot!.latitude,
          _selectedShoppingSpot!.longitude,
        );
        _isFallbackCoordinates = false;
        return;
      }
    }

    if (widget.attractionName != null) {
      _showAttractionCard = true;
      final lat = widget.attractionLatitude;
      final lng = widget.attractionLongitude;

      if (lat != null && lng != null && lat != 0.0 && lng != 0.0) {
        _attractionPoint = LatLng(lat, lng);
        _isFallbackCoordinates = false;
      } else {
        _isFallbackCoordinates = true;
      }
    }
  }

  void _onMapReady() {
    if (!mounted) return;
    setState(() => _isMapReady = true);

    // If shopping spot was passed, zoom directly into the spot
    if (_selectedShoppingSpot != null) {
      _mapController.move(
        LatLng(
          _selectedShoppingSpot!.latitude,
          _selectedShoppingSpot!.longitude,
        ),
        14.0,
      );
      return;
    }

    // If attraction point is present, zoom directly into the attraction
    if (_attractionPoint != null) {
      _mapController.move(_attractionPoint!, 14.0);
      return;
    }

    // If destination ID was passed, focus it
    if (_selectedDestinationId != null) {
      _focusDestination(_selectedDestinationId!);
    }
  }

  void _focusDestination(String id) {
    final destProvider = context.read<DestinationProvider>();
    final dest = destProvider.findById(id);
    if (dest != null) {
      setState(() {
        _selectedDestinationId = id;
        _showAttractionCard = false;
        _selectedShoppingSpot = null;
      });
      _mapController.move(
        LatLng(dest.latitude, dest.longitude),
        MapConstants.destinationZoom,
      );
    }
  }

  void _recenterIndia() {
    setState(() {
      _selectedDestinationId = null;
      _showAttractionCard = false;
      _selectedShoppingSpot = null;
    });
    _mapController.move(MapConstants.indiaCenter, MapConstants.defaultZoom);
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

  void _fitVisibleMarkers(List<Destination> destinations) {
    if (destinations.isEmpty) return;
    final points = destinations
        .map((d) => LatLng(d.latitude, d.longitude))
        .toList();
    if (_attractionPoint != null) {
      points.add(_attractionPoint!);
    }
    final bounds = MapConstants.boundsFromPoints(points);
    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.only(
          top: 130,
          bottom: 80,
          left: 40,
          right: 40,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final destProvider = context.watch<DestinationProvider>();
    final allDestinations = destProvider.allDestinations;

    // Filter destinations by category with normalization
    final visibleDestinations = allDestinations
        .where((d) => d.matchesCategory(_selectedCategory))
        .toList();

    final selectedDestination = _selectedDestinationId != null
        ? destProvider.findById(_selectedDestinationId!)
        : null;

    // Fixed: AppConstants.categories already contains exactly:
    // ['All', 'Beaches', 'Mountains', 'Heritage', 'Adventure']
    final categories = AppConstants.categories;

    // Check if initial destination is provided for fallback coordinate centering
    if (_isFallbackCoordinates &&
        _attractionPoint == null &&
        widget.initialDestinationId != null) {
      final parentDest = destProvider.findById(widget.initialDestinationId!);
      if (parentDest != null) {
        _attractionPoint = LatLng(parentDest.latitude, parentDest.longitude);
      }
    }

    final hasInitialFocus =
        _attractionPoint != null || _selectedDestinationId != null;

    return Scaffold(
      body: Stack(
        children: [
          // 1. FlutterMap with OpenStreetMap TileLayer
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter:
                  _attractionPoint ??
                  (selectedDestination != null
                      ? LatLng(
                          selectedDestination.latitude,
                          selectedDestination.longitude,
                        )
                      : MapConstants.indiaCenter),
              initialZoom: _attractionPoint != null
                  ? (_isFallbackCoordinates ? 10.0 : 14.0)
                  : (selectedDestination != null
                        ? MapConstants.destinationZoom
                        : MapConstants.defaultZoom),
              minZoom: MapConstants.minZoom,
              maxZoom: MapConstants.maxZoom,
              initialCameraFit: hasInitialFocus
                  ? null
                  : CameraFit.bounds(
                      bounds: MapConstants.indiaBounds,
                      padding: const EdgeInsets.only(
                        top: 140,
                        bottom: 90,
                        left: 32,
                        right: 32,
                      ),
                    ),
              onMapReady: _onMapReady,
              onTap: (_, __) {
                if (_selectedDestinationId != null ||
                    _showAttractionCard ||
                    _selectedShoppingSpot != null) {
                  setState(() {
                    _selectedDestinationId = null;
                    _showAttractionCard = false;
                    _selectedShoppingSpot = null;
                  });
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: MapConstants.osmTileUrl,
                userAgentPackageName: kIsWeb
                    ? ''
                    : MapConstants.userAgentPackageName,
                tileProvider: NetworkTileProvider(),
                panBuffer: 1,
                keepBuffer: 2,
                tileDisplay: const TileDisplay.fadeIn(
                  duration: Duration(milliseconds: 150),
                ),
                errorTileCallback: (tile, error, stackTrace) {
                  if (!_hasTileError && mounted) {
                    setState(() => _hasTileError = true);
                  }
                },
              ),

              // Markers Layer
              MarkerLayer(
                markers: [
                  // Destination Markers
                  ...visibleDestinations.map((dest) {
                    final isSelected = dest.id == _selectedDestinationId;
                    return Marker(
                      point: LatLng(dest.latitude, dest.longitude),
                      width: 100,
                      height: 80,
                      alignment: Alignment.center,
                      child: DestinationMapMarker(
                        destination: dest,
                        isSelected: isSelected,
                        onTap: () {
                          setState(() {
                            _selectedDestinationId = dest.id;
                            _showAttractionCard = false;
                          });
                          _mapController.move(
                            LatLng(dest.latitude, dest.longitude),
                            _mapController.camera.zoom < 8.0
                                ? 8.5
                                : _mapController.camera.zoom,
                          );
                        },
                      ),
                    );
                  }),

                  // Attraction Marker (if an attraction location was requested and has valid coordinates)
                  if (widget.attractionName != null &&
                      _attractionPoint != null &&
                      !_isFallbackCoordinates)
                    Marker(
                      point: _attractionPoint!,
                      width: 110,
                      height: 75,
                      alignment: Alignment.center,
                      child: AttractionMapMarker(
                        attractionName: widget.attractionName!,
                        isSelected: _showAttractionCard,
                        onTap: () {
                          setState(() {
                            _showAttractionCard = true;
                            _selectedDestinationId = null;
                            _selectedShoppingSpot = null;
                          });
                        },
                      ),
                    ),

                  // Shopping Spot Markers
                  if (_showShoppingSpots)
                    ...ShoppingSpotsData.allSpots.map((spot) {
                      final isSelected = spot.id == _selectedShoppingSpot?.id;
                      return Marker(
                        point: LatLng(spot.latitude, spot.longitude),
                        width: 100,
                        height: 75,
                        alignment: Alignment.center,
                        child: ShoppingSpotMapMarker(
                          spot: spot,
                          isSelected: isSelected,
                          onTap: () {
                            setState(() {
                              _selectedShoppingSpot = spot;
                              _selectedDestinationId = null;
                              _showAttractionCard = false;
                            });
                            _mapController.move(
                              LatLng(spot.latitude, spot.longitude),
                              _mapController.camera.zoom < 12.0
                                  ? 13.5
                                  : _mapController.camera.zoom,
                            );
                          },
                        ),
                      );
                    }),
                ],
              ),

              // Visible Legal Attribution
              RichAttributionWidget(
                attributions: [
                  TextSourceAttribution(
                    'OpenStreetMap contributors',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Map data © OpenStreetMap contributors (ODbL)',
                          ),
                          duration: Duration(seconds: 3),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),

          // 2. Loading Indicator (while map tiles initially initialize)
          if (!_isMapReady)
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.primaryLight,
                ),
                minHeight: 3,
              ),
            ),

          // 3. Tile Load Warning (non-intrusive offline fallback notice)
          if (_hasTileError)
            Positioned(
              top: 136,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: (isDark ? AppColors.surfaceDark : Colors.white)
                      .withOpacity(0.92),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: AppColors.accentAmber.withOpacity(0.4),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.cloud_off_rounded,
                      size: 16,
                      color: AppColors.accentAmber,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Live map tiles require internet access. Markers and cached tiles remain active.',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // 4. Top Navigation Bar & Category Filter Bar
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Header Card
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: (isDark ? AppColors.surfaceDark : Colors.white)
                        .withOpacity(0.95),
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_rounded),
                        onPressed: () => context.pop(),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.attractionName != null
                                  ? 'Attraction Location'
                                  : 'Interactive Map',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              widget.attractionName != null
                                  ? widget.attractionName!
                                  : '${visibleDestinations.length} destinations across India',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark
                                    ? AppColors.textMutedDark
                                    : AppColors.textMutedLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Shopping spots layer toggle button
                      IconButton(
                        icon: Icon(
                          _showShoppingSpots
                              ? Icons.shopping_bag_rounded
                              : Icons.shopping_bag_outlined,
                          size: 20,
                          color: _showShoppingSpots
                              ? AppColors.terracotta
                              : (isDark ? Colors.white54 : Colors.black54),
                        ),
                        tooltip: _showShoppingSpots
                            ? 'Hide shopping spots'
                            : 'Show shopping spots',
                        onPressed: () {
                          setState(() {
                            _showShoppingSpots = !_showShoppingSpots;
                          });
                        },
                      ),
                      // Fit all visible markers button
                      IconButton(
                        icon: const Icon(Icons.crop_free_rounded, size: 20),
                        tooltip: 'Fit all visible places',
                        onPressed: () =>
                            _fitVisibleMarkers(visibleDestinations),
                      ),
                    ],
                  ),
                ),

                // Category Filter Chips (Single horizontal scrollable row, exactly 5 chips)
                SizedBox(
                  height: 42,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final cat = categories[index];
                      final isSelected = _selectedCategory == cat;
                      return CategoryChip(
                        label: cat,
                        isSelected: isSelected,
                        onTap: () {
                          setState(() {
                            _selectedCategory = cat;
                            _showAttractionCard = false;
                            if (_selectedDestinationId != null) {
                              final current = destProvider.findById(
                                _selectedDestinationId!,
                              );
                              if (current != null &&
                                  !current.matchesCategory(cat)) {
                                _selectedDestinationId = null;
                              }
                            }
                          });
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // 5. Floating Map Controls (Zoom In, Zoom Out, Recenter India)
          Positioned(
            right: 16,
            bottom:
                (_showAttractionCard ||
                    selectedDestination != null ||
                    _selectedShoppingSpot != null)
                ? 230
                : 40,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildMapFloatingButton(
                  icon: Icons.add_rounded,
                  tooltip: 'Zoom in',
                  onTap: _zoomIn,
                  isDark: isDark,
                ),
                const SizedBox(height: 8),
                _buildMapFloatingButton(
                  icon: Icons.remove_rounded,
                  tooltip: 'Zoom out',
                  onTap: _zoomOut,
                  isDark: isDark,
                ),
                const SizedBox(height: 8),
                _buildMapFloatingButton(
                  icon: Icons.my_location_rounded,
                  tooltip: 'Center India',
                  onTap: _recenterIndia,
                  isDark: isDark,
                ),
              ],
            ),
          ),

          // 6. Selected Destination Preview Card
          if (selectedDestination != null && !_showAttractionCard)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: DestinationMapPreviewCard(
                destination: selectedDestination,
                onClose: () => setState(() => _selectedDestinationId = null),
              ),
            ),

          // 7. Attraction Preview Card (when opened via Directions)
          if (_showAttractionCard && widget.attractionName != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: AttractionMapPreviewCard(
                attractionName: widget.attractionName!,
                parentDestinationName: widget.parentDestinationName,
                description: widget.attractionDescription,
                imageUrl: widget.attractionImageUrl,
                isFallbackCoordinates: _isFallbackCoordinates,
                onBackToDetails: () => context.pop(),
                onClose: () => setState(() => _showAttractionCard = false),
              ),
            ),

          // 8. Shopping Spot Preview Card
          if (_selectedShoppingSpot != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: ShoppingSpotPreviewCard(
                spot: _selectedShoppingSpot!,
                onClose: () => setState(() => _selectedShoppingSpot = null),
                onBackToDestination: () {
                  final dId = _selectedShoppingSpot!.destinationId;
                  setState(() => _selectedShoppingSpot = null);
                  context.push('/destination/$dId');
                },
              ),
            ),

          // 8. Empty State (if category filter produces 0 results)
          if (visibleDestinations.isEmpty)
            Center(
              child: Container(
                margin: const EdgeInsets.all(24),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.travel_explore_rounded,
                      size: 40,
                      color: AppColors.primaryLight,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'No destinations found in "$_selectedCategory"',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextButton(
                      onPressed: () =>
                          setState(() => _selectedCategory = 'All'),
                      child: const Text('Show All Destinations'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMapFloatingButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: (isDark ? AppColors.surfaceDark : Colors.white).withOpacity(
          0.95,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, size: 20),
        tooltip: tooltip,
        onPressed: onTap,
      ),
    );
  }
}
