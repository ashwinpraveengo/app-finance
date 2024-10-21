// Copyright 2023 The terCAD team. All rights reserved.
// Use of this source code is governed by a CC BY-NC-ND 4.0 license that can be found in the LICENSE file.

import 'package:app_finance/_classes/structure/currency/exchange.dart';
import 'package:app_finance/_classes/structure/navigation/app_route.dart';
import 'package:app_finance/_classes/structure/budget_app_data.dart';
import 'package:app_finance/_configs/theme_helper.dart';
import 'package:app_finance/design/generic/base_swipe_widget.dart';
import 'package:app_finance/components/widgets/account_widget.dart';
import 'package:app_finance/design/generic/base_group_widget.dart';
import 'package:app_finance/design/generic/base_line_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_currency_picker/flutter_currency_picker.dart';

class BudgetWidget extends AccountWidget {
  BudgetWidget({
    super.key,
    required super.title,
    required super.width,
    required super.margin,
    required super.state,
    super.tooltip,
    super.limit,
    super.route,
    super.routeList = AppRoute.budgetViewRoute,
    super.hasExpand,
    super.toExpand,
    super.callback,
  });

  @override
  Widget buildGroupedListWidget(List<dynamic> items, BuildContext context) {
    final item = wrapBySingleEntity(items);
    return BaseGroupWidget(
      title: item.title,
      total: item.details,
      description: item.description,
      progress: items.map((e) => e.progressLeft).cast<double>().toList(),
      color: items.map((e) => e.color ?? Colors.transparent).cast<Color>().toList(),
      width: width - ThemeHelper.getIndent() / 2,
      items: items,
      route: AppRoute.budgetRoute,
    );
  }

  @override
  dynamic wrapBySingleEntity(List<dynamic> items) {
    Currency? def = Exchange.defaultCurrency;
    double amountLimit = items.fold(0.0, (value, e) => value + exchange.reform(e.amountLimit, e.currency, def));
    double amountSpent = items.fold(0.0, (value, e) => value + exchange.reform(e.amount, e.currency, def));
    double progress = amountLimit > 0 ? 1 - (amountLimit - amountSpent) / amountLimit : 0.0;
    return BudgetAppData(
      title: getName(items.first),
      currency: def,
      amountLimit: amountLimit,
      progress: progress,
    );
  }

  @override
  Widget buildSingleListWidget(item, BuildContext context) {
    item = item is List ? item.first : item;
    return BaseSwipeWidget(
      routePath: AppRoute.budgetEditRoute,
      uuid: item.uuid,
      child: BaseLineWidget(
        uuid: item.uuid,
        title: item.title,
        description: item.description ?? '',
        details: item.detailsFormatted,
        progress: item.progressLeft,
        color: item.color ?? Colors.transparent,
        icon: item.icon ?? Icons.radio_button_unchecked_sharp,
        hidden: item.hidden,
        skip: item.skip,
        width: width,
        route: routeList,
      ),
    );
  }
}
