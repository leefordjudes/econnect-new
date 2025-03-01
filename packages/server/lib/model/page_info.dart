import 'tally_transaction.dart';

class PageInfo {
  const PageInfo({
    required this.page,
    required this.perPage,
    required this.totalPage,
    required this.records,
    required this.overallTotal,
    required this.pageTotal,
    required this.overallTxns,
    required this.pageTxns,
  });

  final int page;
  final int perPage;
  final int totalPage;
  final List<TallyTransaction> records;
  final num overallTotal;
  final num pageTotal;
  final int overallTxns;
  final int pageTxns;
}
