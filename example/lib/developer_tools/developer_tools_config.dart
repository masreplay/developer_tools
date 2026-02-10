import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

@freezed
class DeveloperToolsConfig with _$DeveloperToolsConfig {
  const factory DeveloperToolsConfig({
    @Default(true) bool applyMediaQueryViewInsets,
    @Default(10) int maxToastLimit,
    @Default(2) int maxTitleLines,
    @Default(6) int maxDescriptionLines,
    @Default(false) bool blockBackgroundInteraction,
  }) = _DeveloperToolsConfig;

}
