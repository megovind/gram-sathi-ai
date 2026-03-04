import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../data/models/message_model.dart';
import 'formatted_message.dart';

class MessageBubble extends StatelessWidget {
  final MessageModel message;
  final Widget? audioWidget;

  const MessageBubble({super.key, required this.message, this.audioWidget});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    if (isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: _BubbleContainer(
          isUser: true,
          margin: const EdgeInsets.only(top: 4, bottom: 4, left: 64),
          message: message,
          audioWidget: audioWidget,
        ),
      );
    }

    // Assistant: avatar + bubble + optional facility cards below
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _AssistantAvatar(),
              const SizedBox(width: 6),
              Flexible(
                child: _BubbleContainer(
                  isUser: false,
                  margin: const EdgeInsets.only(top: 4, bottom: 4, right: 64),
                  message: message,
                  audioWidget: audioWidget,
                ),
              ),
            ],
          ),
          if (message.facilities.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 34, right: 16, bottom: 4),
              child: _FacilityResultsList(
                facilities: message.facilities,
                nearbyKind: message.nearbyKind,
              ),
            ),
        ],
      ),
    );
  }
}

class _BubbleContainer extends StatelessWidget {
  final bool isUser;
  final EdgeInsets margin;
  final MessageModel message;
  final Widget? audioWidget;

  const _BubbleContainer({
    required this.isUser,
    required this.margin,
    required this.message,
    this.audioWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isUser ? AppColors.userBubble : AppColors.assistantBubble,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(18),
          topRight: const Radius.circular(18),
          bottomLeft: Radius.circular(isUser ? 18 : 4),
          bottomRight: Radius.circular(isUser ? 4 : 18),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (message.isVoiceMessage)
            _VoiceMessageContent(isUploading: message.isUploading)
          else if (!isUser && message.facilities.isNotEmpty)
            // When structured cards are shown below, replace the TTS paragraph
            // with a compact intro line so results aren't duplicated.
            _NearbyIntroLine(
              count: message.facilities.length,
              kind: message.nearbyKind,
            )
          else
            FormattedMessage(
              text: message.content,
              textColor: isUser ? Colors.white : AppColors.textPrimary,
              isUser: isUser,
            ),
          if (audioWidget != null) ...[
            const SizedBox(height: 8),
            audioWidget!,
          ],
          const SizedBox(height: 4),
          _Timestamp(
            timestamp: message.timestamp,
            isUser: isUser,
          ),
        ],
      ),
    );
  }
}

class _AssistantAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      margin: const EdgeInsets.only(bottom: 4),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.smart_toy_outlined, color: Colors.white, size: 16),
    );
  }
}

class _VoiceMessageContent extends StatelessWidget {
  final bool isUploading;
  const _VoiceMessageContent({this.isUploading = false});

  @override
  Widget build(BuildContext context) {
    if (isUploading) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white70,
            ),
          ),
          SizedBox(width: 8),
          Text(
            'Sending...',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.mic_rounded, color: Colors.white70, size: 16),
        const SizedBox(width: 6),
        Row(
          children: List.generate(
            10,
            (i) => Container(
              width: 3,
              height: (i % 3 == 0 ? 14 : i % 2 == 0 ? 10 : 6).toDouble(),
              margin: const EdgeInsets.symmetric(horizontal: 1.5),
              decoration: BoxDecoration(
                color: Colors.white60,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Timestamp extends StatelessWidget {
  final DateTime timestamp;
  final bool isUser;

  const _Timestamp({required this.timestamp, required this.isUser});

  @override
  Widget build(BuildContext context) {
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Text(
        '$hour:$minute',
        style: TextStyle(
          fontSize: 10,
          color: isUser ? Colors.white54 : AppColors.textHint,
        ),
      ),
    );
  }
}

// ── Compact intro shown inside the bubble when facility cards are present ─────

class _NearbyIntroLine extends StatelessWidget {
  final int count;
  final String kind;

  const _NearbyIntroLine({required this.count, required this.kind});

  IconData get _icon {
    switch (kind) {
      case 'pharmacy':
        return Icons.local_pharmacy_outlined;
      case 'shops':
        return Icons.storefront_outlined;
      default:
        return Icons.local_hospital_outlined;
    }
  }

  String get _label {
    switch (kind) {
      case 'clinic':
        return '$count ${AppStrings.filterClinics.toLowerCase()} found nearby';
      case 'pharmacy':
        return '$count ${AppStrings.filterPharmacy.toLowerCase()} found nearby';
      case 'hospital':
        return '$count hospital(s) found nearby';
      case 'shops':
        return '$count shop(s) found nearby';
      default:
        return '$count ${AppStrings.facilitiesFound}';
    }
  }

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(
            _label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
}

// ── Nearby facility results rendered below the assistant bubble ───────────────

class _FacilityResultsList extends StatelessWidget {
  final List<Map<String, dynamic>> facilities;
  final String nearbyKind;

  const _FacilityResultsList({required this.facilities, required this.nearbyKind});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(
            '${facilities.length} ${AppStrings.facilitiesFound}',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        ...facilities.map((f) => _InlineFacilityCard(facility: f)),
      ],
    );
  }
}

class _InlineFacilityCard extends StatelessWidget {
  final Map<String, dynamic> facility;

  const _InlineFacilityCard({required this.facility});

  bool get _isPharmacy =>
      (facility['category'] as String? ?? '').toLowerCase() == 'pharmacy';
  bool get _isShop =>
      (facility['category'] as String? ?? '').toLowerCase() == 'shop';

  @override
  Widget build(BuildContext context) {
    final phone = facility['phone'] as String?;
    final hasPhone = phone != null && phone.isNotEmpty;

    final Color accentColor;
    final IconData icon;
    final String badge;
    if (_isPharmacy) {
      accentColor = const Color(0xFF9B59B6);
      icon = Icons.local_pharmacy_outlined;
      badge = AppStrings.filterPharmacy;
    } else if (_isShop) {
      accentColor = AppColors.accent;
      icon = Icons.storefront_outlined;
      badge = 'Shop';
    } else {
      accentColor = AppColors.secondary;
      icon = Icons.local_hospital_outlined;
      badge = AppStrings.filterClinics;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: accentColor, width: 3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: accentColor, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          facility['name'] as String? ?? '',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: accentColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          badge,
                          style: TextStyle(
                            color: accentColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (facility['rating'] != null) ...[
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            size: 13, color: Color(0xFFF59E0B)),
                        const SizedBox(width: 3),
                        Text(
                          (facility['rating'] as num).toStringAsFixed(1),
                          style: const TextStyle(
                              color: Color(0xFFF59E0B),
                              fontSize: 12,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                  if (facility['address'] != null) ...[
                    const SizedBox(height: 3),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.location_on_outlined,
                            size: 12, color: AppColors.textSecondary),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            facility['address'] as String,
                            style: const TextStyle(
                                color: AppColors.textSecondary, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (hasPhone) ...[
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: () async {
                        await Clipboard.setData(ClipboardData(text: phone!));
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(AppStrings.phoneCopied),
                              duration: Duration(seconds: 2),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.phone_outlined, size: 12, color: accentColor),
                          const SizedBox(width: 4),
                          Text(
                            phone!,
                            style: TextStyle(
                              color: accentColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.copy_outlined,
                              size: 11, color: AppColors.textHint),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
