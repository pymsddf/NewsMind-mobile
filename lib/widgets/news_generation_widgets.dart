import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../models/article_model.dart';
import '../models/verification_model.dart';
import '../models/bias_model.dart';
import '../widgets/vector_card.dart';
import '../utils/share_util.dart';
import '../utils/title_format.dart';
import 'score_indicator.dart';
import 'markdown_text.dart';

String _capitalize(String s) =>
    s.isNotEmpty ? '${s[0].toUpperCase()}${s.substring(1)}' : s;

class GenerationDropdown extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const GenerationDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600)),
        SizedBox(height: 4),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppTheme.background,
            border: Border.all(color: AppTheme.borderColor),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: AppTheme.surface,
              style: TextStyle(color: AppTheme.textPrimary, fontSize: 14),
              items: items
                  .map((e) =>
                      DropdownMenuItem(value: e, child: Text(_capitalize(e))))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

class LoadingShimmer extends StatelessWidget {
  LoadingShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return VectorCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppTheme.primaryColor,
                ),
              ),
              SizedBox(width: 10),
              Text('Generating your article...',
                  style: TextStyle(
                      color: AppTheme.accentColor,
                      fontWeight: FontWeight.w600)),
            ],
          ),
          SizedBox(height: 20),
          ...List.generate(
              8,
              (i) => Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: Container(
                      height: 14,
                      width: i == 7 ? 160 : double.infinity,
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceLight.withValues(alpha: 0.3),
                      ),
                    ),
                  )),
        ],
      ),
    );
  }
}

class ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const ActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InlineLoading extends StatelessWidget {
  final String message;
  final Color color;

