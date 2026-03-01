import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Parses AI assistant responses for common markdown-like patterns
/// and renders them with appropriate visual styling.
class FormattedMessage extends StatelessWidget {
  final String text;
  final Color textColor;
  final bool isUser;

  const FormattedMessage({
    super.key,
    required this.text,
    required this.textColor,
    required this.isUser,
  });

  @override
  Widget build(BuildContext context) {
    final blocks = _parseBlocks(text.trim());
    if (blocks.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < blocks.length; i++) ...[
          if (i > 0) const SizedBox(height: 6),
          _buildBlock(context, blocks[i]),
        ],
      ],
    );
  }

  Widget _buildBlock(BuildContext context, _Block block) {
    switch (block.type) {
      case _BlockType.header:
        return Text(
          block.text,
          style: TextStyle(
            color: textColor,
            fontSize: 15,
            fontWeight: FontWeight.w700,
            height: 1.4,
          ),
        );

      case _BlockType.bullet:
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 4, right: 8),
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: isUser ? Colors.white70 : AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Expanded(
              child: _buildRichText(block.text, textColor),
            ),
          ],
        );

      case _BlockType.numbered:
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text(
                '${block.number}.',
                style: TextStyle(
                  color: isUser ? Colors.white70 : AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
            Expanded(
              child: _buildRichText(block.text, textColor),
            ),
          ],
        );

      case _BlockType.divider:
        return Divider(
          color: isUser ? Colors.white24 : AppColors.divider,
          height: 12,
          thickness: 1,
        );

      case _BlockType.warning:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.warning.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.warning.withOpacity(0.4)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('⚠️ ', style: TextStyle(fontSize: 14)),
              Expanded(
                child: Text(
                  block.text,
                  style: TextStyle(
                    color: AppColors.warning,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        );

      case _BlockType.paragraph:
        return _buildRichText(block.text, textColor);
      default:
        return _buildRichText(block.text, textColor);
    }
  }

  Widget _buildRichText(String text, Color defaultColor) {
    final spans = _parseInline(text, defaultColor);
    if (spans.length == 1 && spans.first.style == null) {
      // Simple text — skip RichText overhead
      return Text(
        text,
        style: TextStyle(color: defaultColor, fontSize: 15, height: 1.5),
      );
    }
    return RichText(
      text: TextSpan(
        style: TextStyle(color: defaultColor, fontSize: 15, height: 1.5),
        children: spans,
      ),
    );
  }

  /// Parse inline markdown: **bold**, *italic*
  List<TextSpan> _parseInline(String text, Color defaultColor) {
    final spans = <TextSpan>[];
    final regex = RegExp(r'\*\*(.*?)\*\*|\*(.*?)\*');
    int last = 0;
    for (final match in regex.allMatches(text)) {
      if (match.start > last) {
        spans.add(TextSpan(text: text.substring(last, match.start)));
      }
      if (match.group(1) != null) {
        // **bold**
        spans.add(TextSpan(
          text: match.group(1),
          style: const TextStyle(fontWeight: FontWeight.w700),
        ));
      } else if (match.group(2) != null) {
        // *italic*
        spans.add(TextSpan(
          text: match.group(2),
          style: const TextStyle(fontStyle: FontStyle.italic),
        ));
      }
      last = match.end;
    }
    if (last < text.length) {
      spans.add(TextSpan(text: text.substring(last)));
    }
    return spans.isEmpty ? [TextSpan(text: text)] : spans;
  }

  List<_Block> _parseBlocks(String raw) {
    final lines = raw.split('\n');
    final blocks = <_Block>[];
    final numberedRe = RegExp(r'^(\d+)[.)]\s+(.+)');

    for (final line in lines) {
      final trimmed = line.trim();

      if (trimmed.isEmpty) continue;

      // Horizontal rule: --- or ***
      if (RegExp(r'^[-*]{3,}$').hasMatch(trimmed)) {
        blocks.add(_Block(type: _BlockType.divider, text: ''));
        continue;
      }

      // Warning line (starts with ⚠️ or explicit emergency keyword)
      if (trimmed.startsWith('⚠️') ||
          trimmed.toUpperCase().contains('EMERGENCY')) {
        final content = trimmed.replaceFirst(RegExp(r'^⚠️\s*'), '');
        blocks.add(_Block(type: _BlockType.warning, text: content));
        continue;
      }

      // Heading: starts with # or ## or ends with : and is short
      if (RegExp(r'^#{1,3}\s+').hasMatch(trimmed)) {
        blocks.add(_Block(
          type: _BlockType.header,
          text: trimmed.replaceFirst(RegExp(r'^#{1,3}\s+'), ''),
        ));
        continue;
      }

      // Bold heading (entire line is **...**)
      if (trimmed.startsWith('**') && trimmed.endsWith('**') && trimmed.length > 4) {
        blocks.add(_Block(
          type: _BlockType.header,
          text: trimmed.substring(2, trimmed.length - 2),
        ));
        continue;
      }

      // Section header: short line ending with colon
      if (trimmed.endsWith(':') &&
          !trimmed.contains('.') &&
          trimmed.length < 60 &&
          !trimmed.startsWith('-') &&
          !trimmed.startsWith('•')) {
        blocks.add(_Block(type: _BlockType.header, text: trimmed));
        continue;
      }

      // Bullet list item: -, •, *, →
      if (RegExp(r'^[-•*→]\s+').hasMatch(trimmed)) {
        blocks.add(_Block(
          type: _BlockType.bullet,
          text: trimmed.replaceFirst(RegExp(r'^[-•*→]\s+'), ''),
        ));
        continue;
      }

      // Numbered list
      final numMatch = numberedRe.firstMatch(trimmed);
      if (numMatch != null) {
        blocks.add(_Block(
          type: _BlockType.numbered,
          text: numMatch.group(2)!,
          number: int.tryParse(numMatch.group(1)!) ?? 1,
        ));
        continue;
      }

      // Plain paragraph
      blocks.add(_Block(type: _BlockType.paragraph, text: trimmed));
    }

    return blocks;
  }
}

enum _BlockType { paragraph, header, bullet, numbered, divider, warning }

class _Block {
  final _BlockType type;
  final String text;
  final int number;

  const _Block({required this.type, required this.text, this.number = 0});
}
