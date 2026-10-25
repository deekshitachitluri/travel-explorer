import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../models/home_preferences.dart';

/// Modal panel displayed when tapping the Home search bar filter icon.
///
/// Designed specifically for personalizing discovery recommendations,
/// distinctly separate from Explore's catalogue-browsing filters.
class HomePreferencesPanel extends StatefulWidget {
  final HomePreferences initialPreferences;
  final ValueChanged<HomePreferences> onApply;
  final VoidCallback onReset;

  const HomePreferencesPanel({
    super.key,
    required this.initialPreferences,
    required this.onApply,
    required this.onReset,
  });

  static Future<void> show({
    required BuildContext context,
    required HomePreferences initialPreferences,
    required ValueChanged<HomePreferences> onApply,
    required VoidCallback onReset,
  }) {
    final isDesktop = MediaQuery.of(context).size.width >= 700;

    if (isDesktop) {
      return showDialog(
        context: context,
        builder: (ctx) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 40,
            vertical: 24,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620, maxHeight: 780),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.xl),
              child: HomePreferencesPanel(
                initialPreferences: initialPreferences,
                onApply: onApply,
                onReset: onReset,
              ),
            ),
          ),
        ),
      );
    }

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => FractionallySizedBox(
        heightFactor: 0.90,
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppRadius.xl),
          ),
          child: HomePreferencesPanel(
            initialPreferences: initialPreferences,
            onApply: onApply,
            onReset: onReset,
          ),
        ),
      ),
    );
  }

  @override
  State<HomePreferencesPanel> createState() => _HomePreferencesPanelState();
}

class _HomePreferencesPanelState extends State<HomePreferencesPanel> {
  late List<String> _selectedVibes;
  late List<String> _selectedScenery;
  late String _selectedBudget;
  double? _customMaxBudget;
  late String _selectedDuration;
  late String _selectedPriority;
  late List<String> _selectedSeasons;

  static const List<String> _vibesList = [
    'Peaceful & Relaxing',
    'Adventure',
    'Nature & Wildlife',
    'Culture & Heritage',
    'Food & Local Experiences',
    'Romantic Getaway',
    'Photography & Scenic Views',
  ];

  static const List<String> _sceneryList = [
    'Beaches',
    'Mountains',
    'Forests',
    'Lakes',
    'Historic Cities',
  ];

  static const List<String> _budgetOptions = [
    'Any',
    'Budget-friendly',
    'Moderate',
    'Flexible',
  ];

  static const List<String> _durationOptions = [
    'Any',
    'Day trip',
    'Weekend (2–3 days)',
    '4–7 days',
    'Longer vacation (8+ days)',
  ];

  static const List<String> _priorityOptions = [
    'Matching interests',
    'Similar to wishlist',
    'Popular destinations',
    'New places to explore',
  ];

  static const List<String> _seasonsList = [
    'All seasons',
    'Spring',
    'Summer',
    'Monsoon',
    'Autumn',
    'Winter',
  ];

  @override
  void initState() {
    super.initState();
    _selectedVibes = List<String>.from(widget.initialPreferences.travelVibes);
    _selectedScenery = List<String>.from(
      widget.initialPreferences.preferredScenery,
    );
    _selectedBudget = widget.initialPreferences.budgetPreference;
    _customMaxBudget = widget.initialPreferences.customMaxBudget;
    _selectedDuration = widget.initialPreferences.tripDuration;
    _selectedPriority = widget.initialPreferences.recommendationPriority;
    _selectedSeasons = List<String>.from(
      widget.initialPreferences.preferredSeasons,
    );
  }

  void _handleReset() {
    setState(() {
      _selectedVibes = [];
      _selectedScenery = [];
      _selectedBudget = 'Any';
      _customMaxBudget = null;
      _selectedDuration = 'Any';
      _selectedPriority = 'Matching interests';
      _selectedSeasons = [];
    });
    widget.onReset();
    Navigator.of(context).pop();
  }

