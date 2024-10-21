// Copyright 2023 The terCAD team. All rights reserved.
// Use of this source code is governed by a CC BY-NC-ND 4.0 license that can be found in the LICENSE file.

import 'package:app_finance/_classes/herald/app_design.dart';
import 'package:app_finance/_classes/structure/navigation/app_route.dart';
import 'package:app_finance/_ext/build_context_ext.dart';
import 'package:app_finance/charts/bar_vertical_single.dart';
import 'package:app_finance/_configs/custom_text_theme.dart';
import 'package:app_finance/design/wrapper/number_wrapper.dart';
import 'package:app_finance/design/wrapper/row_widget.dart';
import 'package:app_finance/design/wrapper/tap_widget.dart';
import 'package:app_finance/_configs/theme_helper.dart';
import 'package:app_finance/design/wrapper/text_wrapper.dart';
import 'package:flutter/material.dart';

class BaseLineWidget extends StatelessWidget {
  final String uuid;
  final String title;
  final String details;
  final String description;
  final double progress;
  final Color color;
  final IconData? icon;
  final double width;
  final String route;
  final bool hidden;
  final bool skip;
  final bool showDivider;
  final Widget? error;

  const BaseLineWidget({
    super.key,
    required this.uuid,
    required this.title,
    required this.details,
    required this.description,
    required this.color,
    required this.width,
    this.icon = Icons.question_mark,
    this.error,
    this.hidden = false,
    this.skip = false,
    this.progress = 1,
    this.route = '',
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    if (hidden) {
      return ThemeHelper.emptyBox;
    }
    final textTheme = context.textTheme;
    final indent = ThemeHelper.getIndent();
    final txtWidth = ThemeHelper.getTextWidth(Text(details, style: textTheme.numberMedium));

    return TapWidget(
      tooltip: '',
      toWrap: route != '' && uuid != '',
      route: RouteSettings(name: route, arguments: {routeArguments.uuid: uuid}),
      child: Column(
        crossAxisAlignment: AppDesign.getAlignment(),
        children: [
          RowWidget(
            indent: indent,
            alignment: AppDesign.getAlignment<MainAxisAlignment>(),
            maxWidth: width,
            chunk: [ThemeHelper.isWearable ? 0 : indent * 1.5, null, txtWidth + 2 * indent, if (error != null) 22],
            children: [
              [
                Padding(
                  padding: EdgeInsets.only(left: indent),
                  child: BarVerticalSingle(value: progress, height: 32.0, width: indent / 2, color: color),
                ),
              ],
              [
                ThemeHelper.isWearable
                    ? Tooltip(
                        message: title,
                        child: Icon(icon, color: color),
                      )
                    : Column(
                        crossAxisAlignment: AppDesign.getAlignment(),
                        children: [
                          TextWrapper(
                            title,
                            style: textTheme.headlineMedium?.copyWith(
                              fontStyle: skip ? FontStyle.italic : FontStyle.normal,
                            ),
                          ),
                          TextWrapper(
                            description,
                            style: textTheme.bodySmall,
                          ),
                        ],
                      ),
              ],
              [
                Align(
                  alignment: Alignment.centerRight,
                  child: NumberWidget(details, colorScheme: context.colorScheme, style: textTheme.numberMedium),
                ),
              ],
              if (error != null) [error!],
            ],
          ),
          if (showDivider) const Divider(),
        ],
      ),
    );
  }
}
