// lib/features/map/presentation/widgets/expandable_text.dart
import 'package:flutter/material.dart';

class ExpandableText extends StatefulWidget {
  final String text;
  final int trimLines;
  final TextStyle? style;
  final Duration duration;
  final Curve curve;

  const ExpandableText(
      this.text, {
        Key? key,
        this.trimLines = 3,
        this.style,
        this.duration = const Duration(milliseconds: 200),
        this.curve = Curves.easeInOut,
      }) : super(key: key);

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Mesure si ça dépasse trimLines
        final tp = TextPainter(
          text: TextSpan(text: widget.text, style: widget.style),
          maxLines: widget.trimLines,
          textDirection: Directionality.of(context),
        )..layout(maxWidth: constraints.maxWidth);

        final overflows = tp.didExceedMaxLines;

        final text = Text(
          widget.text,
          style: widget.style,
          softWrap: true,
          overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
          maxLines: _expanded ? null : widget.trimLines,
        );

        return InkWell(
          onTap: overflows ? () => setState(() => _expanded = !_expanded) : null,
          child: Semantics(
            button: overflows,
            label: overflows
                ? (_expanded ? 'Réduire la description' : 'Afficher la description complète')
                : null,
            child: ClipRect(
              child: AnimatedSize(
                duration: widget.duration,
                curve: widget.curve,
                child: text,
              ),
            ),
          ),
        );
      },
    );
  }
}
