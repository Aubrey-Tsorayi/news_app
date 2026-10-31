import 'package:flutter/foundation.dart';

@immutable
class NewsBrand {
  const NewsBrand({required this.name});

  final String name;

  @override
  bool operator ==(Object other) => other is NewsBrand && other.name == name;

  @override
  int get hashCode => name.hashCode;
}
