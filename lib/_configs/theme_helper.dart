// Copyright 2023 The terCAD team. All rights reserved.
// Use of this source code is governed by a CC BY-NC-ND 4.0 license that can be found in the LICENSE file.

import 'package:flutter/material.dart';

class ThemeHelper {
  static double getIndent([double multiply = 1]) => 8.0 * multiply;

  static double getWidth(BuildContext context, [double multiply = 4]) =>
      MediaQuery.of(context).size.width - getIndent() * multiply;

  static bool isVertical(BoxConstraints constraints) => constraints.maxWidth < constraints.maxHeight;
}