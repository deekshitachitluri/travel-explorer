import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../models/trip.dart';
import '../../providers/destination_provider.dart';
import '../../providers/trip_provider.dart';

class CreateEditTripDialog extends StatefulWidget {
  final Trip? tripToEdit;
  final String? initialDestinationId;
  final String? initialDestinationName;
  final String? initialImage;
  final double? initialBudget;

  const CreateEditTripDialog({
    super.key,
    this.tripToEdit,
    this.initialDestinationId,
    this.initialDestinationName,
    this.initialImage,
    this.initialBudget,
  });

  @override
  State<CreateEditTripDialog> createState() => _CreateEditTripDialogState();
}

class _CreateEditTripDialogState extends State<CreateEditTripDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _destinationController;
  late TextEditingController _budgetController;
  late TextEditingController _travelersController;
  late TextEditingController _notesController;

  late DateTime _startDate;
  late DateTime _endDate;
  String? _selectedDestId;
  String? _selectedDestImage;
  String _travelStyle = 'Leisure';

  final List<String> _travelStyles = [
    'Leisure',
    'Adventure',
    'Solo',
    'Family',
    'Cultural',
    'Romantic',
  ];

  @override
  void initState() {
    super.initState();
    final t = widget.tripToEdit;
    _titleController = TextEditingController(
      text:
          t?.title ??
          (widget.initialDestinationName != null
              ? 'Trip to ${widget.initialDestinationName!.split(',').first}'
              : ''),
    );
    _destinationController = TextEditingController(
      text: t?.destinationName ?? widget.initialDestinationName ?? '',
    );
    _budgetController = TextEditingController(
      text: t != null
          ? t.plannedBudget.toStringAsFixed(0)
          : (widget.initialBudget != null
                ? widget.initialBudget!.toStringAsFixed(0)
                : '25000'),
    );
    _travelersController = TextEditingController(
      text: (t?.numberOfTravelers ?? 1).toString(),
    );
    _notesController = TextEditingController(text: t?.notes ?? '');

    _startDate = t?.startDate ?? DateTime.now().add(const Duration(days: 7));
    _endDate = t?.endDate ?? DateTime.now().add(const Duration(days: 11));
    _selectedDestId = t?.destinationId ?? widget.initialDestinationId;
    _selectedDestImage = t?.destinationImage ?? widget.initialImage;
    _travelStyle = t?.travelStyle ?? 'Leisure';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _destinationController.dispose();
    _budgetController.dispose();
    _travelersController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDateRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 730)),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.forestGreen,
              onPrimary: AppColors.warmCream,
              surface: AppColors.creamSurface,
              onSurface: AppColors.charcoal,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  Future<void> _saveTrip() async {
    if (!_formKey.currentState!.validate()) return;

    final tripProvider = context.read<TripProvider>();
    final destProvider = context.read<DestinationProvider>();

    final budget = double.tryParse(_budgetController.text.trim()) ?? 0.0;
    final travelers = int.tryParse(_travelersController.text.trim()) ?? 1;

    // Check if entered destination matches seed data for auto image linking
    String? destImage = _selectedDestImage;
    String? destId = _selectedDestId;
    if (destImage == null) {
      final match = destProvider.allDestinations.where(
        (d) =>
            d.name.toLowerCase() ==
            _destinationController.text.trim().toLowerCase(),
      );
      if (match.isNotEmpty) {
        destImage = match.first.imageUrl;
        destId = match.first.id;
      }
    }

    if (widget.tripToEdit != null) {
      final updated = widget.tripToEdit!.copyWith(
        title: _titleController.text.trim(),
        destinationId: destId,
        destinationName: _destinationController.text.trim(),
        destinationImage: destImage,
        startDate: _startDate,
        endDate: _endDate,
        numberOfTravelers: travelers,
        plannedBudget: budget,
        travelStyle: _travelStyle,
        notes: _notesController.text.trim(),
      );
      await tripProvider.updateTrip(updated);
    } else {
      await tripProvider.createTrip(
        title: _titleController.text.trim(),
        destinationId: destId,
        destinationName: _destinationController.text.trim(),
        destinationImage: destImage,
        startDate: _startDate,
        endDate: _endDate,
        numberOfTravelers: travelers,
        plannedBudget: budget,
        travelStyle: _travelStyle,
        notes: _notesController.text.trim(),
      );
    }

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.tripToEdit != null
                ? 'Trip updated successfully!'
                : 'Trip created successfully! 🎉',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEditing = widget.tripToEdit != null;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.creamSurface,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 650),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isEditing ? 'Edit Trip' : 'Plan a New Trip',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 12),

                  // Trip Title
                  Text(
                    'Trip Name *',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      hintText: 'e.g. Goa Weekend Holiday',
                      prefixIcon: Icon(Icons.flight_takeoff_rounded, size: 20),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Please enter a trip name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  // Destination
                  Text(
                    'Destination *',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _destinationController,
                    decoration: const InputDecoration(
                      hintText: 'e.g. Goa, India',
                      prefixIcon: Icon(Icons.location_on_rounded, size: 20),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Please specify destination';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  // Dates Picker
                  Text(
                    'Trip Dates *',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 6),
                  InkWell(
                    onTap: () => _pickDateRange(context),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isDark
                              ? AppColors.dividerDark
                              : AppColors.dividerLight,
                        ),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_month_rounded,
                                size: 18,
                                color: AppColors.forestGreen,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                Formatters.formatDateRange(
                                  _startDate,
                                  _endDate,
                                ),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.mutedSage.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${Formatters.daysBetween(_startDate, _endDate)} days',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.forestGreen,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Budget & Travelers Row
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Planned Budget (₹) *',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimaryLight,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _budgetController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                hintText: '25000',
                                prefixIcon: Icon(
                                  Icons.currency_rupee_rounded,
                                  size: 18,
                                  color: AppColors.forestGreen,
                                ),
                              ),
                              validator: (val) {
                                if (val == null ||
                                    double.tryParse(val.trim()) == null) {
                                  return 'Enter amount';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Travelers',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimaryLight,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _travelersController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                hintText: '1',
                                prefixIcon: Icon(
                                  Icons.people_rounded,
                                  size: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Travel Style Dropdown
                  Text(
                    'Travel Style',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isDark
                            ? AppColors.dividerDark
                            : AppColors.dividerLight,
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _travelStyle,
                        isExpanded: true,
                        items: _travelStyles.map((style) {
                          return DropdownMenuItem(
                            value: style,
                            child: Text(
                              style,
                              style: const TextStyle(fontSize: 14),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _travelStyle = val);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Notes
                  Text(
                    'Notes & Travel Wishlist',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _notesController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      hintText:
                          'e.g. Pack beachwear, try authentic vindaloo...',
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveTrip,
                      child: Text(isEditing ? 'Save Changes' : 'Create Trip'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
