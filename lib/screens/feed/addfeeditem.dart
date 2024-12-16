// import 'package:farm_expense_mangement_app/screens/feed/feedpage.dart';
// import 'package:flutter/material.dart';
// import 'package:farm_expense_mangement_app/services/database/feeddatabase.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:provider/provider.dart';
//
// import '../../models/feed.dart';
// import '../../main.dart';
// import '../home/localisations_en.dart';
// import '../home/localisations_hindi.dart';
// import '../home/localisations_punjabi.dart';
//
// class AddFeedItem extends StatefulWidget {
//   const AddFeedItem({super.key});
// // const AddFeedItem({Key? key}) : super(key: key);
//
//   @override
//   State<AddFeedItem> createState() => _AddFeedItemState();
// // _AddFeedItemState createState() => _AddFeedItemState();
// }
//
// class _AddFeedItemState extends State<AddFeedItem> {
//   late Map<String, String> currentLocalization= {};
//   late String languageCode = 'en';
//
//   final TextEditingController _itemNameController = TextEditingController();
//   final TextEditingController _quantityController = TextEditingController();
//   final TextEditingController _requiredQuantityController =
//       TextEditingController();
//   final TextEditingController _expiryDateController = TextEditingController();
//   final TextEditingController _categoryDateController = TextEditingController();
//
//   late final DatabaseServicesForFeed cattleDb;
//   final user = FirebaseAuth.instance.currentUser;
//   final uid = FirebaseAuth.instance.currentUser!.uid;
//
//   void _saveFeedItem(BuildContext context) {
//     String itemName = _itemNameController.text.trim();
//     int quantity = int.tryParse(_quantityController.text.trim()) ?? 0;
//     int requiredQuantity =
//         int.tryParse(_requiredQuantityController.text.trim()) ?? 0;
//     String category = _categoryDateController.text.trim();
//     DateTime expiryDate = DateTime.parse(_expiryDateController.text.trim());
//     Feed newFeedItem = Feed(
//         itemName: itemName,
//         quantity: quantity,
//         requiredQuantity: requiredQuantity);
//         // category: category,
//         // expiryDate: expiryDate);
//
//     // Now you can save this newFeedItem to Firestore or perform any other actions here
//     // For example, you can use the DatabaseServicesForFeed to save the feed item
//     // DatabaseServicesForFeed(itemName).infoToServerFeed(newFeedItem);
//     cattleDb.infoToServerFeed(newFeedItem);
//
//     // After saving, you can navigate back to the previous screen
//     // Navigator.pop(context);
//     Navigator.pop(context);
//     Navigator.pushReplacement(
//         context, MaterialPageRoute(builder: (context) => const FeedPage()));
//   }
//
//   Future<void> _selectDate(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime.now(),
//       lastDate: DateTime(3000),
//     );
//     if (picked != null && picked.day.toString() != _expiryDateController.text) {
//       setState(() {
//         _expiryDateController.text = picked.toString().split(' ')[0];
//       });
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
//             currentLocalization['add_feed_item']??"",
//           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.fromLTRB(8, 0, 8, 26),
//         child: ListView(
//           children: [
//             Padding(
//               padding: const EdgeInsets.fromLTRB(4, 8, 4, 0),
//               child: TextField(
//                 controller: _itemNameController,
//                 decoration: InputDecoration(
//                   labelText: currentLocalization['item_name']??"",
//                   border: OutlineInputBorder(),
//                   filled: true,
//                   fillColor: Color.fromRGBO(240, 255, 255, 1),
//                 ),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.fromLTRB(4, 8, 4, 0),
//               child: TextField(
//                 controller: _quantityController,
//                 decoration: InputDecoration(
//                   labelText: currentLocalization['quantity']??"",
//                   border: OutlineInputBorder(),
//                   filled: true,
//                   fillColor: Color.fromRGBO(240, 255, 255, 1),
//                 ),
//                 keyboardType: TextInputType.number,
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.fromLTRB(4, 8, 4, 0),
//               child: TextField(
//                 controller: _requiredQuantityController,
//                 decoration: InputDecoration(
//                   labelText: currentLocalization['required_quantity']??"",
//                   border: OutlineInputBorder(),
//                   filled: true,
//                   fillColor: Color.fromRGBO(240, 255, 255, 1),
//                 ),
//                 keyboardType: TextInputType.number,
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.fromLTRB(4, 8, 4, 0),
//               child: TextField(
//                 controller: _categoryDateController,
//                 decoration: InputDecoration(
//                   labelText: currentLocalization['category']??"",
//                   border: OutlineInputBorder(),
//                   filled: true,
//                   fillColor: Color.fromRGBO(240, 255, 255, 1),
//                 ),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.fromLTRB(4, 8, 4, 0),
//               child: TextFormField(
//                 controller: _expiryDateController,
//                 decoration: InputDecoration(
//                   labelText: currentLocalization['expiry_date']??"",
//                   hintText: "YYYY-MM-DD",
//                   border: const OutlineInputBorder(),
//                   filled: true,
//                   fillColor: const Color.fromRGBO(240, 255, 255, 1),
//                   suffixIcon: IconButton(
//                     icon: const Icon(Icons.calendar_today),
//                     onPressed: () => _selectDate(context),
//                   ),
//                 ),
//                 keyboardType: TextInputType.datetime,
//               ),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 _saveFeedItem(context);
//               },
//               style: ButtonStyle(
//                 backgroundColor: MaterialStateProperty.all<Color>(
//                     const Color.fromRGBO(13, 166, 186, 1)), // Background color
//                 // Other styles such as padding, shape, textStyle can also be specified here
//               ),
//               child:  Text(
//                 currentLocalization['save']??"",
//                 style:
//                     TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   @override
//   void initState() {
// // TODO: implement initState
//     super.initState();
//
//     cattleDb = DatabaseServicesForFeed(uid);
//   }
//
//   @override
//   void dispose() {
//     _itemNameController.dispose();
//     _quantityController.dispose();
//     _requiredQuantityController.dispose();
//     super.dispose();
//   }
// }
