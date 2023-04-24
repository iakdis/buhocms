import 'package:flutter/material.dart';

class FrontmatterProvider extends ChangeNotifier {
  List<MapEntry> _frontmatterLines = [];
  List<MapEntry> get frontmatterLines => _frontmatterLines;

  void set(List<MapEntry> newFrontmatterLines) =>
      _frontmatterLines = newFrontmatterLines;

  void add(MapEntry<dynamic, dynamic> value) => _frontmatterLines.add(value);

  void insert(int index, MapEntry<dynamic, dynamic> element) =>
      _frontmatterLines.insert(index, element);

  MapEntry<dynamic, dynamic> removeAt(int index) =>
      _frontmatterLines.removeAt(index);
}
