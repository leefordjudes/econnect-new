class TallyQuery {
  static String companyInfo = '''
  <ENVELOPE>
    <HEADER>
        <VERSION>1</VERSION>
        <TALLYREQUEST>Export</TALLYREQUEST>
        <TYPE>COLLECTION</TYPE>
        <ID>compcoll</ID>
    </HEADER>
    <BODY>
        <DESC>
            <STATICVARIABLES>
                <SVEXPORTFORMAT>\$\$SysName:XML</SVEXPORTFORMAT>
                <LICNUMM>\$\$LicenseInfo:SerialNumber</LICNUMM>
            </STATICVARIABLES>
            <TDL>
                <TDLMESSAGE>
                    <COLLECTION NAME="compcoll" ISINITIALIZE="Yes">
                        <TYPE>Company</TYPE>
                        <BELONGSTO>Yes</BELONGSTO>
                        <FETCH>Name</FETCH>
                        <PARMVAR>LICNUMM:\$\$LicenseInfo:SerialNumber</PARMVAR>
                        <COMPUTE>serialnumber:\$\$LicenseInfo:SerialNumber</COMPUTE>
                        <COMPUTE>CurrentCompany:##SVCURRENTCOMPANY</COMPUTE>
                    </COLLECTION>
                </TDLMESSAGE>
            </TDL>
        </DESC>
    </BODY>
  </ENVELOPE>''';

  static String bankAccounts(String companyName) {
    return '''<ENVELOPE>
			<HEADER>
				<VERSION>1</VERSION>
				<TALLYREQUEST>EXPORT</TALLYREQUEST>
				<TYPE>COLLECTION</TYPE>
				<ID>CUSTOMLEDGERCOLL</ID>
			</HEADER>
			<BODY>
			<DESC>
				<STATICVARIABLES>
				<SVEXPORTFORMAT>\$\$SysName:XML</SVEXPORTFORMAT>
				<SVCURRENTCOMPANY>$companyName</SVCURRENTCOMPANY>
				</STATICVARIABLES>
				<TDL>
				<TDLMESSAGE>
					<COLLECTION NAME="CUSTOMLEDGERCOLL">
					<TYPE>LEDGER</TYPE>
					<FETCH>BANKDETAILS</FETCH>
					<FILTERS>Group</FILTERS>
					</COLLECTION>
					<SYSTEM TYPE="Formulae" NAME="Group">\$Parent EQUALS 'BANK ACCOUNTS' OR \$parent EQUALS 'BANK OD A/c'</SYSTEM>
				</TDLMESSAGE>
				</TDL>
			</DESC>
			</BODY>
		</ENVELOPE>''';
  }

  static String fetchTransactions(
    String companyName,
    String bankName,
    String? date,
  ) {
    String filters = '''
			<FILTER>NOBANKERSDATE</FILTER>
			<FILTER>BANKFILTER</FILTER>
			<FILTER>TRANSACTIONTYPEFILTER</FILTER>
    ''';
    String formulae = '''
			<SYSTEM TYPE="Formulae" NAME="NOBANKERSDATE">\$\$IsEmpty:\$RECOSTARTDATE</SYSTEM>
			<SYSTEM TYPE="Formulae" NAME="BANKFILTER">\$BankParent Equals '$bankName'</SYSTEM>
			<SYSTEM TYPE="Formulae" NAME="TRANSACTIONTYPEFILTER">\$TransactionType Equals 'Same Bank Transfer' OR \$TransactionType Equals 'Inter Bank Transfer'</SYSTEM>
    ''';
    if (date != null) {
      filters = '''$filters<FILTER>DATEFILTER</FILTER>''';
      formulae =
          '''$formulae<SYSTEM TYPE="Formulae" NAME="DATEFILTER">\$STARTDATE Equals \$\$Date:'$date'</SYSTEM>''';
    }
    return '''
  			<ENVELOPE>
				<HEADER>
					<VERSION>1</VERSION>
					<TALLYREQUEST>EXPORT</TALLYREQUEST>
					<TYPE>COLLECTION</TYPE>
					<ID>UNRECONCILED</ID>
				</HEADER>
				<BODY>
					<DESC>
						<STATICVARIABLES>
							<SVEXPORTFORMAT>\$\$SysName:XML</SVEXPORTFORMAT>
							<SVCURRENTCOMPANY>$companyName</SVCURRENTCOMPANY>
						</STATICVARIABLES>
						<TDL>
							<TDLMESSAGE>
								<COLLECTION NAME="UNRECONCILED">
									<TYPE>PAYLINK</TYPE>
									<FETCH>NAME</FETCH>
									<FETCH>BANKAMOUNT</FETCH>
									<FETCH>BANKPARENT</FETCH>
									<FETCH>BANKPARTYNAME</FETCH>
									<FETCH>BENEFICIARYCODE</FETCH>
									<FETCH>EMAIL</FETCH>
									<FETCH>IFSCODE</FETCH>
									<FETCH>BANKNAME</FETCH>
									<FETCH>ACCOUNTNUMBER</FETCH>
									<FETCH>TRANSFERMODE</FETCH>
									<FETCH>LEDGERENTRIES.DATE</FETCH>
									<FETCH>LEDGERENTRIES.MASTERID</FETCH>
									<FETCH>LEDGERENTRIES.NARRATION</FETCH>
									<FETCH>LEDGERENTRIES.VOUCHERNUMBER</FETCH>
									<FETCH>PAYALLOCATIONDATA.UNIQUEREFERENCENUMBER</FETCH>
                  $filters
								</COLLECTION>
                $formulae
							</TDLMESSAGE>
						</TDL>
					</DESC>
				</BODY>
			</ENVELOPE>''';
  }
}
