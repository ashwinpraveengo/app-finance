// Copyright 2023 The terCAD team. All rights reserved.
// Use of this source code is governed by a CC BY-NC-ND 4.0 license that can be found in the LICENSE file.

import 'package:app_finance/_classes/storage/app_data.dart';
import 'package:app_finance/_classes/herald/app_locale.dart';
import 'package:app_finance/_classes/structure/currency/currency_provider.dart';
import 'package:app_finance/_classes/structure/account_app_data.dart';
import 'package:app_finance/_classes/structure/invoice_app_data.dart';
import 'package:app_finance/_configs/account_type.dart';
import 'package:app_finance/_classes/structure/bill_app_data.dart';
import 'package:app_finance/_classes/structure/budget_app_data.dart';
import 'package:app_finance/_classes/storage/transaction_log.dart';
import 'package:app_finance/_classes/controller/focus_controller.dart';
import 'package:app_finance/_mixins/file/file_import_mixin.dart';
import 'package:app_finance/_mixins/shared_preferences_mixin.dart';
import 'package:app_finance/_configs/theme_helper.dart';
import 'package:app_finance/widgets/_forms/list_selector.dart';
import 'package:app_finance/widgets/_forms/simple_input.dart';
import 'package:app_finance/widgets/init/loading_widget.dart';
import 'package:csv/csv.dart';
import 'package:currency_picker/currency_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ImportTab extends StatefulWidget {
  const ImportTab({super.key});

  @override
  ImportTabState createState() => ImportTabState();
}

class ImportTabState extends State<ImportTab> with SharedPreferencesMixin, FileImportMixin {
  late AppData state;
  List<List<dynamic>>? fileContent;
  StringBuffer errorMessage = StringBuffer();
  List<String> columnMap = [];
  bool isLoading = false;
  final dateFormat = TextEditingController(text: 'M/d/yyyy HH:mm');
  final _cache = <AppDataType, Map<String, String?>>{};

  final attrAccountName = 'accountName';
  final attrCategoryName = 'categoryName';
  final attrBillAmount = 'billAmount';
  final attrBillType = 'billType';
  final attrBillDate = 'billDate';
  final attrBillCurrency = 'billCurrency';
  final attrBillComment = 'billComment';

  List<ListSelectorItem> getMappingTypes() {
    final account = AppLocale.labels.account;
    final budget = AppLocale.labels.budget;
    final bill = AppLocale.labels.bill;
    final mapping = [
      ListSelectorItem(id: '', name: '-- ${AppLocale.labels.ignoreTooltip} --'),
      ListSelectorItem(id: attrAccountName, name: '$account: ${AppLocale.labels.title}'),
      ListSelectorItem(id: attrCategoryName, name: '$budget: ${AppLocale.labels.title}'),
      ListSelectorItem(id: attrBillAmount, name: '$bill: ${AppLocale.labels.expense}'),
      ListSelectorItem(id: attrBillType, name: '$bill: ${AppLocale.labels.flowTypeTooltip}'),
      ListSelectorItem(id: attrBillDate, name: '$bill: ${AppLocale.labels.expenseDateTime}'),
      ListSelectorItem(id: attrBillCurrency, name: '$bill: ${AppLocale.labels.currency}'),
      ListSelectorItem(id: attrBillComment, name: '$bill: ${AppLocale.labels.description}'),
    ];
    mapping.sort((a, b) => a.name.compareTo(b.name));
    return mapping;
  }

  Future<void> pickFile() async {
    try {
      String? result = await importFile(['csv']);
      if (result != null) {
        final List<List<dynamic>> csvTable = const CsvToListConverter().convert(result);
        setState(() {
          fileContent = csvTable;
          columnMap = List<String>.filled(csvTable.first.length, '');
        });
      } else {
        setState(() => errorMessage.writeln(AppLocale.labels.missingContent));
      }
    } catch (e) {
      setState(() => errorMessage.writeln(e.toString()));
    }
  }

  Future<void> parseFile() async {
    state.isLoading = true;
    final defaultAccount = getPreference(prefAccount);
    final defaultBudget = getPreference(prefBudget);
    for (int i = 1; i < fileContent!.length; i++) {
      final line = fileContent![i];
      dynamic amount = _get(line, attrBillAmount);
      if (amount is String) {
        amount = double.tryParse(amount);
      }
      try {
        dynamic newItem;
        dynamic account = await _find(AppDataType.accounts, line, _get(line, attrAccountName), defaultAccount);
        if (_get(line, attrBillType) == AppLocale.labels.flowTypeInvoice) {
          newItem = state.add(InvoiceAppData(
            account: account,
            title: _get(line, attrBillComment).toString(),
            details: 0.0 + amount,
            createdAt: DateFormat(dateFormat.text).parse(_get(line, attrBillDate)),
            updatedAt: DateFormat(dateFormat.text).parse(_get(line, attrBillDate)),
            currency: _getCurrency(line),
            hidden: false,
          ));
        } else {
          newItem = state.add(BillAppData(
            account: account,
            category: await _find(AppDataType.budgets, line, _get(line, attrCategoryName), defaultBudget),
            title: _get(line, attrBillComment).toString(),
            details: 0.0 + amount,
            createdAt: DateFormat(dateFormat.text).parse(_get(line, attrBillDate)),
            updatedAt: DateFormat(dateFormat.text).parse(_get(line, attrBillDate)),
            currency: _getCurrency(line),
            hidden: false,
          ));
        }
        TransactionLog.save(newItem);
      } catch (e) {
        setState(() => errorMessage.writeln('[$i / ${fileContent!.length}] ${e.toString()}'));
      }
    }
    await state.restate();
    setState(() => fileContent = null);
  }

