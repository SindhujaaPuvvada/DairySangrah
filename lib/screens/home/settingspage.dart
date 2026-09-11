import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../main.dart';
import '../../services/localizationService.dart';
import '../wrappers/wrapperhome.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late Map<String, dynamic> currentLocalization = {};
  late String languageCode = 'en';

  @override
  Widget build(BuildContext context) {
    languageCode = Provider.of<AppData>(context).persistentVariable;

    currentLocalization = Localization().translations[languageCode] ?? {};
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const WrapperHomePage()),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          currentLocalization['Settings'] ?? 'Settings',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromRGBO(13, 166, 186, 1.0),
        centerTitle: true,
      ),
      body: Container(),
    );
  }
}
