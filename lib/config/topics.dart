import 'package:flutter/material.dart';

/// A selectable news topic for the aggregated daily feed.
///
/// [id] is the canonical value sent to / stored by the backend — it MUST match
/// an entry in `NewsMind AI/backend/config/topics.js` (the two lists are
/// mirrors and must stay in sync).
class NewsTopic {
  final String id;
  final String label;
  final IconData icon;

  const NewsTopic(this.id, this.label, this.icon);
}

/// Canonical topic set. Mirror of the backend `TOPICS` list.
/// Movies & Music are intentionally split out from a generic "Entertainment".
class Topics {
  static const int maxSelection = 3;

  static const List<NewsTopic> all = [
    NewsTopic('Technology', 'Technology', Icons.memory_rounded),
    NewsTopic('Business', 'Business', Icons.business_center_rounded),
    NewsTopic('Politics', 'Politics', Icons.account_balance_rounded),
    NewsTopic('World', 'World', Icons.public_rounded),
    NewsTopic('Science', 'Science', Icons.science_rounded),
    NewsTopic('Health', 'Health', Icons.favorite_rounded),
    NewsTopic('Sports', 'Sports', Icons.sports_soccer_rounded),
    NewsTopic('Movies', 'Movies', Icons.movie_rounded),
    NewsTopic('Music', 'Music', Icons.music_note_rounded),
    NewsTopic('Environment', 'Environment', Icons.eco_rounded),
    NewsTopic('Finance', 'Finance', Icons.trending_up_rounded),
  ];

  /// Lookup a topic by its canonical id (case-insensitive).
  static NewsTopic? byId(String id) {
    final v = id.trim().toLowerCase();
    for (final t in all) {
      if (t.id.toLowerCase() == v) return t;
    }
    return null;
  }
}
