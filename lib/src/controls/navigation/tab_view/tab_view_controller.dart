import 'dart:collection';

import 'package:flutter/foundation.dart';

import 'tab_view.dart';

/// Manages the tabs and selected tab of a [TabView].
///
/// A controller owns its tab list. Supply it to [TabView.controller] to update
/// the view by calling methods such as [select], [add], and [removeAt].
class TabViewController with ChangeNotifier {
  /// Creates a controller with [tabs] and the initially selected tab.
  ///
  /// When [tabs] is empty, [initialIndex] must be `0`. This value is retained
  /// so that the first tab added becomes selected.
  TabViewController({List<Tab> tabs = const [], int initialIndex = 0})
    : _tabs = List.of(tabs),
      _selectedIndex = initialIndex {
    _validateTabs(_tabs);
    _validateSelectedIndex();
  }

  final List<Tab> _tabs;
  int _selectedIndex;

  /// The tabs managed by this controller.
  ///
  /// The returned list cannot be modified. Use [add], [insert], [removeAt],
  /// [move], or [replaceTabs] to change it.
  List<Tab> get tabs => UnmodifiableListView(_tabs);

  /// The index of the selected tab.
  ///
  /// When [tabs] is empty, this is `0`.
  int get selectedIndex => _selectedIndex;

  /// The selected tab, or `null` when [tabs] is empty.
  Tab? get selectedTab => _tabs.isEmpty ? null : _tabs[_selectedIndex];

  /// Selects the tab at [index].
  ///
  /// Throws a [RangeError] when [index] does not identify a managed tab.
  void select(int index) {
    _validateIndex(index);
    if (_selectedIndex == index) return;
    _selectedIndex = index;
    notifyListeners();
  }

  /// Adds [tab] after the existing tabs.
  ///
  /// When [select] is true, which is the default, [tab] becomes selected.
  /// The first added tab is always selected.
  void add(Tab tab, {bool select = true}) {
    _validateTab(tab, _tabs);
    final index = _tabs.length;
    _tabs.add(tab);
    if (index == 0 || select) _selectedIndex = index;
    notifyListeners();
  }

  /// Inserts [tab] at [index].
  ///
  /// When [select] is true, which is the default, [tab] becomes selected.
  /// When false, the existing selection follows its tab. The first inserted tab
  /// is always selected.
  void insert(int index, Tab tab, {bool select = true}) {
    if (index < 0 || index > _tabs.length) {
      throw RangeError.range(index, 0, _tabs.length, 'index');
    }
    _validateTab(tab, _tabs);
    final wasEmpty = _tabs.isEmpty;
    _tabs.insert(index, tab);
    if (wasEmpty || select) {
      _selectedIndex = index;
    } else if (index <= _selectedIndex) {
      _selectedIndex++;
    }
    notifyListeners();
  }

  /// Removes and returns the tab at [index].
  ///
  /// When the selected tab is removed, the tab that takes its place is
  /// selected. Removing the final tab resets [selectedIndex] to `0`.
  Tab removeAt(int index) {
    _validateIndex(index);
    final tab = _tabs.removeAt(index);
    if (_tabs.isEmpty) {
      _selectedIndex = 0;
    } else if (index < _selectedIndex) {
      _selectedIndex--;
    } else if (index == _selectedIndex && _selectedIndex >= _tabs.length) {
      _selectedIndex = _tabs.length - 1;
    }
    notifyListeners();
    return tab;
  }

  /// Moves the tab at [oldIndex] to [newIndex].
  ///
  /// The selected tab remains selected after the move.
  void move(int oldIndex, int newIndex) {
    _validateIndex(oldIndex, name: 'oldIndex');
    _validateIndex(newIndex, name: 'newIndex');
    if (oldIndex == newIndex) return;

    final tab = _tabs.removeAt(oldIndex);
    _tabs.insert(newIndex, tab);

    if (_selectedIndex == oldIndex) {
      _selectedIndex = newIndex;
    } else if (oldIndex < _selectedIndex && _selectedIndex <= newIndex) {
      _selectedIndex--;
    } else if (newIndex <= _selectedIndex && _selectedIndex < oldIndex) {
      _selectedIndex++;
    }
    notifyListeners();
  }

  /// Replaces all managed tabs with [tabs].
  ///
  /// The selected tab is preserved when the replacement contains the same tab
  /// instance or an equal non-null key. Otherwise, the nearest valid index is
  /// selected. Replacing with an empty list resets [selectedIndex] to `0`.
  /// No notification is sent when [tabs] has the same contents in the same
  /// order as the current list.
  void replaceTabs(List<Tab> tabs) {
    _validateTabs(tabs);
    if (listEquals(_tabs, tabs)) return;

    final selectedTab = this.selectedTab;
    _tabs
      ..clear()
      ..addAll(tabs);

    if (_tabs.isEmpty) {
      _selectedIndex = 0;
    } else {
      final selectedIndex = _indexOfSelectedTab(selectedTab);
      _selectedIndex =
          selectedIndex ?? _selectedIndex.clamp(0, _tabs.length - 1);
    }
    notifyListeners();
  }

  int? _indexOfSelectedTab(Tab? selectedTab) {
    if (selectedTab == null) return null;
    final identicalIndex = _tabs.indexOf(selectedTab);
    if (identicalIndex != -1) return identicalIndex;

    final key = selectedTab.key;
    if (key == null) return null;
    final keyedIndex = _tabs.indexWhere((tab) => tab.key == key);
    return keyedIndex == -1 ? null : keyedIndex;
  }

  void _validateSelectedIndex() {
    if (_tabs.isEmpty) {
      if (_selectedIndex != 0) {
        throw RangeError.value(
          _selectedIndex,
          'initialIndex',
          'must be 0 when tabs is empty',
        );
      }
      return;
    }
    _validateIndex(_selectedIndex, name: 'initialIndex');
  }

  void _validateIndex(int index, {String name = 'index'}) {
    if (index < 0 || index >= _tabs.length) {
      throw RangeError.index(index, _tabs, name);
    }
  }

  static void _validateTabs(List<Tab> tabs) {
    final seenTabs = <Tab>{};
    final seenKeys = <Key>{};
    for (final tab in tabs) {
      if (!seenTabs.add(tab)) {
        throw ArgumentError.value(
          tab,
          'tabs',
          'must not contain duplicate tabs',
        );
      }
      final key = tab.key;
      if (key != null && !seenKeys.add(key)) {
        throw ArgumentError.value(
          key,
          'tabs',
          'must not contain duplicate keys',
        );
      }
    }
  }

  static void _validateTab(Tab tab, Iterable<Tab> tabs) {
    if (tabs.contains(tab)) {
      throw ArgumentError.value(tab, 'tab', 'must not already be managed');
    }
    final key = tab.key;
    if (key != null && tabs.any((tab) => tab.key == key)) {
      throw ArgumentError.value(key, 'tab.key', 'must be unique');
    }
  }
}
