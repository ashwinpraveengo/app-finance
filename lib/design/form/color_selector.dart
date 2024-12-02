// Copyright 2023 The terCAD team. All rights reserved.
// Use of this source code is governed by a CC BY-NC-ND 4.0 license that can be found in the LICENSE file.

import 'package:app_finance/_classes/herald/app_locale.dart';
import 'package:app_finance/_configs/custom_color_scheme.dart';
import 'package:app_finance/_configs/custom_text_theme.dart';
import 'package:app_finance/_configs/theme_helper.dart';
import 'package:app_finance/_ext/build_context_ext.dart';
import 'package:app_finance/_ext/color_ext.dart';
import 'package:app_finance/design/form/abstract_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class ColorSelector extends AbstractSelector {
  final Function setState;
  @override
  // ignore: overridden_fields
  final MaterialColor? value;
  final bool withLabel;

  const ColorSelector({
    super.key,
    required this.setState,
    this.value,
    this.withLabel = false,
  }) : super(value: value);

  @override
  ColorSelectorState createState() => ColorSelectorState();
}

class ColorSelectorState extends AbstractSelectorState<ColorSelector> {
  late MaterialColor value;

  @override
  void initState() {
    value = widget.value ?? ColorExt.getRandomMaterialColor();
    super.initState();
  }

  @override
  void onTap(context) {
    if (widget.value != null && widget.value != value) {
      value = widget.value!;
    }
    NavigatorState nav = Navigator.of(context);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocale.labels.colorTooltip),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: value,
              onColorChanged: (color) {
                setState(() => value = color.toMaterialColor);
                focusController.onEditingComplete(this);
              },
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                nav.pop();
                widget.setState(value);
                focusController.onEditingComplete(this);
              },
              child: Text(AppLocale.labels.ok),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget buildContent(context) {
    final indent = ThemeHelper.getIndent(1.8);
    return TextFormField(
      readOnly: true,
      onTap: () => onTap(context),
      decoration: InputDecoration(
        filled: true,
        border: InputBorder.none,
        fillColor: widget.value ?? context.colorScheme.fieldBackground,
        hintText: widget.withLabel ? AppLocale.labels.color : null,
        hintStyle: context.textTheme.tooltipMedium,
        contentPadding: EdgeInsets.fromLTRB(indent / 1.5, widget.withLabel ? 1 : indent, 0, indent),
        suffixIcon: GestureDetector(
          child: const Icon(Icons.color_lens),
        ),
      ),
    );
  }
}
