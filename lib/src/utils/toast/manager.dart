import 'package:flutter/material.dart';

class ToastManager {

  static List<OverlayEntry> entries = [];

  /// Dismiss all the showing toasts
  static void dismissAll() {
    for (var entry in entries) entry?.remove();
  }

  static void dismiss(OverlayEntry entry) {
    entry.remove();
    if (entries.contains(entry)) entries.remove(entry);
  }

  static void insert(OverlayEntry entry) {
    if (!entries.contains(entry)) entries.add(entry);
  }

}