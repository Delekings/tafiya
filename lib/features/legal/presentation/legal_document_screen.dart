import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';

/// Generic viewer for any legal/policy document (markdown body).
class LegalDocumentScreen extends StatelessWidget {
  final String title;
  final String updatedLabel;
  final String body;

  const LegalDocumentScreen({
    super.key,
    required this.title,
    required this.updatedLabel,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(title),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.lg),
        children: [
          Text(title, style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: 4),
          Text(
            updatedLabel,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textTertiary,
                ),
          ),
          const SizedBox(height: AppSizes.lg),
          _MarkdownBody(text: body),
          const SizedBox(height: AppSizes.xl),
        ],
      ),
    );
  }
}

// =============================================
// Lightweight markdown renderer
// Supports: ## headers, ### subheaders, **bold**, *italic*, - bullets
// =============================================
class _MarkdownBody extends StatelessWidget {
  final String text;
  const _MarkdownBody({required this.text});

  @override
  Widget build(BuildContext context) {
    final blocks = text.trim().split(RegExp(r'\n\s*\n'));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: blocks.map((block) {
        final trimmed = block.trim();

        // ## Heading
        if (trimmed.startsWith('## ')) {
          return Padding(
            padding: const EdgeInsets.only(
                top: AppSizes.lg, bottom: AppSizes.sm),
            child: _InlineRichText(
              text: trimmed.substring(3),
              baseStyle: Theme.of(context).textTheme.headlineSmall,
            ),
          );
        }

        // ### Subheading
        if (trimmed.startsWith('### ')) {
          return Padding(
            padding: const EdgeInsets.only(
                top: AppSizes.md, bottom: 6),
            child: _InlineRichText(
              text: trimmed.substring(4),
              baseStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          );
        }

        // #### Subheading
        if (trimmed.startsWith('#### ')) {
          return Padding(
            padding: const EdgeInsets.only(top: AppSizes.sm, bottom: 4),
            child: _InlineRichText(
              text: trimmed.substring(5),
              baseStyle: Theme.of(context).textTheme.titleMedium,
            ),
          );
        }

        // Bullet list
        if (trimmed.startsWith('- ')) {
          final items = trimmed
              .split('\n')
              .where((l) => l.trim().startsWith('- '))
              .map((l) => l.trim().substring(2))
              .toList();
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSizes.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: items
                  .map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(top: 8),
                              child: Icon(Icons.circle,
                                  size: 5, color: AppColors.primary),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _InlineRichText(text: item),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          );
        }

        // Regular paragraph
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSizes.md),
          child: _InlineRichText(text: trimmed),
        );
      }).toList(),
    );
  }
}

/// Renders inline **bold** and *italic* text within a paragraph.
class _InlineRichText extends StatelessWidget {
  final String text;
  final TextStyle? baseStyle;
  const _InlineRichText({required this.text, this.baseStyle});

  @override
  Widget build(BuildContext context) {
    final spans = <TextSpan>[];
    final pattern = RegExp(r'(\*\*[^*]+\*\*|\*[^*]+\*)');
    int lastEnd = 0;

    for (final match in pattern.allMatches(text)) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(text: text.substring(lastEnd, match.start)));
      }
      final m = match.group(0)!;
      if (m.startsWith('**')) {
        spans.add(TextSpan(
          text: m.substring(2, m.length - 2),
          style: const TextStyle(fontWeight: FontWeight.w700),
        ));
      } else {
        spans.add(TextSpan(
          text: m.substring(1, m.length - 1),
          style: const TextStyle(fontStyle: FontStyle.italic),
        ));
      }
      lastEnd = match.end;
    }
    if (lastEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastEnd)));
    }

    final defaultStyle = Theme.of(context).textTheme.bodyLarge?.copyWith(
          height: 1.6,
          color: AppColors.textPrimary,
          fontSize: 15,
        );

    return RichText(
      text: TextSpan(
        style: baseStyle ?? defaultStyle,
        children: spans,
      ),
    );
  }
}
