import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../models/itinerary_activity.dart';
import '../../models/trip.dart';

class AddEditActivityDialog extends StatefulWidget {
  final Trip trip;
  final ItineraryActivity? activityToEdit;
  final int defaultDay;

  const AddEditActivityDialog({
    super.key,
    required this.trip,
    this.activityToEdit,
    this.defaultDay = 1,
  });

  @override
  State<AddEditActivityDialog> createState() => _AddEditActivityDialogState();
}

class _AddEditActivityDialogState extends State<AddEditActivityDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _locationController;
  late TextEditingController _timeController;
  late TextEditingController _notesController;
  late int _selectedDay;

  @override
  void initState() {
    super.initState();
    final a = widget.activityToEdit;
    _titleController = TextEditingController(text: a?.title ?? '');
    _locationController = TextEditingController(
      text: a?.locationName ?? widget.trip.destinationName,
    );
    _timeController = TextEditingController(text: a?.time ?? '10:00 AM');
    _notesController = TextEditingController(text: a?.notes ?? '');
    _selectedDay = a?.dayNumber ?? widget.defaultDay;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _timeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 10, minute: 0),
    );
    if (picked != null) {
      final formatted = picked.format(context);
      setState(() {
        _timeController.text = formatted;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEditing = widget.activityToEdit != null;
    final totalDays = widget.trip.totalDays;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.creamSurface,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(20),
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
                        isEditing ? 'Edit Activity' : 'Add Activity',
                        style: TextStyle(
                          fontSize: 18,
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

                  // Day Selector
                  Text(
                    'Itinerary Day',
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
                      child: DropdownButton<int>(
                        value: _selectedDay,
                        isExpanded: true,
                        items: List.generate(totalDays, (index) {
                          final dayNum = index + 1;
                          final date = widget.trip.startDate.add(
                            Duration(days: index),
                          );
                          return DropdownMenuItem<int>(
                            value: dayNum,
                            child: Text(
                              'Day $dayNum (${date.day}/${date.month})',
                              style: const TextStyle(fontSize: 14),
                            ),
                          );
                        }),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedDay = val);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Title
                  Text(
                    'Activity Title *',
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
                      hintText: 'e.g. Scuba diving, Fort tour, Sunset cruise',
                      prefixIcon: Icon(Icons.directions_walk_rounded, size: 20),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Please enter activity title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  // Location
                  Text(
                    'Location Name',
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
                    controller: _locationController,
                    decoration: const InputDecoration(
                      hintText: 'e.g. Baga Beach, Amer Fort',
                      prefixIcon: Icon(Icons.location_on_rounded, size: 20),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Time
                  Text(
                    'Time',
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
                    controller: _timeController,
                    readOnly: true,
                    onTap: _pickTime,
                    decoration: const InputDecoration(
                      hintText: 'Select Time',
                      prefixIcon: Icon(Icons.access_time_rounded, size: 20),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Notes
                  Text(
                    'Notes / Reminders',
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
                      hintText: 'e.g. Carry towel, book guide in advance...',
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Action
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (!_formKey.currentState!.validate()) return;
                        final date = widget.trip.startDate.add(
                          Duration(days: _selectedDay - 1),
                        );
                        Navigator.pop(context, {
                          'dayNumber': _selectedDay,
                          'date': date,
                          'title': _titleController.text.trim(),
                          'locationName': _locationController.text.trim(),
                          'time': _timeController.text.trim(),
                          'notes': _notesController.text.trim(),
                        });
                      },
                      child: Text(isEditing ? 'Save Activity' : 'Add Activity'),
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
