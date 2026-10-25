import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../features/trips/create_edit_trip_dialog.dart';
import '../../models/destination.dart';
import '../../providers/destination_provider.dart';
import '../../providers/trip_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../services/travel_buddy_service.dart';
import '../../widgets/app_network_image.dart';
import '../../widgets/rating_badge.dart';

/// Full-screen interactive AI Travel Companion interface.
class TravelBuddyScreen extends StatefulWidget {
  const TravelBuddyScreen({super.key});

  @override
  State<TravelBuddyScreen> createState() => _TravelBuddyScreenState();
}

class _TravelBuddyScreenState extends State<TravelBuddyScreen> {
  late final TravelBuddyService _assistantService;
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _assistantService = TravelBuddyService();
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleSendMessage([String? overrideText]) async {
    final text = overrideText ?? _inputController.text;
    if (text.trim().isEmpty || _isGenerating) return;

    _inputController.clear();
    setState(() => _isGenerating = true);
    _scrollToBottom();

    final destProvider = context.read<DestinationProvider>();
    final wishlistProvider = context.read<WishlistProvider>();
    final tripProvider = context.read<TripProvider>();

    double totalSpent = 0.0;
    for (final trip in tripProvider.trips) {
      totalSpent += tripProvider.getTotalSpentForTrip(trip.id);
    }

    await _assistantService.processUserMessage(
      userText: text,
      allDestinations: destProvider.allDestinations,
      wishlistDestinations: wishlistProvider.getWishlistedDestinations(
        destProvider.allDestinations,
      ),
      trips: tripProvider.trips,
      totalActualExpenses: totalSpent,
    );

    if (mounted) {
      setState(() => _isGenerating = false);
      _scrollToBottom();
    }
  }

