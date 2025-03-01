import 'package:dio/dio.dart';
import 'package:xml/xml.dart';

import './tally_query.dart';
import '../http_client.dart';
import '../model.dart';

class Tally {
  const Tally._();

  static Future<CompanyInfo?> getCompanyInfo() async {
    try {
      final response = await tallyHttp.get(
        '/',
        data: TallyQuery.companyInfo,
        options: Options(contentType: 'Content-Type: application/xml'),
      );
      final doc = XmlDocument.parse(response.data);
      final collection = doc.descendantElements
          .where((e) => e.name.toString() == 'COLLECTION')
          .first;
      final company = collection.descendantElements
          .where((e) => e.name.toString() == 'COMPANY')
          .first;
      final name = company.childElements
          .where((e) => e.name.toString() == 'CURRENTCOMPANY')
          .first
          .innerText
          .trim();
      final serialNumber = company.childElements
          .where((e) => e.name.toString() == 'SERIALNUMBER')
          .first
          .innerText
          .trim();
      final companyInfo = CompanyInfo(name, serialNumber);
      return companyInfo;
    } catch (e) {
      return null;
    }
  }

  static Future<List<BankAccount>> getBankAccounts(String companyName) async {
    try {
      final response = await tallyHttp.get(
        '/',
        data: TallyQuery.bankAccounts(companyName),
        options: Options(contentType: 'Content-Type: application/xml'),
      );

      final doc = XmlDocument.parse(response.data);
      final collection = doc.descendantElements
          .where((e) => e.name.toString() == 'COLLECTION')
          .first;
      final ledgers = collection.descendantElements
          .where((e) => e.name.toString() == 'LEDGER')
          .toList();
      final bankAccounts = <BankAccount>[];
      for (final ledger in ledgers) {
        final acName = ledger.attributes
            .where((a) => a.name.toString() == 'NAME')
            .first
            .value;
        final acNum = ledger.descendantElements.first;
        bankAccounts.add(BankAccount(acName, acNum.innerText));
      }

      return bankAccounts;
    } on DioException catch (e) {
      return Future.error(e.message.toString());
    } on Exception catch (e) {
      return Future.error(e.toString());
    } catch (e) {
      return Future.error(e.toString());
    }
  }

