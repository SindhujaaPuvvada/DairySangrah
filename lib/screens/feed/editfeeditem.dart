// import 'package:farm_expense_mangement_app/screens/feed/feedpage.dart';
// import 'package:flutter/material.dart';
// import 'package:farm_expense_mangement_app/models/feed.dart';
// import 'package:farm_expense_mangement_app/services/database/feeddatabase.dart';
// import 'package:provider/provider.dart';
// import '../../main.dart';
// import '../home/localisations_en.dart';
// import '../home/localisations_hindi.dart';
// import '../home/localisations_punjabi.dart';
//
// class EditFeedItemPage extends StatefulWidget {
//   final Feed feed;
//   final String uid;
//
//   const EditFeedItemPage({super.key, required this.feed, required this.uid});
//
//   @override
//   State<EditFeedItemPage> createState() => _EditFeedItemPageState();
// }
//
// class _EditFeedItemPageState extends State<EditFeedItemPage> {
//
//   late Map<String, String> currentLocalization= {};
//   late String languageCode = 'en';
//
//   final _formKey = GlobalKey<FormState>();
//   late TextEditingController _itemNameController;
//   late TextEditingController _categoryController;
//   late TextEditingController _needController;
//   late TextEditingController _stockController;
//   late DateTime _expiryDate;
//
//   late DatabaseServicesForFeed _dbService;
//
//   @override
//   void initState() {
//     super.initState();
//     _itemNameController = TextEditingController(text: widget.feed.itemName);
//     _categoryController =
//         // TextEditingController(text: widget.feed.category ?? '');
//     _needController = TextEditingController(
//         text: widget.feed.requiredQuantity?.toString() ?? '');
//     _stockController =
//         TextEditingController(text: widget.feed.quantity.toString());
//     // _expiryDate = widget.feed.expiryDate ?? DateTime.now();
//
//     _dbService = DatabaseServicesForFeed(widget.uid);
//   }
//
//   @override
//   void dispose() {
//     _itemNameController.dispose();
//     _categoryController.dispose();
//     _needController.dispose();
//     _stockController.dispose();
//     super.dispose();
//   }
//
//   Future<void> editFeedOnDatabase() async {
//     if (_formKey.currentState!.validate()) {
//       final updatedFeed = Feed(
//         itemName: _itemNameController.text,
//         // category: _categoryController.text,
//         requiredQuantity: int.tryParse(_needController.text),
//         quantity: int.parse(_stockController.text),
//         // expiryDate: _expiryDate,
//       );
//
//       await _dbService.infoToServerFeed(updatedFeed);
//     }
//   }
//
//   Future<void> deleteFeedDatabase() async {
//     await _dbService.deleteFeed(_itemNameController.text);
//   }
//
//   void _deleteFeed(BuildContext context) {
//     deleteFeedDatabase();
//     Navigator.pop(context);
//     Navigator.pushReplacement(
//         context, MaterialPageRoute(builder: (context) => const FeedPage()));
//   }
//
//   void _submitForm(BuildContext context) {
//     editFeedOnDatabase();
//
//     Navigator.pop(context);
//     Navigator.pushReplacement(
//         context, MaterialPageRoute(builder: (context) => const FeedPage()));
//
//     // Check if the expiry date is in the past
//     if (_expiryDate.isBefore(DateTime.now())) {
//       showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             title: const Text('Error'),
//             content: const Text('Please select a valid expiry date.'),
//             actions: <Widget>[
//               TextButton(
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                 },
//                 child: const Text('OK'),
//               ),
//             ],
//           );
//         },
//       );
//     } else {
//       editFeedOnDatabase();
//       Navigator.pop(context);
//       Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const FeedPage()));
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     languageCode = Provider.of<AppData>(context).persistentVariable;
//
//     if (languageCode == 'en') {
//       currentLocalization = LocalizationEn.translations;
//     } else if (languageCode == 'hi') {
//       currentLocalization = LocalizationHi.translations;
//     } else if (languageCode == 'pa') {
//       currentLocalization = LocalizationPun.translations;
//     }
//     return Scaffold(
//       backgroundColor: const Color.fromRGBO(240, 255, 255, 1),
//       appBar: AppBar(
//         backgroundColor: const Color.fromRGBO(13, 166, 186, 1.0),
//         title: Text(
//           currentLocalization['edit_feed_item']??"",
//           style: TextStyle(
//               color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: ListView(
//             children: [
//               Container(
//                 margin: const EdgeInsets.symmetric(vertical: 8.0),
//                 padding: const EdgeInsets.all(8.0),
//                 decoration: BoxDecoration(
//                   // border: Border.all(color: Colors.grey),
//                   borderRadius: BorderRadius.circular(8.0),
//                 ),
//                 child: TextFormField(
//                   readOnly: true,
//                   enabled: false,
//                   style: const TextStyle(fontSize: 20, color: Colors.black),
//                   controller: _itemNameController,
//                   decoration: InputDecoration(
//                       labelText:  currentLocalization['item_name']??"",
//                       labelStyle: TextStyle(fontSize: 20, color: Colors.black)),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter item name';
//                     }
//                     return null;
//                   },
//                 ),
//               ),
//               Container(
//                 margin: const EdgeInsets.symmetric(vertical: 8.0),
//                 padding: const EdgeInsets.all(8.0),
//                 decoration: BoxDecoration(
//                   border: Border.all(color: Colors.grey),
//                   borderRadius: BorderRadius.circular(8.0),
//                 ),
//                 child: TextFormField(
//                   controller: _categoryController,
//                   decoration:  InputDecoration(labelText:  currentLocalization['category']??"",),
//                 ),
//               ),
//               Container(
//                 margin: const EdgeInsets.symmetric(vertical: 8.0),
//                 padding: const EdgeInsets.all(8.0),
//                 decoration: BoxDecoration(
//                   border: Border.all(color: Colors.grey),
//                   borderRadius: BorderRadius.circular(8.0),
//                 ),
//                 child: TextFormField(
//                   controller: _needController,
//                   decoration: InputDecoration(labelText:  currentLocalization['need']??"",),
//                   keyboardType: TextInputType.number,
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter need';
//                     }
//                     if (int.tryParse(value) == null) {
//                       return 'Please enter a valid number';
//                     }
//                     return null;
//                   },
//                 ),
//               ),
//               Container(
//                 margin: const EdgeInsets.symmetric(vertical: 8.0),
//                 padding: const EdgeInsets.all(8.0),
//                 decoration: BoxDecoration(
//                   border: Border.all(color: Colors.grey),
//                   borderRadius: BorderRadius.circular(10.0),
//                 ),
//                 child: TextFormField(
//                   controller: _stockController,
//                   decoration:  InputDecoration(labelText: currentLocalization['stock']??"",),
//                   keyboardType: TextInputType.number,
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter stock';
//                     }
//                     if (int.tryParse(value) == null) {
//                       return 'Please enter a valid number';
//                     }
//                     return null;
//                   },
//                 ),
//               ),
//               Container(
//                 margin: const EdgeInsets.symmetric(vertical: 8.0),
//                 padding: const EdgeInsets.all(8.0),
//                 decoration: BoxDecoration(
//                   border: Border.all(color: Colors.grey),
//                   borderRadius: BorderRadius.circular(8.0),
//                 ),
//                 child: ListTile(
//                   title: Text(
//                       '${ currentLocalization['expiry_date']??""}: ${_expiryDate.year}-${_expiryDate.month}-${_expiryDate.day}'),
//                   onTap: () async {
//                     final selectedDate = await showDatePicker(
//                       context: context,
//                       initialDate: DateTime.now().isBefore(_expiryDate)
//                           ? _expiryDate
//                           : DateTime.now(),
//                       firstDate: DateTime.now(),
//                       lastDate: DateTime(DateTime.now().year + 10),
//                     );
//                     if (selectedDate != null) {
//                       setState(() {
//                         _expiryDate = selectedDate;
//                       });
//                     }
//                   },
//                 ),
//               ),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceAround,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   ElevatedButton(
//                     onPressed: () {
//                       _deleteFeed(context);
//                     },
//                     style: ButtonStyle(
//                       backgroundColor: MaterialStateProperty.all<Color>(
//                           const Color.fromRGBO(13, 166, 186, 0.9)),
//                     ),
//                     child:  Text(
//                       currentLocalization['delete']??"",
//                       style: TextStyle(
//                           color: Colors.black, fontWeight: FontWeight.bold),
//                     ),
//                   ),
//                   ElevatedButton(
//                     onPressed: () {
//                       _submitForm(context);
//                     },
//                     style: ButtonStyle(
//                       backgroundColor: MaterialStateProperty.all<Color>(
//                           const Color.fromRGBO(13, 166, 186, 0.9)),
//                     ),
//                     child: Text(
//                       currentLocalization['save']??"",
//                       style: TextStyle(
//                           color: Colors.black, fontWeight: FontWeight.bold),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
