import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

import 'package:server/model.dart';

var nFormatter = NumberFormat('##,##,##,##0.00');

class TransactionPage extends StatefulWidget {
  const TransactionPage({
    super.key,
    required this.mode,
    required this.tallyTransactions,
    required this.pageTotal,
    required this.overallTotal,
    required this.pageTxns,
    required this.overallTxns,
    required this.onToggleHeaderCheckbox,
    required this.onToggleTxnCheckbox,
  });

  final PageMode mode;
  final List<TallyTransaction> tallyTransactions;
  final num overallTotal;
  final num pageTotal;
  final int overallTxns;
  final int pageTxns;
  final void Function(bool flag) onToggleHeaderCheckbox;
  final void Function(int idx, bool flag) onToggleTxnCheckbox;

  @override
  State<TransactionPage> createState() => TransactionPageState();
}

class TransactionPageState extends State<TransactionPage> {
  num selectedTotal = 0.0;
  bool headerCheckbox = false;

  @override
  void didUpdateWidget(covariant TransactionPage oldWidget) {
    if (widget.tallyTransactions != oldWidget.tallyTransactions) {
      headerCheckbox = false;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    bool disableCursor = widget.tallyTransactions
        .where((e) => e.status == TxnStatus.submitted)
        .toList()
        .isNotEmpty;
    Color headerCheckboxColor(Set<MaterialState> states) {
      const Set<MaterialState> interactiveStates = <MaterialState>{
        MaterialState.pressed,
        MaterialState.hovered,
        MaterialState.focused,
      };
      if (disableCursor) {
        return Colors.grey;
      }
      if (states.any(interactiveStates.contains)) {
        return Colors.blue;
      }
      return Colors.green;
    }

    Color txnCheckboxColor(String adhoc, bool disabled) {
      if (disabled) {
        return Colors.grey;
      }
      if (adhoc == 'H') {
        return Colors.blue;
      }
      return Colors.green;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          height: 40,
          color: widget.mode == PageMode.readyToSend
              ? Theme.of(context).colorScheme.tertiary
              : Theme.of(context).colorScheme.surfaceVariant,
          child: Padding(
            padding: const EdgeInsets.only(left: 0, right: 10),
            child: Row(
              children: [
                SizedBox(
                  width: 36,
                  child: Checkbox(
                    checkColor: Colors.white,
                    side: MaterialStateBorderSide.resolveWith(
                      (states) => const BorderSide(
                        width: 1.0,
                        color: Colors.black54,
                      ),
                    ),
                    fillColor:
                        MaterialStateProperty.resolveWith(headerCheckboxColor),
                    value: headerCheckbox,
                    mouseCursor: disableCursor
                        ? SystemMouseCursors.forbidden
                        : SystemMouseCursors.click,
                    onChanged: disableCursor
                        ? null
                        : (bool? value) {
                            if (widget.tallyTransactions.isNotEmpty) {
                              widget.onToggleHeaderCheckbox(value!);
                              setState(() {
                                headerCheckbox = value;
                              });
                            }
                          },
                  ),
                ),
                SizedBox(
                  width: 120,
                  child: Text(
                    'Beneficary',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onTertiary,
                    ),
                  ),
                ),
                Flexible(
                  flex: 1,
                  fit: FlexFit.tight,
                  child: Text(
                    'Particulars',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onTertiary,
                    ),
                  ),
                ),
                if (widget.mode == PageMode.sentToBank)
                  SizedBox(
                    width: 160,
                    child: Text(
                      'Ref.No',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onTertiary,
                      ),
                    ),
                  ),
                SizedBox(
                  width: 60,
                  child: Text(
                    'Mode',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onTertiary,
                    ),
                  ),
                ),
                SizedBox(
                  width: 120,
                  child: Text(
                    'VoucherNo',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onTertiary,
                    ),
                  ),
                ),
                if (widget.mode == PageMode.sentToBank)
                  SizedBox(
                    width: 120,
                    child: Text(
                      'Status',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onTertiary,
                      ),
                    ),
                  ),
                SizedBox(
                  width: 120,
                  child: Text(
                    'Amount',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onTertiary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
            child: Padding(
          padding: const EdgeInsets.only(top: 5, bottom: 5),
          child: ListView.builder(
            itemCount: widget.tallyTransactions.length,
            itemBuilder: (context, index) {
              final TxnStatus txnStatus =
                  widget.tallyTransactions[index].status;
              final bool disabled = (widget.mode == PageMode.sentToBank) &&
                  (txnStatus == TxnStatus.submitted);
              return Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      width: 0.7,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 0,
                    right: 10,
                    top: 2,
                    bottom: 2,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      SizedBox(
                        width: 36,
                        child: Checkbox(
                          checkColor: Colors.white,
                          side: MaterialStateBorderSide.resolveWith(
                            (states) => const BorderSide(
                              width: 1.0,
                              color: Colors.black54,
                            ),
                          ),
                          fillColor: MaterialStateProperty.all(
                            txnCheckboxColor(
                              widget.tallyTransactions[index].adhoc,
                              disabled,
                            ),
                          ),
                          value: widget.tallyTransactions[index].selected,
                          mouseCursor: disabled
                              ? SystemMouseCursors.forbidden
                              : SystemMouseCursors.click,
                          onChanged: disabled
                              ? null
                              : (bool? value) {
                                  widget.onToggleTxnCheckbox(index, value!);
                                  setState(() {
                                    headerCheckbox = widget.tallyTransactions
                                            .where((e) => e.selected == true)
                                            .toList()
                                            .length ==
                                        widget.tallyTransactions.length;
                                  });
                                },
                        ),
                      ),
                      SizedBox(
                        width: 120,
                        child: Text(
                          widget.tallyTransactions[index].beneficiaryCode,
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        fit: FlexFit.tight,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Text(
                              widget.tallyTransactions[index].particulars,
                              textAlign: TextAlign.left,
                              softWrap: false,
                              maxLines: 1,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (widget.mode == PageMode.sentToBank)
                        SizedBox(
                          width: 160,
                          child: Text(
                            widget.tallyTransactions[index].id.toUpperCase(),
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                        ),
                      SizedBox(
                        width: 60,
                        child: Text(
                          widget.tallyTransactions[index].transfermode,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 120,
                        child: Text(
                          widget.tallyTransactions[index].vchNo,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      ),
                      if (widget.mode == PageMode.sentToBank)
                        SizedBox(
                          width: 120,
                          child: Text(
                            txnStatusEnumMap[txnStatus] ?? '',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                        ),
                      SizedBox(
                        width: 120,
                        child: Text(
                          nFormatter
                              .format(widget.tallyTransactions[index].amount),
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        )),
        Container(
          width: double.infinity,
          height: 40,
          color: widget.mode == PageMode.readyToSend
              ? Theme.of(context).colorScheme.tertiary
              : Theme.of(context).colorScheme.surfaceVariant,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'No of Transactions : ${widget.pageTxns} / ${widget.overallTxns}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onTertiary,
                  ),
                ),
                Text(
                  'Selected Total : ${widget.tallyTransactions.where((e) => e.selected == true).length} - ${nFormatter.format(widget.tallyTransactions.where((e) => e.selected == true).fold(0.0, (s, x) => s + x.amount))}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onTertiary,
                  ),
                ),
                Text(
                  'Total : ${nFormatter.format(widget.pageTotal)} / ${nFormatter.format(widget.overallTotal)}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onTertiary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
