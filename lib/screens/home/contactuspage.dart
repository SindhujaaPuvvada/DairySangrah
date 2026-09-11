import 'package:farm_expense_mangement_app/services/database/querydatabase.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../main.dart';
import '../../models/query.dart';
import '../../services/localizationService.dart';
import '../../services/supabaseService.dart';
import '../wrappers/wrapperhome.dart';

class ContactUsPage extends StatefulWidget {
  const ContactUsPage({super.key});

  @override
  State<ContactUsPage> createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage> {
  late Map<String, dynamic> currentLocalization = {};
  late String languageCode = 'en';

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameTextController = TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();
  final TextEditingController _phoneNoTextController = TextEditingController();
  final TextEditingController _queryTextController = TextEditingController();

  @override
  void dispose() {
    _nameTextController.dispose();
    _emailTextController.dispose();
    _phoneNoTextController.dispose();
    super.dispose();
  }

  Future<void> _submitQueryDetails() async {
    final Query query = Query(
      userId: SupabaseService.client.auth.currentUser!.id,
      name: _nameTextController.text,
      emailId: _emailTextController.text,
      phoneNo: _phoneNoTextController.text,
      theQuery: _queryTextController.text,
      createdAt: DateTime.now(),
    );
    await DbServicesForQueries().infoToServer(query);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            currentLocalization['query_submitted_msg'] ??
                "Query submitted successfully",
          ),
        ),
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const WrapperHomePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    languageCode = Provider.of<AppData>(context).persistentVariable;

    currentLocalization = Localization().translations[languageCode] ?? {};
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: BackButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const WrapperHomePage()),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          currentLocalization['ContactUs'] ?? 'Contact Us',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromRGBO(13, 166, 186, 1.0),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Scrollbar(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 26),
                    child: Text(
                      currentLocalization['contactus_msg'] ??
                          "Please submit your Query here...",
                      style: TextStyle(
                        color: Colors.indigo.shade900,
                        fontStyle: FontStyle.italic,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(5, 0, 5, 15),
                    child: TextFormField(
                      controller: _nameTextController,
                      decoration: InputDecoration(
                        labelText: currentLocalization['My Name'] ?? "My Name",
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Color.fromRGBO(240, 255, 255, 0.7),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(5, 0, 5, 15),
                    child: TextFormField(
                      controller: _emailTextController,
                      decoration: InputDecoration(
                        labelText:
                            currentLocalization['email_id'] ?? "Email ID",
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Color.fromRGBO(240, 255, 255, 0.7),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(5, 0, 5, 15),
                    child: TextFormField(
                      controller: _phoneNoTextController,
                      decoration: InputDecoration(
                        labelText:
                            currentLocalization['Phone No.'] ?? "Phone No.",
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Color.fromRGBO(240, 255, 255, 0.7),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(5, 0, 5, 15),
                    child: TextFormField(
                      controller: _queryTextController,
                      keyboardType: TextInputType.multiline,
                      maxLines: 10,
                      decoration: InputDecoration(
                        labelText:
                            currentLocalization['my_query'] ?? "My query",
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Color.fromRGBO(240, 255, 255, 0.7),
                      ),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return currentLocalization['please_enter_query'] ??
                              'Please enter your query';
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(5, 0, 5, 25),
                    child: Center(
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _submitQueryDetails();
                          }
                        },
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all(
                            const Color.fromRGBO(13, 166, 186, 1.0),
                          ),
                        ),
                        child: Text(
                          currentLocalization['submit'] ?? "",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