  Future<void> wrapCall(Function callback) async {
    setState(() {
      isLoading = true;
      errorMessage.clear();
    });
    await callback();
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      isLoading = false;
      String isFinished = AppLocale.labels.processIsFinished;
      errorMessage.write(isFinished);
      if (errorMessage.toString() == isFinished) {
        Future.delayed(const Duration(seconds: 2), () => setState(() => errorMessage.clear()));
      }
    });
  }

  Future<String> _find(AppDataType type, List<dynamic> line, dynamic value, String? def) async {
    if (value == null) {
      return def ?? '';
    }
    String? uuid;
    if (_cache[type] == null) {
      _cache[type] = <String, String?>{};
    }
    if (_cache[type]?[value] != null) {
      uuid = _cache[type]?[value];
    } else {
      final item = state.getList(type).where((element) => element.title == value).firstOrNull;
      uuid = item?.uuid;
      _cache[type]![value] = uuid ?? '';
    }
    return uuid ?? await _new(type, line, value);
  }

  dynamic _get(List<dynamic> line, String type) {
    final index = columnMap.indexOf(type);
    return index >= 0 ? line[index] : null;
  }

  Currency? _getCurrency(List<dynamic> line) {
    return CurrencyProvider.findByCode(_get(line, attrBillCurrency));
  }

  Future<String> _new(AppDataType type, List<dynamic> line, dynamic value) async {
    dynamic newItem;
    switch (type) {
      case AppDataType.accounts:
        newItem = state.add(AccountAppData(
          title: value,
          type: AppAccountType.account.toString(),
          details: 0.0,
          currency: _getCurrency(line),
          hidden: false,
        ));
        break;
      default:
        newItem = state.add(BudgetAppData(
          title: value,
          currency: _getCurrency(line),
          hidden: false,
        ));
    }
    _cache[type]![value] = newItem.uuid;
    TransactionLog.save(newItem);
    return newItem.uuid;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    double indent = ThemeHelper.getIndent(2);
    FocusController.init();

    return Consumer<AppData>(builder: (context, appState, _) {
      state = appState;
      return SingleChildScrollView(
        controller: FocusController.getController(runtimeType),
        child: Padding(
          padding: EdgeInsets.all(indent),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: indent),
              Text(errorMessage.toString(), style: textTheme.bodyMedium?.copyWith(color: colorScheme.error)),
              if (isLoading) ...[
                SizedBox(height: indent * 6),
                LoadingWidget(isLoading: isLoading),
              ] else if (fileContent != null)
                ...List<Widget>.generate(fileContent!.first.length + 1, (index) {
                  if (index == fileContent!.first.length) {
                    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      SizedBox(height: indent * 2),
                      Text(
                        AppLocale.labels.dateFormat,
                        style: textTheme.bodyLarge,
                      ),
                      Text(
                        AppLocale.labels.dateFormatPattern,
                        style: textTheme.bodyMedium,
                      ),
                      SimpleInput(controller: dateFormat),
                      SizedBox(height: indent * 2),
                      SizedBox(
                        width: double.infinity,
                        child: FloatingActionButton(
                          heroTag: 'import_tab_parse',
                          onPressed: () => wrapCall(parseFile),
                          tooltip: AppLocale.labels.parseFile,
                          child: Text(
                            AppLocale.labels.parseFile,
                          ),
                        ),
                      ),
                    ]);
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: indent),
                      Text(
                        AppLocale.labels.columnMap(fileContent!.first[index]),
                        style: textTheme.bodyLarge,
                      ),
                      ListSelector(
                        options: getMappingTypes(),
                        indent: indent,
                        hintText: AppLocale.labels.columnMapTooltip,
                        setState: (value) => setState(() => columnMap[index] = value),
                      ),
                    ],
                  );
                })
              else ...[
                SizedBox(
                  width: double.infinity,
                  child: FloatingActionButton(
                    heroTag: 'import_tab_pick',
                    onPressed: () => wrapCall(pickFile),
                    tooltip: AppLocale.labels.pickFile,
                    child: Text(
                      AppLocale.labels.pickFile,
                    ),
                  ),
                ),
              ]
            ],
          ),
        ),
      );
    });
  }
}