  const InlineLoading({
    super.key,
    required this.message,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 16),
      child: VectorCard(
        child: Row(
          children: [
            SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: color)),
            SizedBox(width: 12),
            Text(message,
                style: TextStyle(color: color, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class InlineVerificationResult extends StatelessWidget {
  final VerificationModel verificationResult;

  const InlineVerificationResult({
    super.key,
    required this.verificationResult,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 16),
      child: Column(
        children: [
          VectorCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.verified_user_rounded,
                        color: AppTheme.success, size: 20),
                    SizedBox(width: 8),
                    Text('Verification Result',
                        style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.bold)),
                    Spacer(),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: verificationResult.verdictColor
                            .withValues(alpha: 0.1),
                        border: Border.all(
                            color: verificationResult.verdictColor
                                .withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        verificationResult.verdict.toUpperCase(),
                        style: TextStyle(
                            color: verificationResult.verdictColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    ScoreIndicator(
                        score: verificationResult.credibilityScore,
                        size: 60,
                        label: 'Credibility'),
                    SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        verificationResult.summary.isNotEmpty
                            ? verificationResult.summary
                            : 'No summary available.',
                        style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 13,
                            height: 1.4),
                      ),
                    ),
                  ],
                ),
                if (verificationResult.keyFindings.isNotEmpty) ...[
                  SizedBox(height: 12),
                  Text('Key Findings:',
                      style:
                          TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                  SizedBox(height: 4),
                  ...verificationResult.keyFindings
                      .take(2)
                      .map((finding) => Padding(
                            padding: EdgeInsets.only(bottom: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.arrow_right_rounded,
                                    size: 16, color: AppTheme.textMuted),
                                Expanded(
                                  child: Text(
                                    finding,
                                    style: TextStyle(
                                        color: AppTheme.textSecondary,
                                        fontSize: 12),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          )),
                ],
                if (verificationResult.evidence.isNotEmpty) ...[
                  SizedBox(height: 8),
                  Text('Sources:',
                      style:
                          TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                  SizedBox(height: 4),
                  ...verificationResult.evidence.take(2).map((src) => Text(
                        '• ${src.title}${src.domain != null ? ' (${src.domain})' : ''}',
                        style: TextStyle(
                            color: AppTheme.textSecondary, fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )),
                ],
                SizedBox(height: 12),
                Divider(color: AppTheme.borderColor),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () =>
                          ShareUtil.shareVerification(verificationResult),
                      icon: Icon(Icons.share_rounded,
                          size: 16, color: AppTheme.textMuted),
                      label: Text('Share Result',
                          style: TextStyle(
                              color: AppTheme.textMuted, fontSize: 12)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class InlineBiasResult extends StatelessWidget {
  final BiasModel biasResult;

  const InlineBiasResult({
    super.key,
    required this.biasResult,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 16),
      child: VectorCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics_rounded,
                    color: AppTheme.warning, size: 20),
                SizedBox(width: 8),
                Text('Bias Analysis',
                    style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.bold)),
                Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: biasResult.overallBias.color.withValues(alpha: 0.1),
                    border: Border.all(
                        color: biasResult.overallBias.color
                            .withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    '${biasResult.overallBias.level} BIAS'.toUpperCase(),
                    style: TextStyle(
                        color: biasResult.overallBias.color,
                        fontSize: 10,
                        fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ScoreIndicator(
                  score: biasResult.overallBias.score,
                  size: 60,
                  label: 'Bias',
                  color: biasResult.overallBias.color,
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (biasResult.biasTypes.isNotEmpty) ...[
                        Text('Top Bias Types:',
                            style: TextStyle(
                                color: AppTheme.textMuted, fontSize: 11)),
                        SizedBox(height: 4),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: biasResult.biasTypes
                              .map((b) => Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: b.color.withValues(alpha: 0.1),
                                    ),
                                    child: Text(b.type,
                                        style: TextStyle(
                                            color: b.color, fontSize: 10)),
                                  ))
                              .toList(),
                        ),
                        SizedBox(height: 8),
                      ],
                      if (biasResult.keyFindings.isNotEmpty) ...[
                        Text('Key Findings:',
                            style: TextStyle(
                                color: AppTheme.textMuted, fontSize: 11)),
                        SizedBox(height: 4),
                        ...biasResult.keyFindings.take(2).map((finding) => Text(
                              '• $finding',
                              style: TextStyle(
                                  color: AppTheme.textSecondary, fontSize: 12),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            )),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Divider(color: AppTheme.borderColor),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => ShareUtil.shareBiasAnalysis(biasResult),
                  icon: Icon(Icons.share_rounded,
                      size: 16, color: AppTheme.textMuted),
                  label: Text('Share Analysis',
                      style:
                          TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class GeneratedArticleCard extends StatelessWidget {
  final ArticleModel article;
  final String style;
  final String tone;
  final VoidCallback onTranslate;
  final VoidCallback onVerify;
  final VoidCallback onAnalyzeBias;
  final void Function(String) onShowSnack;

  const GeneratedArticleCard({
    super.key,
    required this.article,
    required this.style,
    required this.tone,
    required this.onTranslate,
    required this.onVerify,
    required this.onAnalyzeBias,
    required this.onShowSnack,
  });

  @override
  Widget build(BuildContext context) {
    return VectorCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome, color: Colors.white, size: 14),
                    SizedBox(width: 4),
                    Text('AI Generated',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              Spacer(),
              IconButton(
                icon: Icon(Icons.g_translate_rounded,
                    size: 20, color: AppTheme.accentColor),
                onPressed: onTranslate,
                tooltip: 'Translate',
              ),
              IconButton(
                icon: Icon(Icons.copy_rounded,
                    size: 20, color: AppTheme.textMuted),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: article.content ?? ''));
                  onShowSnack('Copied to clipboard!');
                },
              ),
              IconButton(
                icon: Icon(Icons.share_rounded,
                    size: 20, color: AppTheme.textMuted),
                onPressed: () => ShareUtil.shareArticle(article),
              ),
            ],
          ),
          SizedBox(height: 12),

          // Title — strip any markdown so a history-stored markdown title
          // (e.g. "## Foo ### I") doesn't render as literal hashes.
          if (cleanTitle(article.title).isNotEmpty)
            Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Text(
                cleanTitle(article.title),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                  height: 1.3,
                ),
              ),
            ),

          // Content (markdown-rendered: headings, bold, lists, quotes)
          if (article.content != null) MarkdownText(article.content!),

          if (article.wordCount != null) ...[
            SizedBox(height: 16),
            Divider(color: AppTheme.borderColor),
            SizedBox(height: 8),
            Text(
              '${article.wordCount} words  •  ${_capitalize(style)}  •  ${_capitalize(tone)}',
              style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
            ),
          ],

          SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ActionButton(
                  icon: Icons.verified_rounded,
                  label: 'Verify Content',
                  color: AppTheme.success,
                  onPressed: onVerify,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: ActionButton(
                  icon: Icons.balance_rounded,
                  label: 'Check Bias',
                  color: AppTheme.warning,
                  onPressed: onAnalyzeBias,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
