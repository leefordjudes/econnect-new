const txnStatusEnumMap = {
  TxnStatus.ready: 'ready',
  TxnStatus.submitted: 'submitted',
  TxnStatus.failed: 'failed',
  TxnStatus.suspect: 'suspect',
  TxnStatus.incomplete: 'incomplete',
};

enum TxnStatus {
  ready,
  submitted,
  failed,
  suspect,
  incomplete;

  String toMap() {
    return txnStatusEnumMap[this]!;
  }

  static TxnStatus fromMap(String key) {
    return switch (key) {
      'ready' => TxnStatus.ready,
      'submitted' => TxnStatus.submitted,
      'failed' => TxnStatus.failed,
      'suspect' => TxnStatus.suspect,
      _ => TxnStatus.incomplete,
    };
  }
}
