import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farm_expense_mangement_app/screens/cattle/newcattle.dart';
import 'package:farm_expense_mangement_app/screens/wrappers/wrapperhome.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../models/cattle.dart';
import '../../../services/database/cattledatabase.dart';
import 'package:farm_expense_mangement_app/models/history.dart';
import 'package:farm_expense_mangement_app/services/database/cattlehistorydatabase.dart';
import '../../../main.dart';
import '../notification/alertnotifications.dart';
import 'package:farm_expense_mangement_app/shared/constants.dart';

import 'grouplist.dart';

class AnimalDetails extends StatefulWidget {
  final String rfid;
  const AnimalDetails({super.key, required this.rfid});

  @override
  State<AnimalDetails> createState() => _AnimalDetailsState();
}

class _AnimalDetailsState extends State<AnimalDetails> {
  late Map<String, String> currentLocalization = {};
  late String languageCode = 'en';

  final user = FirebaseAuth.instance.currentUser;
  final uid = FirebaseAuth.instance.currentUser!.uid;
  late Stream<DocumentSnapshot<Map<String, dynamic>>> _streamController;

  // late DocumentSnapshot<Map<String,dynamic>> snapshot;
  late DatabaseServicesForCattle cattleDb;
  late DatabaseServiceForCattleHistory cattleHistory;
  late Cattle _cattle;
  // final CattleHistoryService _historyService = CattleHistoryService();
  late List<CattleHistory> events = [];
  // List<Map<String, dynamic>> events = [];

  @override
  void initState() {
    super.initState();
    cattleDb = DatabaseServicesForCattle(uid);
    cattleHistory = DatabaseServiceForCattleHistory(uid: uid);
    setState(() {
      _fetchCattleHistory();
    });

    loadEvents();

    _streamController = _fetchCattleDetail();
  }