  static Future<PageInfo> getTallyTransactions(
    PageMode pageMode,
    List<BankTransaction> exBankTxns,
    String companyName,
    String bankName,
    int page,
    int perPage,
    String? currentDate,
  ) async {
    // print('$page, $perPage');
    try {
      final response = await tallyHttp.get(
        '/',
        data: TallyQuery.fetchTransactions(companyName, bankName, currentDate),
        options: Options(contentType: 'Content-Type: application/xml'),
      );

      final doc = XmlDocument.parse(response.data);
      final paylinks = doc.descendantElements
          .where((e) => e.name.toString() == 'PAYLINK')
          .toList();
      List<TallyTransaction> tallyTransactions = [];
      for (var paylink in paylinks) {
        final bankAllocation = paylink.descendantElements
            .where((e) => e.name.toString() == 'PAYALLOCATIONDATA.LIST')
            .first;
        final uniqueReferenceNumber = bankAllocation.childElements
            .where((e) => e.name.toString() == 'UNIQUEREFERENCENUMBER')
            .first
            .innerText
            .trim();

        final email = paylink.childElements
            .where((e) => e.name.toString() == 'EMAIL')
            .first
            .innerText
            .trim();

        final ifsCode = paylink.childElements
            .where((e) => e.name.toString() == 'IFSCODE')
            .first
            .innerText
            .trim();

        final bankName = paylink.childElements
            .where((e) => e.name.toString() == 'BANKNAME')
            .first
            .innerText
            .trim();

        final bankAmount = paylink.childElements
            .where((e) => e.name.toString() == 'BANKAMOUNT')
            .first
            .innerText
            .trim();

        final bankPartyName = paylink.childElements
            .where((e) => e.name.toString() == 'BANKPARTYNAME')
            .first
            .innerText
            .trim();

        final accountNumber = paylink.childElements
            .where((e) => e.name.toString() == 'ACCOUNTNUMBER')
            .first
            .innerText
            .trim();

        String beneficiaryCode = paylink.childElements
            .where((e) => e.name.toString() == 'BENEFICIARYCODE')
            .first
            .innerText
            .trim();
        String adhoc = 'N';
        if (beneficiaryCode.isEmpty && accountNumber.isNotEmpty) {
          adhoc = 'H';
          beneficiaryCode = 'AC$accountNumber';
        }

        final tm = paylink.childElements
            .where((e) => e.name.toString() == 'TRANSFERMODE')
            .first
            .innerText
            .trim();
        final transferMode =
            switch (tm) { 'NEFT' => 'NFT', 'RTGS' => 'RTG', _ => 'WIB' };

        final voucher = paylink.descendantElements
            .where((e) => e.name.toString() == 'LEDGERENTRIES.LIST')
            .first;
        final voucherDate = voucher.childElements
            .where((e) => e.name.toString() == 'DATE')
            .first
            .innerText
            .trim();

        final voucherNarration = voucher.childElements
            .where((e) => e.name.toString() == 'NARRATION')
            .first
            .innerText
            .trim();

        final voucherId = voucher.childElements
            .where((e) => e.name.toString() == 'MASTERID')
            .first
            .innerText
            .trim();

        final voucherNo = voucher.childElements
            .where((e) => e.name.toString() == 'VOUCHERNUMBER')
            .first
            .innerText
            .trim();

        final voucherTypeName = voucher.childElements
            .where((e) => e.name.toString() == 'VOUCHERTYPENAME')
            .first
            .innerText
            .trim();

        var tallyTxn = TallyTransaction(
          id: uniqueReferenceNumber,
          status: TxnStatus.ready,
          date: voucherDate,
          particulars: bankPartyName,
          vchType: voucherTypeName,
          vchId: voucherId,
          vchNo: voucherNo,
          adhoc: adhoc,
          beneficiaryCode: beneficiaryCode,
          transfermode: transferMode,
          amount: num.tryParse(bankAmount) ?? 0,
          narration: voucherNarration,
          email: email,
          ifscode: ifsCode,
          bankName: bankName,
        );
        // print(tallyTxn.toJson());
        tallyTransactions.add(tallyTxn);
      }
      var exBankTxnsIds = exBankTxns.map((e) => e.id).toList();
      List<TallyTransaction> filteredTallyTxns = [];
      if (pageMode == PageMode.readyToSend) {
        // print(pageMode);
        filteredTallyTxns = tallyTransactions
            .where((e) => !exBankTxnsIds.contains(e.id.toUpperCase()))
            .toList();
      } else {
        // print(pageMode);
        filteredTallyTxns = tallyTransactions
            .where((e) => exBankTxnsIds.contains(e.id.toUpperCase()))
            .toList();
        for (var (idx, txn) in filteredTallyTxns.indexed) {
          var exTxn =
              exBankTxns.where((e) => e.id == txn.id.toUpperCase()).first;
          filteredTallyTxns[idx] = txn.copyWith(
            status: exTxn.status,
            particulars:
                '${exTxn.particulars} the Text widget is essential for displaying text, but overflow issues can arise.',
          );
        }
      }

      filteredTallyTxns.sort((b, a) => a.amount.compareTo(b.amount));
      filteredTallyTxns.sort((a, b) => a.vchId.compareTo(b.vchId));
      final overallTotal = filteredTallyTxns.fold(0.0, (s, x) => s + x.amount);
      final totalPage = (filteredTallyTxns.length / perPage).ceil();
      final skip = page > 0 ? (page - 1) * perPage : 0;
      final lastRecord = (skip + perPage) > filteredTallyTxns.length
          ? filteredTallyTxns.length
          : skip + perPage;

      List<TallyTransaction> txns = skip > filteredTallyTxns.length
          ? []
          : filteredTallyTxns.sublist(skip, lastRecord);
      final pageTotal = txns.fold(0.0, (s, x) => s + x.amount);
      return PageInfo(
        page: filteredTallyTxns.isNotEmpty ? page : 1,
        perPage: perPage,
        totalPage: filteredTallyTxns.isNotEmpty ? totalPage : 1,
        records: txns,
        overallTotal: overallTotal,
        pageTotal: pageTotal,
        overallTxns: filteredTallyTxns.length,
        pageTxns: txns.length,
      );
    } on DioException catch (e) {
      return Future.error(e.message.toString());
    } on Exception catch (e) {
      return Future.error(e.toString());
    } catch (e) {
      return Future.error(e.toString());
    }
  }
}
