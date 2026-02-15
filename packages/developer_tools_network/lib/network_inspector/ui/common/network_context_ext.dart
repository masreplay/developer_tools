import 'package:developer_tools_network/network_inspector/model/network_translation.dart';
import 'package:developer_tools_network/network_inspector/core/network_translations.dart';
import 'package:flutter/material.dart';

/// Extension for [BuildContext].
extension NetworkContextExt on BuildContext {
  /// Tries to translate given key based on current language code collected from
  /// locale. If it fails to translate [key], it will return [key] itself.
  String i18n(NetworkTranslationKey key) {
    try {
      final locale = Localizations.localeOf(this);
      return NetworkTranslations.get(
        languageCode: locale.languageCode,
        key: key,
      );
    } catch (error) {
      return key.toString();
    }
  }
}