  void _handleApply() {
    final updated = HomePreferences(
      travelVibes: _selectedVibes,
      preferredScenery: _selectedScenery,
      budgetPreference: _selectedBudget,
      customMaxBudget: _customMaxBudget,
      tripDuration: _selectedDuration,
      recommendationPriority: _selectedPriority,
      preferredSeasons: _selectedSeasons,
    );
    widget.onApply(updated);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: isDark ? AppColors.surfaceDark : AppColors.creamSurface,
      child: Column(
        children: [
          // Drag handle on mobile
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.dividerDark : AppColors.creamBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 12, 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.surfaceDark
                        : AppColors.mutedSageLight,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Icon(
                    Icons.auto_awesome_rounded,
                    color: isDark ? AppColors.mutedSage : AppColors.forestGreen,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recommendation Preferences',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                        ),
                      ),
                      Text(
                        'Personalize what inspires your Home Feed',
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
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  tooltip: 'Cancel',
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Scrollable Preferences Form
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // A. Travel Vibe
                  _buildSectionTitle(
                    title: 'A. Travel Vibe',
                    subtitle: 'What kind of journey resonates with you today?',
                    isDark: isDark,
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _vibesList.map((vibe) {
                      final isSelected = _selectedVibes.contains(vibe);
                      return FilterChip(
                        label: Text(vibe),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedVibes.add(vibe);
                            } else {
                              _selectedVibes.remove(vibe);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // B. Preferred Scenery
                  _buildSectionTitle(
                    title: 'B. Preferred Scenery',
                    subtitle: 'Choose landscapes you would like to experience',
                    isDark: isDark,
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _sceneryList.map((scenery) {
                      final isSelected = _selectedScenery.contains(scenery);
                      return FilterChip(
                        label: Text(scenery),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedScenery.add(scenery);
                            } else {
                              _selectedScenery.remove(scenery);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // C. Budget Preference
                  _buildSectionTitle(
                    title: 'C. Budget Preference',
                    subtitle: 'Estimated daily cost per traveler (approximate)',
                    isDark: isDark,
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _budgetOptions.map((opt) {
                      final isSelected =
                          _selectedBudget == opt && _customMaxBudget == null;
                      return ChoiceChip(
                        label: Text(
                          opt == 'Budget-friendly'
                              ? 'Budget-friendly (≤ ₹2,500)'
                              : (opt == 'Moderate'
                                    ? 'Moderate (₹2,500–₹4,500)'
                                    : opt),
                        ),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedBudget = opt;
                              _customMaxBudget = null;
                            });
                          }
                        },
                      );
                    }).toList(),
                  ),

                  // Optional Custom Slider
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Or specify max daily budget:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                      Text(
                        _customMaxBudget != null
                            ? Formatters.formatCurrency(_customMaxBudget!)
                            : 'No cap',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryLight,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: _customMaxBudget ?? 6000,
                    min: 1500,
                    max: 6000,
                    divisions: 9,
                    label: _customMaxBudget != null
                        ? Formatters.formatCurrency(_customMaxBudget!)
                        : 'No cap',
                    onChanged: (val) {
                      setState(() {
                        if (val >= 6000) {
                          _customMaxBudget = null;
                        } else {
                          _customMaxBudget = val;
                          _selectedBudget = 'Custom';
                        }
                      });
                    },
                  ),

                  const SizedBox(height: 20),

                  // D. Trip Duration
                  _buildSectionTitle(
                    title: 'D. Trip Duration',
                    subtitle: 'How much time do you have for this getaway?',
                    isDark: isDark,
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _durationOptions.map((duration) {
                      final isSelected = _selectedDuration == duration;
                      return ChoiceChip(
                        label: Text(duration),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _selectedDuration = duration);
                          }
                        },
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // E. Recommendation Priorities
                  _buildSectionTitle(
                    title: 'E. Recommendation Focus',
                    subtitle: 'What should we prioritize in your personalized carousel?',
                    isDark: isDark,
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _priorityOptions.map((priority) {
                      final isSelected = _selectedPriority == priority;
                      return ChoiceChip(
                        label: Text(priority),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _selectedPriority = priority);
                          }
                        },
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // F. Preferred Season
                  _buildSectionTitle(
                    title: 'F. Preferred Season',
                    subtitle: 'When would you like to travel?',
                    isDark: isDark,
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _seasonsList.map((season) {
                      final isSelected = _selectedSeasons.contains(season) ||
                          (season == 'All seasons' && _selectedSeasons.isEmpty);
                      return FilterChip(
                        label: Text(season),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (season == 'All seasons') {
                              if (selected) {
                                _selectedSeasons = ['All seasons'];
                              } else {
                                _selectedSeasons.clear();
                              }
                            } else {
                              _selectedSeasons.remove('All seasons');
                              if (selected) {
                                _selectedSeasons.add(season);
                              } else {
                                _selectedSeasons.remove(season);
                              }
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Action Buttons
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.warmCream,
              border: Border(
                top: BorderSide(
                  color: isDark
                      ? AppColors.dividerDark
                      : AppColors.creamBorder,
                ),
              ),
            ),
            child: Row(
              children: [
                OutlinedButton(
                  onPressed: _handleReset,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  child: const Text('Reset'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.check_rounded, size: 18),
                    label: const Text('Apply Preferences'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: _handleApply,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle({
    required String title,
    required String subtitle,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 11,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }
}
