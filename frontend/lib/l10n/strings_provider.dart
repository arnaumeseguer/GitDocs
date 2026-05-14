import 'package:flutter/material.dart';
import 'strings.dart';

class StringsProvider extends InheritedWidget {
  final AppStrings strings;

  const StringsProvider({
    super.key,
    required this.strings,
    required super.child,
  });

  static AppStrings of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<StringsProvider>()!
        .strings;
  }

  @override
  bool updateShouldNotify(StringsProvider old) => strings.langCode != old.strings.langCode;
}
