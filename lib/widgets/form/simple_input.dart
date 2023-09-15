// Copyright 2023 The terCAD team. All rights reserved.
// Use of this source code is governed by a CC BY-NC-ND 4.0 license that can be found in the LICENSE file.

import 'package:app_finance/_classes/controller/focus_controller.dart';
import 'package:app_finance/_configs/custom_text_theme.dart';
import 'package:app_finance/widgets/form/abstract_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SimpleInput extends AbstractInput {
  final Function? setState;
  final String? tooltip;
  final TextInputType type;
  final List<TextInputFormatter>? formatter;
  final TextEditingController controller;

  static FilteringTextInputFormatter filterDouble = FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,4}'));

  SimpleInput({
    super.key,
    required this.controller,
    this.setState,
    this.tooltip,
    this.formatter,
    this.type = TextInputType.text,
  }) : super(value: controller.text) {
    if (setState != null) {
      controller.addListener(() => setState!(controller.text));
    }
  }

  @override
  Widget buildContent(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return TextFormField(
      controller: controller,
      inputFormatters: formatter,
      style: textTheme.numberMedium.copyWith(color: textTheme.headlineSmall?.color),
      keyboardType: type,
      focusNode: focus,
      textInputAction: FocusController.getAction(),
      onTap: () => FocusController.onFocus(focusOrder),
      onEditingComplete: () => FocusController.onEditingComplete(focusOrder),
      autofocus: isFocused,
      decoration: InputDecoration(
        filled: true,
        border: InputBorder.none,
        fillColor: Theme.of(context).colorScheme.inversePrimary.withOpacity(0.3),
        hintText: tooltip,
        hintStyle: textTheme.numberMedium.copyWith(color: textTheme.headlineSmall?.color!.withOpacity(0.4)),
      ),
    );
  }
}