  void loadEvents() async {
    // events1 = await _historyService.fetchEvents(uid, cattle.id);
    setState(() {});
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> _fetchCattleDetail() {
    return cattleDb.infoFromServer(widget.rfid).asStream();
  }

  Future<void> _fetchCattleHistory() async {
    final snapshot = await cattleHistory.historyFromServer(widget.rfid);
    // for (var doc in snapshot.docs) {
    //   print('Document ID: ${doc.id}');
    //   print('Document Data: ${doc.data()}');
    // }
    setState(() {
      events =
          snapshot.docs
              .map((doc) => CattleHistory.fromFireStore(doc, null))
              .toList();
    });
    events.sort((a, b) => b.date.compareTo(a.date));
  }

  void editCattleDetail() {
    // Navigator.pop(context);
    // Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditAnimalDetail(cattle: _cattle),
      ),
    );
  }

  void deleteCattle() {
    cattleDb.deleteCattle(widget.rfid).then((value) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(currentLocalization['Deleted'] ?? ''),
            duration: Duration(seconds: 2),
          ),
        );
      }
    });
    Navigator.pop(context);
    Navigator.pop(context);
    Navigator.pop(context);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => WrapperHomePage()),
    );
  }

  bool isDetailVisible = false;
  @override
  Widget build(BuildContext context) {
    languageCode = Provider.of<AppData>(context).persistentVariable;

    currentLocalization = langFileMap[languageCode]!;
    Widget buildWidget(CattleHistory event) {
      // String eventName = (event['name'] as String).toLowerCase();
      if (event.name == currentLocalization['abortion']) {
        return Image.asset('asset/Cross_img.png', width: 30, height: 35);
      } else if (event.name == currentLocalization['vaccination']) {
        return Image.asset('asset/Vaccination.png', width: 30, height: 35);
      } else if (event.name == currentLocalization['Heifer']) {
        return Image.asset('asset/heifer.png', width: 30, height: 35);
      } else {
        return Image.asset('asset/Vaccination.png', width: 30, height: 35);
      }
    }

    return Scaffold(
      backgroundColor: const Color.fromRGBO(240, 255, 255, 1.0),
      appBar: AppBar(
        title: Text(widget.rfid, style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromRGBO(13, 166, 186, 1.0),
        leading: IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => GroupList()),
            );
          },
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: () {
              deleteCattle();
            },
            icon: const Icon(Icons.delete, color: Colors.white),
          ),
          IconButton(
            onPressed: () {
              editCattleDetail();
            },
            icon: const Icon(Icons.edit, color: Colors.white),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: _streamController,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Text(currentLocalization['please_wait'] ?? ""),
            );
          } else if (snapshot.hasData) {
            _cattle = Cattle.fromFireStore(snapshot.requireData, null);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                (_cattle.sex == 'Female')
                    ? Expanded(
                      // flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(15, 5, 5, 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              currentLocalization['events'] ?? "",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AddEventPopup(
                                      uid: uid,
                                      cattle: _cattle,
                                    );
                                  },
                                );
                              },
                              style: ButtonStyle(
                                backgroundColor: WidgetStateProperty.all<Color>(
                                  const Color.fromRGBO(240, 255, 255, 1.0),
                                ),
                                side: WidgetStateProperty.all<BorderSide>(
                                  const BorderSide(
                                    color: Colors.black,
                                  ), // Set the border color here
                                ),
                              ),
                              child: Text(
                                currentLocalization['add_event'] ?? "",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    : Expanded(
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                        alignment: Alignment.center,
                        child:
                            (_cattle.sex == null)
                                ? Text(
                                  currentLocalization['Update_gender_dob'] ??
                                      '',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.deepPurple,
                                  ),
                                )
                                : Text(''),
                      ),
                    ),
                Expanded(
                  flex: 6,
                  child: ListView(
                    children:
                        events
                            .map(
                              (event) => Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  10,
                                  7,
                                  10,
                                  7,
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.grey,
                                      // Set the border color here
                                      width: 1.5, // Set the border width here
                                    ),
                                    color: const Color.fromRGBO(
                                      240,
                                      255,
                                      255,
                                      1,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(7,9,7,9),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Expanded(
                                          flex: 4,
                                          child: Container(
                                            padding: const EdgeInsets.fromLTRB(
                                              20,
                                              10,
                                              10,
                                              10,
                                            ),
                                            width: 130,
                                            height: 60,
                                            alignment: Alignment.centerLeft,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(
                                                12,
                                              ),
                                            ),
                                            child: buildWidget(event),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 12,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                " ${capitalizeFirstLetterOfEachWord(currentLocalization[event.name.toLowerCase()] ?? "")}",
                                                textAlign: TextAlign.left,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              if (event.notes != '' && event.notes != null) ...[
                                                Padding(
                                                  padding: const EdgeInsets.fromLTRB(3,0,0,0),
                                                  child: Text(
                                                    "${(event.name == 'Insemination') ? currentLocalization['sire_info'] : ''} ${event.notes ?? ''}",
                                                    textAlign: TextAlign.left,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          flex: 6,
                                          child: SizedBox(
                                            child: Text(
                                              "${event.date.year}-${(event.date.month > 9) ? event.date.month : '0${event.date.month}'}-${(event.date.day > 9) ? event.date.day : '0${event.date.day}'}",
                                              // Display the raw date string
                                              softWrap: false,
                                              textAlign: TextAlign.left,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                  ),

                  // ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 0, 8, 0),
                  child: Center(
                    child: Column(
                      children: [
                        IconButton(
                          icon: Icon(
                            isDetailVisible
                                ? Icons.keyboard_arrow_down
                                : Icons.keyboard_arrow_up,
                            color: const Color.fromRGBO(13, 166, 186, 1),
                            size: 40,
                          ),
                          onPressed: () {
                            setState(() {
                              isDetailVisible =
                                  !isDetailVisible; // Toggle visibility
                            });
                          },
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(12.0, 0, 12, 2),
                          child: Text(
                            currentLocalization["details"] ?? "",
                            style: TextStyle(
                              fontSize: 24,
                              color: Color.fromRGBO(13, 166, 186, 1.0),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                AnimatedContainer(
                  margin: const EdgeInsets.fromLTRB(0, 2, 0, 0),
                  // color: Colors.grey[200],
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  height: isDetailVisible ? 350 : 0,
                  // Set height based on visibility
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(30.0, 0, 30, 0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 20),
                          Container(
                            color: const Color.fromRGBO(13, 166, 186, 1.0),
                            height: 60,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                SizedBox(
                                  width: 100,
                                  child: Text(
                                    currentLocalization["cattle_name"] ??
                                        "Name /Tag No.",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 110,
                                  child: Text(
                                    (_cattle.nickname == null)
                                        ? ''
                                        : _cattle.nickname.toString().split(
                                          " ",
                                        )[0],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            color: const Color.fromRGBO(13, 166, 186, 1.0),
                            height: 50,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                SizedBox(
                                  width: 100,
                                  child: Text(
                                    currentLocalization["dob"] ?? "",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 110,
                                  child: Text(
                                    (_cattle.dateOfBirth == null)
                                        ? ''
                                        : _cattle.dateOfBirth.toString().split(
                                          " ",
                                        )[0],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            color: const Color.fromRGBO(13, 166, 186, 1.0),
                            height: 50,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                SizedBox(
                                  width: 100,
                                  child: Text(
                                    currentLocalization["sex"] ?? "",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 100,
                                  child: Text(
                                    currentLocalization[_cattle.sex
                                            ?.toLowerCase()] ??
                                        "",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            color: const Color.fromRGBO(13, 166, 186, 1.0),
                            height: 50,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                SizedBox(
                                  width: 100,
                                  child: Text(
                                    currentLocalization["weight"] ?? "",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 100,
                                  child: Text(
                                    "${_cattle.weight}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            height: 60,
                            color: const Color.fromRGBO(13, 166, 186, 1.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                SizedBox(
                                  width: 100,
                                  child: Text(
                                    currentLocalization["breed"] ?? "",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 100,
                                  child: Text(
                                    currentLocalization[_cattle.breed
                                            ?.toLowerCase()] ??
                                        '',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            height: 50,
                            color: const Color.fromRGBO(13, 166, 186, 1.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                SizedBox(
                                  width: 100,
                                  child: Text(
                                    currentLocalization["state"] ?? "",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 100,
                                  child: Text(
                                    currentLocalization[_cattle.state] ?? "",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            height: 60,
                            color: const Color.fromRGBO(13, 166, 186, 1.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                SizedBox(
                                  width: 100,
                                  child: Text(
                                    currentLocalization["source_of_cattle"] ??
                                        "",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 100,
                                  child: Text(
                                    currentLocalization[_cattle.source
                                            ?.toLowerCase()] ??
                                        '',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            height: 60,
                            color: const Color.fromRGBO(13, 166, 186, 1.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                SizedBox(
                                  width: 100,
                                  child: Text(
                                    currentLocalization["mother_info"] ?? "",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 100,
                                  child: Text(
                                    _cattle.motherInfo ?? '',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            height: 60,
                            color: const Color.fromRGBO(13, 166, 186, 1.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                SizedBox(
                                  width: 100,
                                  child: Text(
                                    currentLocalization["father_info"] ?? "",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 100,
                                  child: Text(
                                    _cattle.fatherInfo ?? '',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          (_cattle.sex == currentLocalization['female'])
                              ? Container(
                                height: 60,
                                color: const Color.fromRGBO(13, 166, 186, 1.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    SizedBox(
                                      width: 100,
                                      child: Text(
                                        currentLocalization["pregnant"] ?? "",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                          fontSize: 20,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 100,
                                      child: Text(
                                        (_cattle.isPregnant)
                                            ? currentLocalization['yes']!
                                            : currentLocalization['no']!,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                          fontSize: 20,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                              : Container(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          } else {
            return Center(
              child: Text(currentLocalization['Error in Fetch'] ?? ''),
            );
          }
        },
      ),
    );
  }
}

class EditAnimalDetail extends StatefulWidget {
  final Cattle cattle;

  const EditAnimalDetail({super.key, required this.cattle});

  @override
  State<EditAnimalDetail> createState() => _EditAnimalDetailState();
}

class _EditAnimalDetailState extends State<EditAnimalDetail> {
  late Map<String, String> currentLocalization = {};
  late String languageCode = 'en';
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameTextController = TextEditingController();
  final TextEditingController _weightTextController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _motherInfoTextController =
      TextEditingController();
  final TextEditingController _fatherInfoTextController =
      TextEditingController();

  String? _selectedGender; // Variable to store selected gender
  String? _selectedSource;
  String? _selectedBreed;
  DateTime? _birthDate;

  // Variable to store selected gender

  final List<String> genderOptions = ['Male', 'Female'];
  final List<String> sourceOptions = [
    'Born on Farm',
    'Purchased',
  ]; // List of gender options

  final user = FirebaseAuth.instance.currentUser;
  final uid = FirebaseAuth.instance.currentUser!.uid;

  late final DatabaseServicesForCattle cattleDb;

  @override
  void initState() {
    super.initState();

    cattleDb = DatabaseServicesForCattle(uid);
    _nameTextController.text = widget.cattle.nickname ?? '';
    _selectedBreed = widget.cattle.breed;
    _weightTextController.text = widget.cattle.weight.toString();
    _selectedSource = widget.cattle.source;
    _selectedGender = widget.cattle.sex;
    _birthDateController.text =
        '${widget.cattle.dateOfBirth?.year}-${widget.cattle.dateOfBirth?.month}-${widget.cattle.dateOfBirth?.day}';
    _motherInfoTextController.text = widget.cattle.motherInfo ?? '';
    _fatherInfoTextController.text = widget.cattle.fatherInfo ?? '';
  }

  void updateCattleButton(BuildContext context) {
    final cattle = Cattle(
      rfid: widget.cattle.rfid,
      nickname: _nameTextController.text,
      breed: _selectedBreed.toString(),
      sex: _selectedGender.toString(),
      weight: int.parse(_weightTextController.text),
      state: widget.cattle.state,
      source: _selectedSource.toString(),
      type: widget.cattle.type,
      isPregnant: widget.cattle.isPregnant,
      dateOfBirth: _birthDate != null ? _birthDate! : widget.cattle.dateOfBirth,
      motherInfo: _motherInfoTextController.text,
      fatherInfo: _fatherInfoTextController.text,
    );

    cattleDb.infoToServerSingleCattle(cattle);
    if (cattle.state == "Calf" &&
        cattle.sex == "Female" &&
        cattle.dateOfBirth != null &&
        widget.cattle.dateOfBirth == null) {
      AlertNotifications alert = AlertNotifications();
      alert.createCalfNotifications(cattle);
    }

    Navigator.pop(context);
    Navigator.pop(context);
    Navigator.pop(context);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => WrapperHomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    languageCode = Provider.of<AppData>(context).persistentVariable;

    currentLocalization = langFileMap[languageCode]!;

    var breedList = (widget.cattle.type == 'Cow') ? cowBreed : buffaloBreed;

    return Scaffold(
      backgroundColor: const Color.fromRGBO(240, 255, 255, 1.0),
      appBar: AppBar(
        title: Text(
          currentLocalization['edit_details'] ?? '',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(13, 166, 186, 1.0),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => AnimalDetails(rfid: widget.cattle.rfid),
              ),
            );
          },
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.fromLTRB(5, 0, 5, 26),
                  child: TextFormField(
                    controller: _nameTextController,
                    decoration: InputDecoration(
                      labelText:
                          currentLocalization['enter_the_cattle_name'] ?? '',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Color.fromRGBO(240, 255, 255, 0.7),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return currentLocalization['please_enter_tag_num'];
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(5, 8, 5, 26),
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedGender,
                    decoration: InputDecoration(
                      labelText: "${currentLocalization['gender'] ?? ''}*",
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Color.fromRGBO(240, 255, 255, 0.7),
                    ),
                    items:
                        genderOptions.map((String gender) {
                          return DropdownMenuItem<String>(
                            value: gender,
                            child: Text(
                              currentLocalization[gender.toLowerCase()] ?? '',
                            ),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedGender = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return currentLocalization['please_select_gender'];
                      }
                      return null;
                    },
                  ),
                ),
                // SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.fromLTRB(5, 0, 5, 26),
                  child: InkWell(
                    onTap: () async {
                      final DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          _birthDate = pickedDate;
                          _birthDateController.text =
                              '${_birthDate!.year}-${_birthDate!.month}-${_birthDate!.day}';
                        });
                      }
                    },
                    child: IgnorePointer(
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        // initialValue: '0',
                        controller: _birthDateController,
                        decoration: InputDecoration(
                          labelText: currentLocalization['enter_the_DOB'],
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                          filled: true,
                          fillColor: Color.fromRGBO(240, 255, 255, 0.7),
                        ),
                      ),
                    ),
                  ),
                ),
                // SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.fromLTRB(5, 0, 5, 26),
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    controller: _weightTextController,
                    decoration: InputDecoration(
                      labelText: currentLocalization['enter_the_weight'] ?? '',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Color.fromRGBO(240, 255, 255, 0.7),
                    ),
                  ),
                ),
                // SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.fromLTRB(5, 0, 5, 26),
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedSource,
                    decoration: InputDecoration(
                      labelText:
                          currentLocalization['source_of_cattle'] ??
                          ""
                              '*',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Color.fromRGBO(240, 255, 255, 0.7),
                    ),
                    items:
                        sourceOptions.map((String source) {
                          return DropdownMenuItem<String>(
                            value: source,
                            child: Text(
                              currentLocalization[source.toLowerCase()] ?? '',
                            ),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedSource = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return currentLocalization['please_select_source'];
                      }
                      return null;
                    },
                  ),
                ),
                // SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.fromLTRB(5, 0, 5, 26),
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedBreed,
                    decoration: InputDecoration(
                      labelText:
                          currentLocalization['select_the_breed'] ??
                          ""
                              '*',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Color.fromRGBO(240, 255, 255, 0.7),
                    ),
                    items:
                        breedList.map((String breed) {
                          return DropdownMenuItem<String>(
                            value: breed,
                            child: Text(currentLocalization[breed] ?? 'breed'),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedBreed = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value == 'select') {
                        return currentLocalization['please_select_breed'];
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(5, 0, 5, 26),
                  child: TextFormField(
                    controller: _motherInfoTextController,
                    decoration: InputDecoration(
                      labelText: currentLocalization['enter_mother_info'] ?? "",
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Color.fromRGBO(240, 255, 255, 0.7),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 26),
                  child: TextFormField(
                    controller: _fatherInfoTextController,
                    decoration: InputDecoration(
                      labelText: currentLocalization['enter_father_info'] ?? "",
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Color.fromRGBO(240, 255, 255, 0.7),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 26),
                  child: Center(
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          // Process the data
                          // For example, save it to a database or send it to an API
                          updateCattleButton(context);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                currentLocalization['cattle_details_updated_successfully'] ??
                                    '',
                              ),
                            ),
                          );
                        }
                      },
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(
                          const Color.fromRGBO(13, 166, 186, 1.0),
                        ),
                      ),
                      child: Text(
                        currentLocalization['submit'] ?? '',
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
    );
  }

  @override
  void dispose() {
    // _rfidTextController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }
}

String capitalizeFirstLetterOfEachWord(String input) {
  if (input.isEmpty) return "";

  var words = input.toLowerCase().split(' ');
  for (int i = 0; i < words.length; i++) {
    words[i] = words[i][0].toUpperCase() + words[i].substring(1);
  }
  return words.join(' ');
}

class AddEventPopup extends StatefulWidget {
  final String uid;
  final Cattle cattle;

  const AddEventPopup({super.key, required this.uid, required this.cattle});

  @override
  State<AddEventPopup> createState() => _AddEventPopupState();
}

class _AddEventPopupState extends State<AddEventPopup> {
  String? selectedOption;
  List<String> eventOptions = [];
  DateTime? selectedDate;
  late AlertNotifications alerts;
  late Map<String, String> currentLocalization = {};
  late String languageCode = 'en';
  TextEditingController notesTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    alerts = AlertNotifications();
    setEventOptions(); // Set event options based on cattle state
  }

  @override
  void dispose() {
    super.dispose();
    notesTextController.dispose();
  }

  void setEventOptions() {
    switch (widget.cattle.state) {
      case 'Dry':
        eventOptions = [
          'Abortion',
          'Insemination',
          'Pregnant',
          'Calved',
          'Vaccination',
        ];
        break;
      case 'Milked':
        eventOptions = [
          'Insemination',
          'Pregnant',
          'Abortion',
          'Dry',
          'Vaccination',
        ];
        break;
      case 'Heifer':
        eventOptions = [
          'Insemination',
          'Pregnant',
          'Abortion',
          'Calved',
          'Vaccination',
        ];
        break;
      case 'Calf':
        eventOptions = ['Insemination', 'Vaccination'];
        break;
      default:
        eventOptions = [];
    }
  }

  @override
  Widget build(BuildContext context) {
    languageCode = Provider.of<AppData>(context).persistentVariable;

    currentLocalization = langFileMap[languageCode]!;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  Widget contentBox(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            currentLocalization['add_event'] ?? '',
            style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 15.0),
          SizedBox(
            width: double.infinity,
            child: DropdownButtonFormField<String>(
              initialValue: selectedOption,
              onChanged: (String? newValue) {
                setState(() {
                  selectedOption = newValue;
                });
              },
              decoration: InputDecoration(
                hintText: currentLocalization['event_name'] ?? '',
                border: OutlineInputBorder(),
              ),
              items:
                  eventOptions.map((String option) {
                    return DropdownMenuItem<String>(
                      value: option,
                      child: Text(
                        currentLocalization[option.toLowerCase()] ?? '',
                      ),
                    );
                  }).toList(),
            ),
          ),
          const SizedBox(height: 10.0),
          TextFormField(
            readOnly: true,
            controller: TextEditingController(
              text:
                  selectedDate != null
                      ? selectedDate.toString().split(' ')[0]
                      : '',
            ),
            onTap: () async {
              final DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (pickedDate != null) {
                setState(() {
                  selectedDate = pickedDate;
                });
              }
            },
            decoration: InputDecoration(
              hintText: currentLocalization['event_date'] ?? '',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10.0),
          TextFormField(
            controller: notesTextController,
            textCapitalization: TextCapitalization.words,
            maxLength: 25,
            decoration: InputDecoration(
              hintText:
                  (selectedOption == 'Insemination')
                      ? currentLocalization['enter_sire_info']
                      : currentLocalization['enter_notes'],
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20.0),
          ElevatedButton(
            onPressed: () {
              if (selectedOption != null && selectedDate != null) {
                final newHistory = CattleHistory(
                  name: selectedOption!,
                  date: selectedDate!,
                  notes: notesTextController.text,
                );

                DatabaseServiceForCattleHistory(
                  uid: widget.uid,
                ).historyToServerSingleCattle(widget.cattle, newHistory);

                alerts.createNotifications(widget.cattle, newHistory);

                Navigator.of(context).pop();

                if (selectedOption == 'Calved') {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text(
                          currentLocalization['calf_entry'] ?? '',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color.fromRGBO(13, 166, 186, 0.9),
                          ),
                        ),
                        content: Text(
                          currentLocalization['would_enter_calf_details'] ?? '',
                        ),
                        actions: [
                          TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFF0DA6BA),
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onPressed: () async {
                              String sireInfo =
                                  await DatabaseServiceForCattleHistory(
                                    uid: widget.uid,
                                  ).getLastAISireDetails(widget.cattle.rfid);
                              if (context.mounted) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => AddNewCattle(
                                          state: 'Calf',
                                          breed: widget.cattle.breed,
                                          type: widget.cattle.type,
                                          dob: selectedDate,
                                          source: 'Born on Farm',
                                          motherInfo:
                                              widget.cattle.nickname ??
                                              widget.cattle.rfid,
                                          fatherInfo: sireInfo,
                                        ),
                                  ),
                                );
                              }
                            },
                            child: Text(currentLocalization['now'] ?? 'Now'),
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFF0DA6BA),
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => AnimalDetails(
                                        rfid: widget.cattle.rfid,
                                      ),
                                ),
                              );
                            },
                            child: Text(
                              currentLocalization['later'] ?? 'Later',
                            ),
                          ),
                        ],
                      );
                    },
                  );
                } else {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => AnimalDetails(rfid: widget.cattle.rfid),
                    ),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      currentLocalization['please_select_event_and_date'] ?? '',
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(
                const Color.fromRGBO(13, 166, 186, 0.6),
              ),
            ),
            child: Text(
              currentLocalization['submit'] ?? '',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
