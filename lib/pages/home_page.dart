import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:window_manager/window_manager.dart';

import 'package:server/tally.dart';
import 'package:server/model.dart';
import 'package:server/server.dart';

import 'dialogs/dialogs.dart';
import 'transaction_page.dart';
import '../widgets/widgets.dart';
import '../theme/theme.dart';

final DateFormat parseDt = DateFormat('dd-MM-yyyy');
final DateFormat formatDt = DateFormat('yyyyMMdd');

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final paginationController = TextEditingController();
  PageMode pageMode = PageMode.readyToSend;
  CompanyInfo? companyInfo;
  Configuration? savedConfiguration;
  Settings? savedSettings;
  List<TallyTransaction> tallyTransactions = [];
  int totalPage = 1;
  num overallTotal = 0.0;
  num pageTotal = 0.0;
  int overallTxns = 0;
  int pageTxns = 0;
  String selectedBankAccountName = ''; // get from db;
  String selectedBankAccountNumber = ''; // get from db;
  String selectedDate = '01-04-2024'; //parseDt.format(DateTime.now());
  // String formattedDate = //'20240401'; //formatDt.format(DateTime.now());

  void selectDate() async {
    final initialDate = DateTime.now();

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(initialDate.year - 2),
      lastDate: DateTime(initialDate.year + 2),
    );
    if (pickedDate != null && selectedDate != parseDt.format(pickedDate)) {
      setState(() {
        selectedDate = parseDt.format(pickedDate);
      });
      await getTallyTransactions();
    }
  }

  Future<void> openConfiguration() async {
    if (companyInfo == null) {
      final tallyCompanyInfo = await Tally.getCompanyInfo();
      if (tallyCompanyInfo != null) {
        setState(() {
          companyInfo = tallyCompanyInfo;
        });
      } else {
        //todo! show alert dialog
        return;
      }
    }
    if (!mounted) return;
    final server = context.read<Server>();
    final config = await showDialog<Configuration>(
      context: context,
      builder: (context) {
        return Align(
          alignment: Alignment.center,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: SizedBox(
              height: 370,
              width: 600,
              child: ConfigurationDialog(companyInfo!, savedConfiguration),
            ),
          ),
        );
      },
    );
    if (config != null && config.isNotEmpty) {
      var result = await server.setConfiguration(config);
      if (result) {
        setState(() {
          selectedBankAccountName = config.accountName;
          selectedBankAccountNumber = config.accountNumber;
        });
      } else {
        //todo! show alert dialog
        print('set configuration fails');
      }
    }
  }

  Future<void> openSettings() async {
    final storedSettings = await showDialog<Settings>(
      context: context,
      builder: (context) {
        return Align(
          alignment: Alignment.center,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: const SizedBox(
              height: 470,
              width: 750,
              child: SettingsDialog(),
            ),
          ),
        );
      },
    );
    if (storedSettings != null) {
      setState(() {
        savedSettings = storedSettings;
      });
      await pageInit();
    }
  }

  Future<void> getCompanyInfo() async {
    final tallyCompanyInfo = await Tally.getCompanyInfo();
    if (tallyCompanyInfo != null && mounted) {
      setState(() {
        companyInfo = tallyCompanyInfo;
      });
    } else {
      //todo! show alert dialog
      print('could not connect tally');
      return;
    }
  }

  Future<void> getSettings() async {
    if (mounted) {
      final dbSettings = await context.read<Server>().getSettings();
      if (dbSettings != null) {
        savedSettings = dbSettings;
      }
    }
  }

  Future<void> getConfiguration() async {
    final server = context.read<Server>();
    final dbConfiguration = await server.getConfiguration();
    if (dbConfiguration != null) {
      setState(() {
        savedConfiguration = dbConfiguration;
        selectedBankAccountName = dbConfiguration.accountName;
        selectedBankAccountNumber = dbConfiguration.accountNumber;
      });
    } else {
      print('No configuration found');
    }
  }

  Future<void> getTallyTransactions() async {
    final server = context.read<Server>();
    if (companyInfo?.name != null && selectedBankAccountName.isNotEmpty) {
      // print('getTallyTransactions called');
      final perPage = savedSettings?.recordsPerPage ?? 25;
      final page = paginationController.text.isEmpty
          ? 1
          : int.tryParse(paginationController.text) ?? 1;

      var exBankTxns = await server.getIncompleteBankTransaction();
      // print(pageMode);
      var res = await Tally.getTallyTransactions(
        pageMode,
        exBankTxns,
        companyInfo!.name,
        selectedBankAccountName,
        page,
        perPage,
        selectedDate,
      );
      // print('tlyTxns: ${res.records.length}');

      // for (var txn in res.records) {
      //   print('-----------------');
      //   print(txn.toJson());
      //   print('-----------------');
      // }
      setState(() {
        paginationController.text = res.page.toString();
        totalPage = res.totalPage;
        overallTotal = res.overallTotal;
        pageTotal = res.pageTotal;
        overallTxns = res.overallTxns;
        pageTxns = res.pageTxns;
        tallyTransactions = res.records;
      });
    }
  }

  void firstPage() async {
    setState(() {
      paginationController.text = '1'.toString();
    });
    await getTallyTransactions();
  }

  void prevPage() async {
    int page = paginationController.text.isEmpty
        ? 1
        : int.tryParse(paginationController.text) ?? 1;
    page = (page - 1) <= 0 ? 1 : (page - 1);
    setState(() {
      paginationController.text = page.toString();
    });
    await getTallyTransactions();
  }

  void getPage(String val) async {
    await getTallyTransactions();
  }

  void nextPage() async {
    int page = paginationController.text.isEmpty
        ? 1
        : int.tryParse(paginationController.text) ?? 1;

    page = page + 1;
    if (page > totalPage) {
      page = totalPage;
    }
    setState(() {
      paginationController.text = page.toString();
    });
    await getTallyTransactions();
  }

  void lastPage() async {
    setState(() {
      paginationController.text = totalPage.toString();
    });
    await getTallyTransactions();
  }

  Future<void> pageInit() async {
    if (mounted) {
      // print('page Init');
      final theme = context.read<GetStorage>().read('theme').toString();
      context.read<ThemeCubit>().setTheme(theme);
      paginationController.text = '1';
      await getCompanyInfo();
      await getSettings();
      await getConfiguration();
      if (companyInfo?.name == null) return;
      await getTallyTransactions();
    }
  }

  void showReadyToSend() async {
    setState(() {
      pageMode = PageMode.readyToSend;
      paginationController.text = '1';
    });
    await getTallyTransactions();
  }

  void showSentToBank() async {
    setState(() {
      pageMode = PageMode.sentToBank;
      paginationController.text = '1';
    });
    await getTallyTransactions();
  }

  void sendToBank() async {
    //send selected transactions to bank
    final server = context.read<Server>();
    final selectedTxns = tallyTransactions.where((e) => e.selected).toList();
    if (selectedTxns.isNotEmpty &&
        savedSettings != null &&
        savedConfiguration != null) {
      var result = await server.sendToBank(
        selectedTxns,
        selectedBankAccountNumber,
        savedSettings!,
        savedConfiguration!,
      );
      if (result) {
        //todo! show snackbar: Transactions send successfully
        await pageInit();
        print('Transactions send successfully');
      }
    } else {
      //todo! show snackbar: can not send empty transaction list
    }
  }

  void updateStatus() {
    //send selected transactions to bank
  }

  void reset() async {
    print('reset called');
    final server = context.read<Server>();
    final selectedTxns = tallyTransactions.where((e) => e.selected).toList();
    if (selectedTxns.isNotEmpty &&
        savedSettings != null &&
        savedConfiguration != null) {
      var result = await server.resetSendToBank(
        selectedTxns,
      );
      if (result) {
        //todo! show snackbar: Transactions send successfully
        await pageInit();
        print('Transactions send successfully');
      }
    } else {
      //todo! show snackbar: can not send empty transaction list
    }
  }

  @override
  void initState() {
    pageInit();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    void toggleAllTransaction(bool flag) {
      for (var txn in tallyTransactions) {
        txn.selected = flag;
      }
    }

    void toggleTransaction(int idx, bool flag) {
      tallyTransactions[idx].selected = flag;
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(kWindowCaptionHeight),
        child: EconnectTitleBar(),
      ),
      body: Column(
        children: [
          Container(
              width: double.infinity,
              height: 70,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black87.withOpacity(0.4),
                    spreadRadius: 3,
                    blurRadius: 3,
                    offset: const Offset(0, 1), // changes position of shadow
                  ),
                ],
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: 30,
                    width: double.infinity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 1,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: selectDate,
                                padding: EdgeInsets.zero,
                                icon: const Icon(Icons.calendar_month_outlined),
                                color:
                                    Theme.of(context).colorScheme.onSecondary,
                              ),
                              Text(
                                'Date : ',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color:
                                      Theme.of(context).colorScheme.onSecondary,
                                ),
                              ),
                              Text(
                                selectedDate,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w400,
                                  color:
                                      Theme.of(context).colorScheme.onSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                companyInfo?.name ?? '',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      Theme.of(context).colorScheme.onSecondary,
                                  letterSpacing: 2,
                                ),
                              ),
                              const SizedBox(width: 10),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () {
                                openConfiguration();
                              },
                              icon: const Icon(Icons.settings),
                              color: Theme.of(context).colorScheme.onSecondary,
                            ),
                            Text(
                              'Bank : ',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color:
                                    Theme.of(context).colorScheme.onSecondary,
                              ),
                            ),
                            Text(
                              selectedBankAccountName,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                                color:
                                    Theme.of(context).colorScheme.onSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            OverflowBar(
                              spacing: 10,
                              children: <Widget>[
                                if (pageMode == PageMode.readyToSend)
                                  ElevatedButton(
                                    onPressed: showReadyToSend,
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(3.0),
                                      ),
                                      backgroundColor: Theme.of(context)
                                          .colorScheme
                                          .primaryContainer,
                                    ),
                                    child: const Text(
                                      'Ready To Send',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                if (pageMode == PageMode.readyToSend)
                                  OutlinedButton(
                                    onPressed: showSentToBank,
                                    style: OutlinedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(3.0),
                                      ),
                                      side: BorderSide(
                                        width: 1.0,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .inversePrimary,
                                      ),
                                      backgroundColor: Theme.of(context)
                                          .colorScheme
                                          .inversePrimary,
                                    ),
                                    child: const Text(
                                      'Sent To Bank',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                if (pageMode != PageMode.readyToSend)
                                  OutlinedButton(
                                    onPressed: showReadyToSend,
                                    style: OutlinedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(3.0),
                                      ),
                                      side: BorderSide(
                                        width: 1.0,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .inversePrimary,
                                      ),
                                      backgroundColor: Theme.of(context)
                                          .colorScheme
                                          .inversePrimary,
                                    ),
                                    child: const Text(
                                      'Ready To Send',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                if (pageMode != PageMode.readyToSend)
                                  ElevatedButton(
                                    onPressed: showSentToBank,
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(3.0),
                                      ),
                                      backgroundColor: Theme.of(context)
                                          .colorScheme
                                          .primaryContainer,
                                    ),
                                    child: const Text(
                                      'Sent To Bank',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                const SizedBox(width: 0),
                              ],
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ],
              )),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 8,
              ),
              child: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: pageMode == PageMode.readyToSend
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.secondaryContainer,
                  boxShadow: [
                    if (Theme.of(context).brightness == Brightness.light)
                      BoxShadow(
                        color: Colors.black87.withOpacity(0.4),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset:
                            const Offset(0, 2), // changes position of shadow
                      ),
                    if (Theme.of(context).brightness == Brightness.dark)
                      BoxShadow(
                        color: Colors.white24.withOpacity(0.4),
                        spreadRadius: 3,
                        blurRadius: 5,
                        offset:
                            const Offset(0, 1), // changes position of shadow
                      ),
                  ],
                ),
                child: TransactionPage(
                  mode: pageMode,
                  tallyTransactions: tallyTransactions,
                  pageTotal: pageTotal,
                  overallTotal: overallTotal,
                  pageTxns: pageTxns,
                  overallTxns: overallTxns,
                  onToggleHeaderCheckbox: toggleAllTransaction,
                  onToggleTxnCheckbox: toggleTransaction,
                ),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              boxShadow: [
                BoxShadow(
                  color: Colors.black87.withOpacity(0.4),
                  spreadRadius: 3,
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OverflowBar(
                  spacing: 10,
                  children: <Widget>[
                    const SizedBox(width: 0),
                    if (pageMode == PageMode.readyToSend)
                      ElevatedButton(
                        onPressed: sendToBank,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(3.0),
                          ),
                          backgroundColor:
                              Theme.of(context).colorScheme.primaryContainer,
                        ),
                        child: const Text(
                          ' Send To Bank',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    if (pageMode == PageMode.readyToSend)
                      ElevatedButton(
                        onPressed: pageInit,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(3.0),
                          ),
                          backgroundColor:
                              Theme.of(context).colorScheme.primaryContainer,
                        ),
                        child: const Text(
                          'Refresh',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    if (pageMode == PageMode.sentToBank)
                      ElevatedButton(
                        onPressed: sendToBank,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(3.0),
                          ),
                          backgroundColor:
                              Theme.of(context).colorScheme.primaryContainer,
                        ),
                        child: const Text(
                          'Update Status',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    if (pageMode == PageMode.sentToBank)
                      ElevatedButton(
                        onPressed: reset,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(3.0),
                          ),
                          backgroundColor:
                              Theme.of(context).colorScheme.primaryContainer,
                        ),
                        child: const Text(
                          '  Reset  ',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    VerticalDivider(
                        color:
                            Theme.of(context).colorScheme.onTertiaryContainer),
                    IconButton(
                      onPressed: firstPage,
                      iconSize: 28,
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.first_page),
                      color: Theme.of(context).colorScheme.onSecondary,
                    ),
                    IconButton(
                      onPressed: prevPage,
                      iconSize: 18,
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.arrow_back_ios),
                      color: Theme.of(context).colorScheme.onSecondary,
                    ),
                    SizedBox(
                      width: 40,
                      height: 30,
                      child: TextField(
                        controller: paginationController,
                        onSubmitted: getPage,
                        cursorColor: Colors.black54,
                        textAlign: TextAlign.center,
                        textAlignVertical: TextAlignVertical.center,
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^\d{0,2}')),
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSecondary,
                          fontSize: 16,
                          height: 1,
                        ),
                        cursorHeight: 16,
                        decoration: InputDecoration(
                          filled: true,
                          // fillColor: Colors.white70,
                          fillColor: Theme.of(context).scaffoldBackgroundColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6.0),
                          ),
                          contentPadding: EdgeInsets.zero,
                          // contentPadding:
                          //     const EdgeInsets.only(top: 5, bottom: 5),
                        ),
                      ),
                    ),
                    Text(
                      '  /  $totalPage',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                    ),
                    IconButton(
                      onPressed: nextPage,
                      iconSize: 18,
                      icon: const Icon(Icons.arrow_forward_ios),
                      color: Theme.of(context).colorScheme.onSecondary,
                    ),
                    IconButton(
                      onPressed: lastPage,
                      iconSize: 28,
                      icon: const Icon(Icons.last_page),
                      color: Theme.of(context).colorScheme.onSecondary,
                    ),
                    VerticalDivider(
                        color:
                            Theme.of(context).colorScheme.onTertiaryContainer),
                    TextButton.icon(
                      label: Text(
                        'Settings',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onSecondary,
                        ),
                      ),
                      onPressed: openSettings,
                      icon: Icon(
                        Icons.construction,
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
