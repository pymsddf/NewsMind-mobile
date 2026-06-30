import 'dart:ui';
import '../theme/intelligence_design_system.dart';

class VerificationModel {
  final String verdict;
  final int confidence;
  final int credibilityScore;
  final String summary;
  final List<String> keyFindings;
  final List<EvidenceSource> evidence;
  final String status;
  final String? historyId;

  VerificationModel({
    required this.verdict,
    this.confidence = 5,
    this.credibilityScore = 50,
    this.summary = '',
    this.keyFindings = const [],
    this.evidence = const [],
    this.status = 'unverified',
    this.historyId,
  });

  factory VerificationModel.fromJson(Map<String, dynamic> json) {
    // Helper function to safely convert to List<String>
    List<String> toStringList(dynamic value) {
      if (value == null) return [];
      if (value is List) {
        return value.map<String>((e) => e?.toString() ?? '').toList();
      }
      return [];
    }
    
    // Helper function to safely convert to List for EvidenceSource
    List<EvidenceSource> toEvidenceList(dynamic value) {
      if (value == null) return [];
      if (value is List) {
        return value.map<EvidenceSource>((e) {
          if (e is Map) {
            return EvidenceSource.fromJson(Map<String, dynamic>.from(e));
          }
          return EvidenceSource(title: e?.toString() ?? 'Source');
        }).toList();
      }
      return [];
    }

    int parseSafeInt(dynamic val, int defaultValue) {
      if (val == null) return defaultValue;
      if (val is int) return val;
      if (val is double) return val.toInt();
      if (val is num) return val.toInt();
      if (val is String) return int.tryParse(val) ?? defaultValue;
      return defaultValue;
    }

    return VerificationModel(
      verdict: (json['verdict'] ?? json['overall_verdict'] ?? 'MAYBE').toString().toUpperCase(),
      confidence: parseSafeInt(json['confidence'] ?? json['confidence_score'], 5),
      credibilityScore: parseSafeInt(json['credibilityScore'] ?? json['credibility_score'] ?? json['score'], 50),
      summary: json['summary'] ?? json['conclusion'] ?? json['rationale'] ?? '',
      keyFindings: toStringList(json['keyFindings'] ?? json['key_findings']),
      evidence: toEvidenceList(json['evidence'] ?? json['sources']),
      status: json['status'] ?? 'completed',
      historyId: json['historyId']?.toString() ?? json['_id']?.toString() ?? json['id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'verdict': verdict,
      'confidence': confidence,
      'credibilityScore': credibilityScore,
      'summary': summary,
      'keyFindings': keyFindings,
      'evidence': evidence.map((e) => e.toJson()).toList(),
      'status': status,
    };
  }

  Color get verdictColor {
    switch (verdict.toUpperCase()) {
      case 'TRUE':
      case 'READY':
        return AppColors.verified;
      case 'FALSE':
      case 'NOT_READY':
        return AppColors.redline;
      default:
        return AppColors.caution;
    }
  }
}

class EvidenceSource {
  final String title;
  final String description;
  final String? url;
  final String? domain;
  final int reliability;

  EvidenceSource({
    required this.title,
    this.description = '',
    this.url,
    this.domain,
    this.reliability = 80,
  });

  factory EvidenceSource.fromJson(Map<String, dynamic> json) {
    return EvidenceSource(
      title: json['title'] ?? 'Source',
      description: json['description'] ?? '',
      url: json['url'] ?? json['link'],
      domain: json['domain'],
      reliability: json['reliability'] ?? 80,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'url': url,
      'domain': domain,
      'reliability': reliability,
    };
  }
}
