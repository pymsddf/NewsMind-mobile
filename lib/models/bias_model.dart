import 'dart:ui';
import '../theme/intelligence_design_system.dart';

class BiasModel {
  final BiasOverall overallBias;
  final List<BiasType> biasTypes;
  final List<String> keyFindings;
  final List<BiasEvidence> evidence;
  final List<String> recommendations;
  final String? historyId;

  BiasModel({
    required this.overallBias,
    this.biasTypes = const [],
    this.keyFindings = const [],
    this.evidence = const [],
    this.recommendations = const [],
    this.historyId,
  });

  factory BiasModel.fromJson(Map<String, dynamic> json) {
    // Helper function to safely convert to List<String>
    List<String> toStringList(dynamic value) {
      if (value == null) return [];
      if (value is List) {
        return value.map<String>((e) => e?.toString() ?? '').toList();
      }
      return [];
    }

    // Helper function to safely convert to List for BiasEvidence
    List<BiasEvidence> toEvidenceList(dynamic value) {
      if (value == null) return [];
      if (value is List) {
        return value.map<BiasEvidence>((e) {
          if (e is Map) {
            return BiasEvidence(
              text: e['claim'] ?? e['text'] ?? '',
              explanation: e['support'] ?? e['explanation'] ?? 'Analysis detail',
            );
          }
          return BiasEvidence(text: e?.toString() ?? '');
        }).toList();
      }
      return [];
    }

    // Parse bias types from dimensions
    final biasTypes = _parseBiasTypes(json['dimensions'] ?? json['labels'] ?? json['bias_types']);

    // Compute overall score from dimensions if not provided
    int overallScore = 0;
    final overallObj = json['overall_bias'] ?? json['overall'] ?? {};
    final directScore = json['overall_score'] ?? json['score'] ?? (overallObj is Map ? overallObj['score'] : null);
    
    int parseSafeInt(dynamic val, int defaultValue) {
      if (val == null) return defaultValue;
      if (val is int) return val;
      if (val is double) return val.toInt();
      if (val is num) return val.toInt();
      if (val is String) return int.tryParse(val) ?? defaultValue;
      return defaultValue;
    }

    if (directScore != null) {
      overallScore = parseSafeInt(directScore, 0);
    } else {
      // Compute from dimension scores
      final dims = json['dimensions'];
      if (dims is Map) {
        final scores = <int>[];
        for (final key in ['framing', 'sensationalism', 'source_bias', 'evidence_quality']) {
          final dim = dims[key];
          if (dim is Map && dim['score'] != null) {
            scores.add(parseSafeInt(dim['score'], 0));
          }
        }
        if (scores.isNotEmpty) {
          overallScore = (scores.reduce((a, b) => a + b) / scores.length).round();
        }
      }
    }

    final level = json['overall_label'] ?? json['overall_level'] ?? json['level'] ?? (overallObj is Map ? (overallObj['level'] ?? 'medium') : 'medium');

    return BiasModel(
      overallBias: BiasOverall(level: level, score: overallScore),
      biasTypes: biasTypes,
      keyFindings: toStringList(json['key_phrases'] ?? json['key_findings']),
      evidence: toEvidenceList(json['claims'] ?? json['evidence'] ?? json['evidence_list']),
      recommendations: _parseRecommendations(json['dimensions'] ?? json['labels'] ?? json['recommendations']),
      historyId: json['historyId']?.toString() ?? json['_id']?.toString() ?? json['id']?.toString(),
    );
  }

  static List<BiasType> _parseBiasTypes(Map<String, dynamic>? data) {
    if (data == null) return [];
    final types = <BiasType>[];

    // Handle the new 'dimensions' structure
    if (data.containsKey('framing')) {
      final framing = data['framing'];
      types.add(BiasType(
        type: 'Linguistic',
        severity: (framing['label'] ?? 'medium').toString().toLowerCase(),
        description: framing['rationale'] ?? '',
      ));
    }
    if (data.containsKey('source_bias')) {
      final source = data['source_bias'];
      types.add(BiasType(
        type: 'Source',
        severity: (source['label'] ?? 'low').toString().toLowerCase(),
        description: source['rationale'] ?? '',
      ));
    }
    if (data.containsKey('sensationalism')) {
      final sens = data['sensationalism'];
      types.add(BiasType(
        type: 'Sensationalism',
        severity: (sens['label'] ?? 'low').toString().toLowerCase(),
        description: sens['rationale'] ?? '',
      ));
    }
    if (data.containsKey('evidence_quality')) {
      final ev = data['evidence_quality'];
      types.add(BiasType(
        type: 'Evidence',
        severity: (ev['label'] ?? 'medium').toString().toLowerCase(),
        description: ev['rationale'] ?? '',
      ));
    }

    // Fallback for legacy labels structure
    if (types.isEmpty) {
      if (data['ideology'] != null) {
        types.add(BiasType(
          type: 'Political',
          severity: (data['ideology']['label'] ?? 'medium').toString().toLowerCase(),
          description: data['ideology']['rationale'] ?? '',
        ));
      }
      // ... existing ones ...
    }

    return types;
  }

  static List<String> _parseRecommendations(Map<String, dynamic>? labels) {
    final recs = <String>[];
    if (labels != null && labels['evidence_quality'] != null) {
      recs.add('Evidence quality: ${labels['evidence_quality']['rationale'] ?? 'N/A'}');
    }
    recs.add('Balance perspectives and reduce sensational language where possible.');
    return recs;
  }

  Map<String, dynamic> toJson() {
    return {
      'overall_bias': overallBias.toJson(),
      'dimensions': Map.fromEntries(biasTypes.map((t) => MapEntry(t.type.toLowerCase(), {
        'label': t.severity,
        'rationale': t.description,
      }))),
      'key_findings': keyFindings,
      'evidence': evidence.map((e) => e.toJson()).toList(),
      'recommendations': recommendations,
    };
  }
}

class BiasOverall {
  final String level;
  final int score;

  BiasOverall({required this.level, required this.score});

  Map<String, dynamic> toJson() {
    return {
      'level': level,
      'score': score,
    };
  }

  Color get color {
    switch (level.toLowerCase()) {
      case 'low':
        return AppColors.verified;
      case 'medium':
        return AppColors.caution;
      case 'high':
        return AppColors.redline;
      default:
        return AppColors.graphite;
    }
  }
}

class BiasType {
  final String type;
  final String severity;
  final String description;

  BiasType({
    required this.type,
    required this.severity,
    this.description = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'severity': severity,
      'description': description,
    };
  }

  Color get color {
    switch (severity.toLowerCase()) {
      case 'low':
        return AppColors.verified;
      case 'medium':
        return AppColors.caution;
      case 'high':
        return AppColors.redline;
      default:
        return AppColors.graphite;
    }
  }
}

class BiasEvidence {
  final String text;
  final String explanation;

  BiasEvidence({required this.text, this.explanation = ''});

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'explanation': explanation,
    };
  }
}