  void _confirmClearChat() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear Conversation?'),
        content: const Text(
          'This will restart your conversation with Travel Buddy and reset the session context.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _assistantService.clearConversation();
              });
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showAddToTripDialog(BuildContext context, Destination destination) {
    showDialog(
      context: context,
      builder: (ctx) => CreateEditTripDialog(
        initialDestinationId: destination.id,
        initialDestinationName: '${destination.name}, ${destination.state}',
        initialImage: destination.imageUrl,
        initialBudget:
            destination.estimatedDailyCost * destination.suggestedDurationDays,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final messages = _assistantService.messages;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.forestGreen, AppColors.forestGreenLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.forestGreen.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Center(
                child: Text('🌿', style: TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Travel Buddy',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'AI Companion • Ready',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? AppColors.textMutedDark
                            : AppColors.textMutedLight,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            tooltip: 'Clear conversation',
            onPressed: messages.length > 1 ? _confirmClearChat : null,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Messages List
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                itemCount: messages.length + (_isGenerating ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == messages.length && _isGenerating) {
                    return _buildTypingIndicator(isDark);
                  }
                  final msg = messages[index];
                  return _buildMessageBubble(context, msg, isDark);
                },
              ),
            ),

            // Suggested Prompt Chips
            Container(
              height: 44,
              padding: const EdgeInsets.only(bottom: 6),
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: TravelBuddyService.defaultSuggestedPrompts.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final prompt =
                      TravelBuddyService.defaultSuggestedPrompts[index];
                  return ActionChip(
                    avatar: Icon(
                      Icons.auto_awesome_rounded,
                      size: 14,
                      color:
                          isDark ? AppColors.mutedSage : AppColors.forestGreen,
                    ),
                    label: Text(prompt, style: const TextStyle(fontSize: 12)),
                    backgroundColor: isDark
                        ? AppColors.surfaceDark
                        : AppColors.creamSurface,
                    side: BorderSide(
                      color: isDark
                          ? AppColors.dividerDark
                          : AppColors.creamBorder,
                    ),
                    onPressed: () => _handleSendMessage(prompt),
                  );
                },
              ),
            ),

            // Input Bar
            Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
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
                  Expanded(
                    child: TextField(
                      controller: _inputController,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _handleSendMessage(),
                      decoration: InputDecoration(
                        hintText: 'Ask Travel Buddy anything...',
                        filled: true,
                        fillColor: isDark
                            ? AppColors.backgroundDark
                            : AppColors.creamSurface,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          borderSide: BorderSide(
                            color: isDark
                                ? AppColors.dividerDark
                                : AppColors.creamBorder,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.mutedSage
                          : AppColors.forestGreen,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.send_rounded,
                        color:
                            isDark ? AppColors.charcoal : AppColors.warmCream,
                        size: 20,
                      ),
                      onPressed: _handleSendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.surfaceDark
                  : AppColors.mutedSageLight,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('🌿', style: TextStyle(fontSize: 16)),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.creamSurface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(
                color: isDark ? AppColors.dividerDark : AppColors.creamBorder,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isDark ? AppColors.mutedSage : AppColors.forestGreen,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Travel Buddy is thinking...',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(
    BuildContext context,
    ChatMessage msg,
    bool isDark,
  ) {
    if (msg.isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12, left: 48),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.mutedSage : AppColors.forestGreen,
            borderRadius: BorderRadius.circular(AppRadius.lg)
                .copyWith(bottomRight: const Radius.circular(4)),
            boxShadow: [
              BoxShadow(
                color: (isDark ? AppColors.mutedSage : AppColors.forestGreen)
                    .withOpacity(0.2),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            msg.text,
            style: TextStyle(
              color: isDark ? AppColors.charcoal : AppColors.warmCream,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ),
      );
    }

    // Assistant Message
    final wishlistProvider = context.watch<WishlistProvider>();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.surfaceDark
                  : AppColors.mutedSageLight,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('🌿', style: TextStyle(fontSize: 16)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Text bubble
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.surfaceDark
                        : AppColors.creamSurface,
                    borderRadius: BorderRadius.circular(AppRadius.lg)
                        .copyWith(topLeft: const Radius.circular(4)),
                    border: Border.all(
                      color: isDark
                          ? AppColors.dividerDark
                          : AppColors.creamBorder,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    msg.text,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.45,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                ),

                // Interactive Destination Cards (if attached)
                if (msg.destinations.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  ...msg.destinations.map((dest) {
                    final isSaved = wishlistProvider.isWishlisted(dest.id);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.surfaceDark
                            : AppColors.creamSurface,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        border: Border.all(
                          color: dest.palette.currentBorder(isDark),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Image with badges
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(AppRadius.lg),
                            ),
                            child: Stack(
                              children: [
                                AppNetworkImage(
                                  imageUrl: dest.imageUrl,
                                  height: 130,
                                  width: double.infinity,
                                ),
                                Positioned(
                                  top: 8,
                                  left: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: dest.palette.badgeBackground,
                                      borderRadius: BorderRadius.circular(
                                        AppRadius.sm,
                                      ),
                                    ),
                                    child: Text(
                                      dest.category.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: dest.palette.badgeText,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Material(
                                    color: Colors.black.withOpacity(0.4),
                                    shape: const CircleBorder(),
                                    child: InkWell(
                                      customBorder: const CircleBorder(),
                                      onTap: () {
                                        wishlistProvider.toggleWishlist(
                                          dest.id,
                                        );
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(6),
                                        child: Icon(
                                          isSaved
                                              ? Icons.favorite_rounded
                                              : Icons.favorite_border_rounded,
                                          size: 16,
                                          color: isSaved
                                              ? AppColors.terracotta
                                              : Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Destination Info & Action Row
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        dest.name,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    RatingBadge(
                                      rating: dest.rating,
                                      compact: true,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${dest.city}, ${dest.state}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark
                                        ? AppColors.textMutedDark
                                        : AppColors.textMutedLight,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  dest.description,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondaryLight,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '~${Formatters.formatCurrency(dest.estimatedDailyCost)} / day',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: dest.palette.currentPrimary(
                                          isDark,
                                        ),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        OutlinedButton(
                                          onPressed: () => _showAddToTripDialog(
                                            context,
                                            dest,
                                          ),
                                          style: OutlinedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 6,
                                            ),
                                            minimumSize: Size.zero,
                                            tapTargetSize: MaterialTapTargetSize
                                                .shrinkWrap,
                                          ),
                                          child: const Text(
                                            'Add to Trip',
                                            style: TextStyle(fontSize: 11),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        ElevatedButton(
                                          onPressed: () => context.push(
                                            '/destination/${dest.id}',
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            minimumSize: Size.zero,
                                            tapTargetSize: MaterialTapTargetSize
                                                .shrinkWrap,
                                          ),
                                          child: const Text(
                                            'Details',
                                            style: TextStyle(fontSize: 11),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],

                // Action Navigation Buttons
                if (msg.actionButtons.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: msg.actionButtons.map((btn) {
                      return OutlinedButton.icon(
                        icon: Icon(
                          btn.icon ?? Icons.arrow_forward_rounded,
                          size: 14,
                        ),
                        label: Text(
                          btn.label,
                          style: const TextStyle(fontSize: 12),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () {
                          if (btn.route.startsWith('/')) {
                            context.push(btn.route);
                          } else if (btn.route == 'action_show_more') {
                            _handleSendMessage('show more');
                          } else {
                            _handleSendMessage(btn.route);
                          }
                        },
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
