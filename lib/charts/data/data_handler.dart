// Copyright 2023 The terCAD team. All rights reserved.
// Use of this source code is governed by a CC BY-NC-ND 4.0 license that can be found in the LICENSE file.

import 'dart:collection';

import 'package:app_finance/_classes/herald/app_start_of_month.dart';
import 'package:app_finance/_classes/structure/bill_app_data.dart';
import 'package:app_finance/_classes/structure/budget_app_data.dart';
import 'package:app_finance/_classes/structure/currency/exchange.dart';
import 'package:app_finance/_classes/structure/interface_app_data.dart';
import 'package:app_finance/_classes/structure/transaction_log_data.dart';
import 'package:app_finance/_ext/date_time_ext.dart';
import 'package:app_finance/charts/interface/ohlc_data.dart';
import 'package:flutter/material.dart';

typedef DateCallback = double Function(InterfaceAppData item);

class DataHandler {
  static double countBudgetTotal(List<InterfaceAppData> scope, {required Exchange exchange}) {
    final currency = exchange.getDefaultCurrency();
    return scope.fold(0.0, (v, e) => v + exchange.reform((e as BudgetAppData).amountLimit, e.currency, currency));
  }

  static List<Offset> getAmountGroupedByCategory(List<BillAppData> scope, List<BudgetAppData> budgets,
      {required Exchange exchange}) {
    final idx = budgets.map((e) => e.uuid).toList();
    fn(item) => idx.indexWhere((uuid) => uuid == item.category).toDouble();
    return _getGroupedAmount(scope, fn, exchange: exchange);
  }

  static List<Offset> getAmountGroupedByMonth(List<InterfaceAppData> scope, {required Exchange exchange}) {
    fn(item) => (item.createdAt as DateTime).getStartingDay(AppStartOfMonth.get()).millisecondsSinceEpoch.toDouble();
    return _getGroupedAmount(scope, fn, exchange: exchange);
  }

  static List<Offset> getAmountGroupedByDate(List<InterfaceAppData> scope, {required Exchange exchange}) {
    fn(item) =>
        DateTime(item.createdAt.year, item.createdAt.month, item.createdAt.day).millisecondsSinceEpoch.toDouble();
    return _getGroupedAmount(scope, fn, exchange: exchange);
  }

  static List<Offset> _getGroupedAmount(List<InterfaceAppData> scope, DateCallback fn, {required Exchange exchange}) {
    final data = SplayTreeMap<dynamic, List<double>>();
    final currency = exchange.getDefaultCurrency();
    for (final item in scope) {
      final actual = fn(item);
      if (actual == -1) {
        continue;
      }
      if (data[actual] == null) {
        data[actual] = [];
      }
      data[actual]!.add(exchange.reform(item.details, item.currency, currency));
    }
    final List<Offset> result = [];
    data.forEach((key, value) => result.add(Offset(key, value.fold(0.0, (v, e) => v + e))));
    return result;
  }

  static List<OhlcData> generateOhlcSummary(List<List<TransactionLogData>?> scope,
      {required Exchange exchange, DateTime? cut}) {
    final data = scope.firstOrNull;
    for (int i = 1; i < scope.length; i++) {
      if (scope[i] == null || data == null) {
        continue;
      }
      data.addAll(scope[i]!.where((e) => cut == null || e.timestamp.isAfter(cut)));
    }
    if (data != null && data.isNotEmpty) {
      data.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      return _generateOhlc(data, exchange);
    }
    return [];
  }

  static List<OhlcData> _generateOhlc(List<TransactionLogData> scope, Exchange exchange) {
    final currency = exchange.getDefaultCurrency();
    final result = SplayTreeMap<DateTime, OhlcData>();
    double min = 0;
    double close = 0;
    for (int i = 0; i < scope.length; i++) {
      final key = DateTime(scope[i].timestamp.year, scope[i].timestamp.month, (scope[i].timestamp.day / 7).floor() * 6);
      final value = exchange.reform(scope[i].delta, scope[i].currency, currency);
      if (!result.containsKey(key)) {
        result[key] = OhlcData(date: key, open: close, close: value + close, high: value + close, low: value + close);
      } else {
        result[key]!.close += value;
      }
      if (result[key]!.close > result[key]!.high) {
        result[key]!.high = result[key]!.close;
      }
      if (result[key]!.close < result[key]!.low) {
        result[key]!.low = result[key]!.close;
      }
      if (min > result[key]!.close) {
        min = result[key]!.close;
      }
      close = result[key]!.close;
    }
    for (OhlcData data in result.values) {
      data.open -= min;
      data.close -= min;
      data.high -= min;
      data.low -= min;
    }
    return result.values.toList();
  }
}
