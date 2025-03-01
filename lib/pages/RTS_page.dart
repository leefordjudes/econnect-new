import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

import 'package:server/model.dart';

var nFormatter = NumberFormat('##,##,##,##0.00');

class RTSPage extends StatefulWidget {
  const RTSPage({
    super.key,
    required this.tallyTransactions,
    required this.pageTotal,
    required this.overallTotal,
    required this.pageTxns,
    required this.overallTxns,
    required this.onToggleHeaderCheckbox,
    required this.onToggleTxnCheckbox,
  });

  final List<TallyTransaction> tallyTransactions;
  final num overallTotal;
  final num pageTotal;
  final int overallTxns;
  final int pageTxns;
  final void Function(bool flag) onToggleHeaderCheckbox;
  final void Function(int idx, bool flag) onToggleTxnCheckbox;

  @override
  State<RTSPage> createState() => RTSPageState();
}

class RTSPageState extends State<RTSPage> {
  num selectedTotal = 0.0;
  bool headerCheckbox = false;

  @override
  void didUpdateWidget(covariant RTSPage oldWidget) {
    if (widget.tallyTransactions != oldWidget.tallyTransactions) {
      headerCheckbox = false;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    Color headerCheckboxColor(Set<MaterialState> states) {
      const Set<MaterialState> interactiveStates = <MaterialState>{
        MaterialState.pressed,
        MaterialState.hovered,
        MaterialState.focused,
      };
      if (states.any(interactiveStates.contains)) {
        return Colors.blue;
      }
      return Colors.green;
    }

    Color txnCheckboxColor(String adhoc) {
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
          color: Theme.of(context).colorScheme.tertiary,
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
                          width: 0.0, color: Colors.transparent),
                    ),
                    fillColor:
                        MaterialStateProperty.resolveWith(headerCheckboxColor),
                    value: headerCheckbox,
                    onChanged: (bool? value) {
                      if (widget.tallyTransactions.isNotEmpty) {
                        widget.onToggleHeaderCheckbox(value!);
                        setState(() {
                          headerCheckbox = value;
                        });
                      }
                    },
                  ),
                ),
                Flexible(
                  flex: 25,
                  fit: FlexFit.tight,
                  child: Text(
                    'Beneficary',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onTertiary,
                    ),
                  ),
                ),
                Flexible(
                  flex: 55,
                  fit: FlexFit.tight,
                  child: Text(
                    'Particulars',
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
                Flexible(
                  flex: 20,
                  fit: FlexFit.tight,
                  child: Text(
                    'VoucherNo',
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
                    top: 5,
                    bottom: 5,
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
                                width: 0.0, color: Colors.transparent),
                          ),
                          fillColor: MaterialStateProperty.all(
                            txnCheckboxColor(
                                widget.tallyTransactions[index].adhoc),
                          ),
                          value: widget.tallyTransactions[index].selected,
                          onChanged: (bool? value) {
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
                      Flexible(
                        flex: 25,
                        fit: FlexFit.tight,
                        child: Text(
                          widget.tallyTransactions[index].beneficiaryCode,
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      ),
                      Flexible(
                        flex: 55,
                        fit: FlexFit.tight,
                        child: Text(
                          widget.tallyTransactions[index].particulars,
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
                      Flexible(
                        flex: 20,
                        fit: FlexFit.tight,
                        child: Text(
                          widget.tallyTransactions[index].vchNo,
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
          color: Theme.of(context).colorScheme.tertiary,
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
