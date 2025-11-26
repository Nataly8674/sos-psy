import 'package:flutter/material.dart';
import '../models/entrada_diario.dart';

Color getHumorColor(Humor humor) {
  switch (humor) {
    case Humor.feliz:
      return Colors.green;
    case Humor.neutro:
      return Colors.orange;
    case Humor.triste:
      return Colors.blue;
    case Humor.ansioso:
      return Colors.red;
    case Humor.calmo:
      return Colors.teal;
    case Humor.orgulhoso:
      return Colors.purple;
    case Humor.reflexivo:
      return Colors.indigo;
  }
}

IconData getHumorIcon(Humor humor) {
  switch (humor) {
    case Humor.feliz:
      return Icons.sentiment_very_satisfied;
    case Humor.neutro:
      return Icons.sentiment_neutral;
    case Humor.triste:
      return Icons.sentiment_dissatisfied;
    case Humor.ansioso:
      return Icons.psychology;
    case Humor.calmo:
      return Icons.self_improvement;
    case Humor.orgulhoso:
      return Icons.emoji_events;
    case Humor.reflexivo:
      return Icons.lightbulb;
  }
}
