import 'package:flutter/material.dart';

import 'package:server/tally.dart';
import 'package:server/model.dart';

class ConfigurationDialog extends StatefulWidget {
  const ConfigurationDialog(this.companyInfo, this.exConfiguration,
      {super.key});
  final CompanyInfo companyInfo;
  final Configuration? exConfiguration;

  @override
  State<ConfigurationDialog> createState() => _ConfigurationDialogState();
}

class _ConfigurationDialogState extends State<ConfigurationDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _corporateId = TextEditingController();
  final TextEditingController _makerId = TextEditingController();
  final TextEditingController _userId = TextEditingController();
  final TextEditingController _password = TextEditingController();

  final List<BankAccount> bankAccounts = [];
  String selectedBankAc = '';
  void submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      if (selectedBankAc.isNotEmpty) {
        final bankAc =
            bankAccounts.firstWhere((ac) => ac.accountNumber == selectedBankAc);
        final configuration = Configuration(
          accountNumber: bankAc.accountNumber,
          accountName: bankAc.accountName,
          corporateId: _corporateId.text,
          makerId: _makerId.text,
          userId: _userId.text,
          password: _password.text,
        );
        Navigator.of(context).pop(configuration);
      }
    }
  }

  void loadBankAccounts(CompanyInfo compInfo) async {
    final tallyBankAccounts = await Tally.getBankAccounts(compInfo.name);
    if (tallyBankAccounts.isNotEmpty) {
      setState(() {
        bankAccounts.addAll(tallyBankAccounts);
        if (widget.exConfiguration != null &&
            widget.exConfiguration!.accountNumber.isNotEmpty &&
            widget.exConfiguration!.accountName.isNotEmpty) {
          final xAcNo = widget.exConfiguration!.accountNumber;
          final xAcName = widget.exConfiguration!.accountName;
          final xIdx =
              tallyBankAccounts.indexWhere((e) => e.accountName == xAcName);
          if (xIdx != -1) {
            selectedBankAc = xAcNo;
          } else {
            selectedBankAc = tallyBankAccounts.first.accountNumber;
          }
        } else {
          selectedBankAc = tallyBankAccounts.first.accountNumber;
        }
      });
    }
  }

  void patchValue(Configuration? xConf) {
    if (xConf != null) {
      _corporateId.text = xConf.corporateId;
      _makerId.text = xConf.makerId;
      _userId.text = xConf.userId;
      _password.text = xConf.password;
    }
  }

  @override
  void initState() {
    loadBankAccounts(widget.companyInfo);
    patchValue(widget.exConfiguration);
    super.initState();
  }

  @override
  void dispose() {
    _corporateId.dispose();
    _makerId.dispose();
    _userId.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50.0),
        child: AppBar(
          backgroundColor: Colors.blue[400],
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              padding: const EdgeInsets.all(0),
              icon: Icon(
                Icons.close,
                color: Colors.blue[50],
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            const SizedBox(width: 5),
          ],
          elevation: 0,
          title: Text(
            'Configuration',
            style: TextStyle(
              fontSize: 22,
              color: Colors.blue[50],
            ),
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 12),
              buildConfigurationBankRow(
                title: 'Bank',
                dropdownButtonFormField:
                    buildBank(selectedBankAc, bankAccounts),
              ),
              const SizedBox(height: 4),
              buildConfigurationRow(
                title: 'Corporate Id',
                formField: buildCorporateId(
                  'Corporate Id',
                  _corporateId,
                ),
              ),
              const SizedBox(height: 4),
              buildConfigurationRow(
                title: 'Maker Id',
                formField: buildMakerId('Maker Id', _makerId),
              ),
              const SizedBox(height: 4),
              buildConfigurationRow(
                title: 'User Id',
                formField: buildUserId('User Id', _userId),
              ),
              const SizedBox(height: 4),
              buildConfigurationRow(
                title: 'Password',
                formField: buildPassword('Password', _password),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo[900],
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6)),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 230,
                    vertical: 15,
                  ),
                ),
                child: Text(
                  'Submit',
                  style: TextStyle(
                    fontSize: 20,
                    letterSpacing: 5,
                    color: Colors.blue[50],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildConfigurationBankRow({
    required String title,
    required DropdownButtonFormField dropdownButtonFormField,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 180,
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.left,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const Text(
                    ' *',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      // fontFeatures: [FontFeature.superscripts()],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            width: 30,
            child: Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text(
                ' : ',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
          SizedBox(
            width: 350,
            height: 35,
            child: Theme(
              data: Theme.of(context).copyWith(
                canvasColor: Colors.blue[50],
                focusColor: Colors.blue[100],
                hoverColor: Colors.blue[200],
              ),
              child: dropdownButtonFormField,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildConfigurationRow({
    required String title,
    required TextFormField formField,
    bool? obscureText,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 180,
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.left,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const Text(
                    ' *',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontFeatures: [FontFeature.superscripts()],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            width: 30,
            child: Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text(
                ' : ',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
          SizedBox(
            width: 350,
            height: 35,
            child: Theme(
              data: Theme.of(context).copyWith(
                textSelectionTheme: TextSelectionThemeData(
                  selectionColor: Colors.blue[200],
                ),
              ),
              child: formField,
            ),
          ),
        ],
      ),
    );
  }

  DropdownButtonFormField buildBank(
    String selBankAc,
    List<BankAccount> bankAcs,
  ) {
    return DropdownButtonFormField(
      value: selBankAc,
      menuMaxHeight: 200,
      dropdownColor: Colors.blue[50],
      items: bankAcs
          .map((bankAc) => DropdownMenuItem(
                value: bankAc.accountNumber,
                child: Text(
                  bankAc.accountName,
                  style: TextStyle(
                    color: Colors.grey[700],
                  ),
                ),
              ))
          .toList(),
      onChanged: (value) {
        setState(() {
          selectedBankAc = value!;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Select any bank account';
        }
        return null;
      },
      autofocus: true,
      style: TextStyle(
        color: Colors.grey[700],
        letterSpacing: 1.2,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
      decoration: dropDownFormFieldDecoration(),
    );
  }

  TextFormField buildCorporateId(
    String title,
    TextEditingController controller,
  ) {
    return TextFormField(
      controller: controller,
      maxLines: 1,
      cursorColor: Colors.blue[400],
      cursorErrorColor: Colors.red[400],
      style: TextStyle(
        color: Colors.grey[700],
        letterSpacing: 1.2,
      ),
      decoration: formFieldDecoration(title),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Enter Corporate Id';
        }
        return null;
      },
      onSaved: (value) {
        print('corporate id: $value');
      },
    );
  }

  TextFormField buildMakerId(
    String title,
    TextEditingController controller,
  ) {
    return TextFormField(
      controller: controller,
      maxLines: 1,
      cursorColor: Colors.blue[400],
      cursorErrorColor: Colors.red[400],
      style: TextStyle(
        color: Colors.grey[700],
        letterSpacing: 1.2,
      ),
      decoration: formFieldDecoration(title),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Enter Maker Id';
        }
        return null;
      },
      onSaved: (value) {
        print('maker: $value');
      },
    );
  }

  TextFormField buildUserId(
    String title,
    TextEditingController controller,
  ) {
    return TextFormField(
      controller: controller,
      maxLines: 1,
      cursorColor: Colors.blue[400],
      cursorErrorColor: Colors.red[400],
      style: TextStyle(
        color: Colors.grey[700],
        letterSpacing: 1.2,
      ),
      decoration: formFieldDecoration(title),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Enter User Id';
        }
        return null;
      },
      onSaved: (value) {
        print('user: $value');
      },
    );
  }

  TextFormField buildPassword(
    String title,
    TextEditingController controller,
  ) {
    return TextFormField(
      controller: controller,
      obscureText: true,
      obscuringCharacter: '*',
      maxLines: 1,
      cursorColor: Colors.blue[400],
      cursorErrorColor: Colors.red[400],
      style: TextStyle(
        color: Colors.grey[700],
        letterSpacing: 10,
      ),
      decoration: formFieldDecoration(title),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Enter Password';
        }
        return null;
      },
      onSaved: (value) {
        print('pwd: $value');
      },
    );
  }

  InputDecoration formFieldDecoration(String title) {
    return InputDecoration(
      filled: true,
      // isDense: true,
      hoverColor: Colors.blue[200],
      // errorText: '',
      errorStyle: const TextStyle(
        color: Colors.transparent,
        fontSize: 0,
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.transparent),
        borderRadius: BorderRadius.circular(6.0),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(width: 2, color: Colors.blue[400]!),
        borderRadius: BorderRadius.circular(6.0),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6.0),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6.0),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(
        vertical: 10,
        horizontal: 10,
      ),
      hintStyle: TextStyle(
        color: Colors.grey[700],
        letterSpacing: 1.5,
      ),
      hintText: title,
      fillColor: Colors.blue[100],
    );
  }

  InputDecoration dropDownFormFieldDecoration() {
    return InputDecoration(
      filled: true,
      hoverColor: Colors.blue[200],
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.transparent),
        borderRadius: BorderRadius.circular(6.0),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(width: 2, color: Colors.blue[400]!),
        borderRadius: BorderRadius.circular(6.0),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6.0),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6.0),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(
        vertical: 10,
        horizontal: 10,
      ),
      hintStyle: TextStyle(
        color: Colors.grey[700],
        letterSpacing: 1.5,
      ),
      fillColor: Colors.blue[100],
    );
  }
}
