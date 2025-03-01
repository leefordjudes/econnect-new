import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:server/server.dart';
import 'package:server/model.dart';

class SettingsDialog extends StatefulWidget {
  const SettingsDialog({super.key});

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _recordsPerPage = TextEditingController();
  final TextEditingController _oauthUrl = TextEditingController();
  final TextEditingController _statusUrl = TextEditingController();
  final TextEditingController _paymentUrl = TextEditingController();
  final TextEditingController _publicKey = TextEditingController();
  final TextEditingController _privateKey = TextEditingController();

  void submit() async {
    int perPage = _recordsPerPage.text.isEmpty
        ? 25
        : int.tryParse(_recordsPerPage.text) ?? 25;
    final settings = Settings(
      recordsPerPage: perPage,
      oauthUrl: _oauthUrl.text,
      statusUrl: _statusUrl.text,
      paymentUrl: _paymentUrl.text,
      publicKey: _publicKey.text,
      privateKey: _privateKey.text,
    );
    await context.read<Server>().setSettings(settings);
    if (!mounted) return;
    Navigator.of(context).pop(settings);
  }

  void loadSettings() async {
    final exSettings = await context.read<Server>().getSettings();
    if (exSettings != null) {
      _recordsPerPage.text = exSettings.recordsPerPage?.toString() ?? '25';
      _oauthUrl.text = exSettings.oauthUrl ?? '';
      _statusUrl.text = exSettings.statusUrl ?? '';
      _paymentUrl.text = exSettings.paymentUrl ?? '';
      _publicKey.text = exSettings.publicKey ?? '';
      _privateKey.text = exSettings.privateKey ?? '';
    }
  }

  @override
  void initState() {
    loadSettings();
    super.initState();
  }

  @override
  void dispose() {
    _recordsPerPage.dispose();
    _oauthUrl.dispose();
    _statusUrl.dispose();
    _paymentUrl.dispose();
    _publicKey.dispose();
    _privateKey.dispose();
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
            'Settings',
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
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                buildLabel('No. of records per page :'),
                const SizedBox(height: 4),
                buildRecordsPerPageRow(_recordsPerPage),
                const SizedBox(height: 8),
                buildLabel('OAuth Url :'),
                const SizedBox(height: 4),
                buildUrlRow(_oauthUrl),
                const SizedBox(height: 8),
                buildLabel('Get Transaction Status Url :'),
                const SizedBox(height: 4),
                buildUrlRow(_statusUrl),
                const SizedBox(height: 8),
                buildLabel('ERP Payment Api Url :'),
                const SizedBox(height: 4),
                buildUrlRow(_paymentUrl),
                const SizedBox(height: 8),
                buildLabel('Public Key :'),
                const SizedBox(height: 4),
                buildKeyRow(_publicKey),
                const SizedBox(height: 8),
                buildLabel('Private Key :'),
                const SizedBox(height: 4),
                buildKeyRow(_privateKey),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo[900],
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6)),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 305,
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
      ),
    );
  }

  Widget buildLabel(String lblTxt) {
    return Text(
      lblTxt,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.black54,
      ),
    );
  }

  Widget buildRecordsPerPageRow(
    TextEditingController controller,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 710,
          height: 35,
          child: Theme(
            data: Theme.of(context).copyWith(
              textSelectionTheme: TextSelectionThemeData(
                selectionColor: Colors.blue[200],
              ),
            ),
            child: TextFormField(
              controller: controller,
              maxLines: 1,
              cursorColor: Colors.blue[400],
              cursorErrorColor: Colors.red[400],
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'^\d{0,3}')),
                FilteringTextInputFormatter.digitsOnly
              ],
              style: TextStyle(
                color: Colors.grey[700],
                letterSpacing: 1.2,
              ),
              decoration: InputDecoration(
                filled: true,
                hoverColor: Colors.blue[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.transparent),
                  borderRadius: BorderRadius.circular(6.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(width: 2, color: Colors.blue[400]!),
                  borderRadius: BorderRadius.circular(6.0),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 10,
                ),
                fillColor: Colors.blue[100],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildUrlRow(
    TextEditingController controller,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 710,
          height: 35,
          child: Theme(
            data: Theme.of(context).copyWith(
              textSelectionTheme: TextSelectionThemeData(
                selectionColor: Colors.blue[200],
              ),
            ),
            child: buildUrlField(controller),
          ),
        ),
      ],
    );
  }

  TextFormField buildUrlField(
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
      decoration: InputDecoration(
        filled: true,
        hoverColor: Colors.blue[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.transparent),
          borderRadius: BorderRadius.circular(6.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(width: 2, color: Colors.blue[400]!),
          borderRadius: BorderRadius.circular(6.0),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 10,
        ),
        fillColor: Colors.blue[100],
      ),
    );
  }

  Widget buildKeyRow(
    TextEditingController controller,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 710,
          height: 85,
          child: Theme(
            data: Theme.of(context).copyWith(
              textSelectionTheme: TextSelectionThemeData(
                selectionColor: Colors.blue[200],
              ),
            ),
            child: buildKeyField(controller),
          ),
        ),
      ],
    );
  }

  TextFormField buildKeyField(
    TextEditingController controller,
  ) {
    return TextFormField(
      controller: controller,
      maxLines: 3,
      cursorColor: Colors.blue[400],
      cursorErrorColor: Colors.red[400],
      style: TextStyle(
        color: Colors.grey[700],
        letterSpacing: 1.2,
      ),
      decoration: InputDecoration(
        filled: true,
        hoverColor: Colors.blue[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.transparent),
          borderRadius: BorderRadius.circular(6.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(width: 2, color: Colors.blue[400]!),
          borderRadius: BorderRadius.circular(6.0),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 10,
        ),
        fillColor: Colors.blue[100],
      ),
    );
  }
}
