// Copyright 2023 The terCAD team. All rights reserved.
// Use of this source code is governed by a CC BY-NC-ND 4.0 license that can be
// found in the LICENSE file.

import 'package:adaptive_breakpoints/adaptive_breakpoints.dart';
import 'package:app_finance/_classes/app_route.dart';
import 'package:app_finance/_classes/data/account_app_data.dart';
import 'package:app_finance/_classes/data/exchange.dart';
import 'package:app_finance/_classes/focus_controller.dart';
import 'package:app_finance/custom_text_theme.dart';
import 'package:app_finance/_classes/app_data.dart';
import 'package:app_finance/helpers/theme_helper.dart';
import 'package:app_finance/widgets/_forms/currency_exchange_input.dart';
import 'package:app_finance/widgets/_wrappers/required_widget.dart';
import 'package:app_finance/widgets/_wrappers/row_widget.dart';
import 'package:app_finance/widgets/_forms/currency_selector.dart';
import 'package:app_finance/widgets/_forms/list_account_selector.dart';
import 'package:app_finance/widgets/_forms/simple_input.dart';
import 'package:currency_picker/currency_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import 'package:provider/provider.dart';

class TransferTab extends StatefulWidget {
  final String? accountFrom;
  final String? accountTo;
  final double? amount;
  final Currency? currency;

  const TransferTab({
    super.key,
    this.accountFrom,
    this.accountTo,
    this.amount,
    this.currency,
  });

  @override
  TransferTabState createState() => TransferTabState();
}

class TransferTabState extends State<TransferTab> {
  late AppData state;
  String? accountFrom;
  String? accountTo;
  late TextEditingController amount;
  Currency? currency;
  bool hasErrors = false;

  @override
  void initState() {
    accountFrom = widget.accountFrom;
    accountTo = widget.accountTo;
    amount = TextEditingController(text: widget.amount != null ? widget.amount.toString() : '');
    currency = widget.currency;
    super.initState();
  }

  @override
  dispose() {
    amount.dispose();
    super.dispose();
  }

  bool hasFormErrors() {
    setState(() => hasErrors = accountFrom == null || accountTo == null);
    return hasErrors;
  }

  void updateStorage() {
    String uuidFrom = accountFrom ?? '';
    final course = Exchange(store: state);
    AccountAppData from = state.getByUuid(uuidFrom);
    from.details -= course.reform(double.tryParse(amount.text), from.currency, currency);
    state.update(AppDataType.accounts, uuidFrom, from);
    String uuidTo = accountTo ?? '';
    AccountAppData to = state.getByUuid(uuidTo);
    to.details += course.reform(double.tryParse(amount.text), currency, to.currency);
    state.update(AppDataType.accounts, uuidTo, to);
  }

  Widget buildButton(BuildContext context, BoxConstraints constraints) {
    var helper = ThemeHelper(windowType: getWindowType(context));
    String title = AppLocalizations.of(context)!.createTransferTooltip;
    FocusController.init(3);
    return SizedBox(
      width: constraints.maxWidth - helper.getIndent() * 4,
      child: FloatingActionButton(
        onPressed: () => {
          setState(() {
            if (hasFormErrors()) {
              return;
            }
            updateStorage();
            Navigator.popAndPushNamed(context, AppRoute.homeRoute);
          })
        },
        focusNode: FocusController.getFocusNode(),
        tooltip: title,
        child: Align(
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.save),
              SizedBox(height: helper.getIndent()),
              Text(title, style: Theme.of(context).textTheme.headlineMedium)
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // FocusController.dispose();
    final TextTheme textTheme = Theme.of(context).textTheme;
    double indent = ThemeHelper(windowType: getWindowType(context)).getIndent() * 2;
    double offset = MediaQuery.of(context).size.width - indent * 3;
    int focusOrder = FocusController.DEFAULT;
    FocusController.setContext(context);

    return LayoutBuilder(builder: (context, constraints) {
      return Consumer<AppData>(builder: (context, appState, _) {
        state = appState;
        return Scaffold(
          body: SingleChildScrollView(
            controller: FocusController.getController(),
            child: Container(
              margin: EdgeInsets.fromLTRB(indent, indent, indent, 90),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RequiredWidget(
                    title: AppLocalizations.of(context)!.accountFrom,
                    showError: hasErrors && accountFrom == null,
                  ),
                  ListAccountSelector(
                    value: accountFrom,
                    state: state,
                    setState: (value) => setState(() => accountFrom = value),
                    style: textTheme.numberMedium.copyWith(color: textTheme.headlineSmall?.color),
                    indent: indent,
                    width: offset,
                    focusOrder: focusOrder += 1,
                  ),
                  SizedBox(height: indent),
                  RequiredWidget(
                    title: AppLocalizations.of(context)!.accountTo,
                    showError: hasErrors && accountTo == null,
                  ),
                  ListAccountSelector(
                    value: accountTo,
                    state: state,
                    setState: (value) => setState(() {
                      accountTo = value;
                      currency ??= state.getByUuid(value).currency;
                    }),
                    style: textTheme.numberMedium.copyWith(color: textTheme.headlineSmall?.color),
                    indent: indent,
                    width: offset,
                    focusOrder: focusOrder += 1,
                  ),
                  SizedBox(height: indent),
                  RowWidget(
                    indent: indent,
                    maxWidth: offset,
                    chunk: const [0.32, 0.68],
                    children: [
                      [
                        Text(
                          AppLocalizations.of(context)!.currency,
                          style: textTheme.bodyLarge,
                        ),
                        Container(
                          color: Theme.of(context).colorScheme.inversePrimary.withOpacity(0.3),
                          width: double.infinity,
                          child: CurrencySelector(
                            value: currency?.code,
                            setView: (Currency currency) => currency.code,
                            setState: (value) => setState(() => currency = value),
                            focusOrder: focusOrder += 1,
                          ),
                        ),
                      ],
                      [
                        Text(
                          AppLocalizations.of(context)!.expenseTransfer,
                          style: textTheme.bodyLarge,
                        ),
                        SimpleInput(
                          controller: amount,
                          type: const TextInputType.numberWithOptions(decimal: true),
                          tooltip: AppLocalizations.of(context)!.billSetTooltip,
                          style: textTheme.numberMedium.copyWith(color: textTheme.headlineSmall?.color),
                          formatter: [
                            SimpleInput.filterDouble,
                          ],
                          focusOrder: focusOrder += 1,
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: indent),
                  CurrencyExchangeInput(
                    width: offset + indent,
                    indent: indent,
                    target: currency,
                    state: state,
                    targetAmount: double.tryParse(amount.text),
                    source: [
                      accountFrom != null ? state.getByUuid(accountFrom!).currency : null,
                      accountTo != null ? state.getByUuid(accountTo!).currency : null,
                    ].cast<Currency?>(),
                  ),
                ],
              ),
            ),
          ),
          floatingActionButton: buildButton(context, constraints),
        );
      });
    });
  }
}
