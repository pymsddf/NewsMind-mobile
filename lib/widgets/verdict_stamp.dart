import 'package:flutter/material.dart';
import '../theme/intelligence_design_system.dart';

/// Maps a raw verdict string to its editorial color + display word.
class Verdict {
  final Color color;
  final String word;
  final IconData icon;
  const Verdict(this.color, this.word, this.icon);

  static Verdict of(String raw) {
    switch (raw.toUpperCase().trim()) {
      case 'TRUE':
      case 'VERIFIED':
      case 'ACCURATE':
        return Verdict(AppColors.verified, 'TRUE', Icons.verified_rounded);
      case 'FALSE':
      case 'INACCURATE':
      case 'DEBUNKED':
        return Verdict(AppColors.redline, 'FALSE', Icons.gpp_bad_rounded);
      case 'MISLEADING':
      case 'MIXED':
      case 'PARTIAL':
        return Verdict(AppColors.caution, 'MISLEADING', Icons.warning_amber_rounded);
      default:
        return Verdict(AppColors.neutral, 'UNVERIFIED', Icons.help_outline_rounded);
    }
  }
}

/// The verdict stamp — a slightly-canted, double-ruled editorial stamp. The
/// signature moment of a fact-check result.
class VerdictStamp extends StatelessWidget {
  final String verdict;
  final int? confidence; // 0-100
  final bool flash;

  const VerdictStamp({
    super.key,
    required this.verdict,
    this.confidence,
    this.flash = false,
  });

  @override
  Widget build(BuildContext context) {
    final v = Verdict.of(verdict);
    return Transform.rotate(
      angle: -0.035,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 280),
        padding: EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: flash ? v.color.withValues(alpha: 0.16) : v.color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: v.color, width: 2.5),
        ),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: Border.all(color: v.color.withValues(alpha: 0.55), width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(v.icon, color: v.color, size: 16),
                  SizedBox(width: 6),
                  Text('VERDICT',
                      style: AppType.ui(
                          size: 11,
                          weight: FontWeight.w700,
                          color: v.color,
                          letterSpacing: 3)),
                ],
              ),
              SizedBox(height: 6),
              Text(
                v.word,
                style: AppType.headline(
                  size: v.word.length > 6 ? 36 : 52,
                  weight: FontWeight.w700,
                  color: v.color,
                  height: 1,
                  letterSpacing: 1,
                  fontStyle: FontStyle.italic,
                ),
              ),
              if (confidence != null && confidence! > 0) ...[
                SizedBox(height: 8),
                // Backend confidence is a 1–10 score; show it as a percentage
                // (9 → 90%). Values already in 0–100 are passed through.
                Text(
                    '${confidence! <= 10 ? confidence! * 10 : confidence!}% CONFIDENCE',
                    textAlign: TextAlign.center,
                    style: AppType.data(
                        size: 11, weight: FontWeight.w500, color: AppColors.graphite)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Proof mark — a single finding rendered like a copyeditor's margin note:
/// a colored tick in the margin, then the note.
class ProofMark extends StatelessWidget {
  final String text;
  final Color? color;
  final IconData icon;

  const ProofMark({
    super.key,
    required this.text,
    this.color,
    this.icon = Icons.short_text_rounded,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.neutral;
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpace.sm + 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: c.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(icon, size: 15, color: c),
          ),
          SizedBox(width: AppSpace.sm + 2),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 3),
              child: Text(
                text,
                style: AppType.display(size: 14.5, color: AppColors.ink, height: 1.45),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Small uppercase section label with a short redline rule beneath it —
/// the recurring "desk" header used across result panels.
class DeskLabel extends StatelessWidget {
  final String label;
  final Color? accent;
  const DeskLabel(this.label, {super.key, this.accent});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // scaleDown keeps the label on one line in narrow columns instead of
        // wrapping mid-word (e.g. "CREDIBILITY" → "CREDIBILI / TY").
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(label.toUpperCase(),
              maxLines: 1,
              softWrap: false,
              style: AppType.ui(
                  size: 11,
                  weight: FontWeight.w700,
                  color: AppColors.graphite,
                  letterSpacing: 1.6)),
        ),
        SizedBox(height: 5),
        Container(width: 26, height: 2.5, color: accent ?? AppColors.redline),
      ],
    );
  }
}
