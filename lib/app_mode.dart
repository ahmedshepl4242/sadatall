import 'package:flutter/material.dart';

enum AppMode { captain, vendor, user }

/// Global notifier — update this to switch modes without calling runApp again.
/// Listened to by [RootApp] in main.dart; set by [ModeSelectorScreen].
final ValueNotifier<String?> appModeNotifier = ValueNotifier(null);
