import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// Target for a platform-specific share button.
enum SharePlatform { whatsapp, linkedin, facebook, more }

class ShareUtil {
  /// Public URL used as the shareable link on platforms (Facebook/LinkedIn)
  /// that share a page rather than free text.
  static const String _siteUrl = 'https://newsmindai.ddfrl.com';

  static Future<void> shareText(String text, {String? subject}) async {
    await Share.share(text, subject: subject);
  }

  /// Open a share/deep-link URL in the relevant app (or browser fallback).
  static Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      try {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      } catch (_) {}
    }
  }

  /// Route a verdict to a specific platform. WhatsApp takes the full text;
  /// Facebook/LinkedIn open their composer (Facebook attaches our site link,
  /// LinkedIn pre-fills the text); "More" falls back to the OS share sheet.
  static Future<void> shareVerificationTo(
      SharePlatform platform, dynamic result) async {
    final text = _verificationText(result);
    switch (platform) {
      case SharePlatform.whatsapp:
        await _launch('https://wa.me/?text=${Uri.encodeComponent(text)}');
        break;
      case SharePlatform.linkedin:
        await _launch(
            'https://www.linkedin.com/feed/?shareActive=true&text=${Uri.encodeComponent(text)}');
        break;
      case SharePlatform.facebook:
        await _launch(
            'https://www.facebook.com/sharer/sharer.php?u=${Uri.encodeComponent(_siteUrl)}&quote=${Uri.encodeComponent(text)}');
        break;
      case SharePlatform.more:
        shareText(text, subject: 'Notizz AI Verification Result');
        break;
    }
  }

  /// Builds the shareable verdict text (used by every share target).
  static String _verificationText(dynamic result) {
    // result is VerificationModel (verdict, confidence, summary — there is no
    // `claim` field; accessing it threw NoSuchMethodError).
    final String verdict =
        (result.verdict ?? "UNKNOWN").toString().toUpperCase();
    final conf = result.confidence ?? 0;
    final int confPct = conf <= 10 ? (conf * 10) : conf; // 1–10 score → %
    final String summary = (result.summary ?? "").toString();

    return "Notizz AI Verification\n\n"
        "Verdict: $verdict  ($confPct% confidence)\n"
        "${summary.isNotEmpty ? "\n$summary\n" : ""}"
        "\nChecked with Notizz AI";
  }

  static void shareVerification(dynamic result) {
    shareText(_verificationText(result),
        subject: "Notizz AI Verification Result");
  }

  static void shareBiasAnalysis(dynamic result) {
    // result is BiasModel
    final String level = result.overallBias.level;
    final int score = result.overallBias.score;

    final String text = "Notizz AI Bias Analysis\n\n"
        "Overall Bias: $level\n"
        "Bias Score: $score/100\n\n"
        "Check more at Notizz AI!";

    shareText(text, subject: "Notizz AI Bias Analysis Result");
  }

  static void shareArticle(dynamic article) {
    final String title = article.title ?? "Untitled Article";
    final String content = article.content ?? "";
    final String preview =
        content.length > 200 ? "${content.substring(0, 200)}..." : content;

    final String text = "Notizz AI Generated Article\n\n"
        "Title: $title\n\n"
        "$preview\n\n"
        "Read more in the Notizz App!";

    shareText(text, subject: title);
  }
}
