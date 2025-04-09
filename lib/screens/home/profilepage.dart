import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farm_expense_mangement_app/main.dart';
import 'package:farm_expense_mangement_app/models/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../services/database/userdatabase.dart';
import '../wrappers/wrapperhome.dart';

class ProfileAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ProfileAppBar({super.key});

  final Color myColor = const Color(0xFF39445A);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: BackButton(
          onPressed: () =>
              Navigator.push(
                  context, MaterialPageRoute(
                  builder: (context) => const WrapperHomePage())
              )),
      centerTitle: true,
      title: const Text(
        'Profile',
        style: TextStyle(color: Colors.white,
        fontWeight: FontWeight.bold),
      ),
      backgroundColor: const Color.fromRGBO(13, 166, 186, 0.9),
      actions: [
        IconButton(
          onPressed: () {
            FirebaseAuth.instance.signOut();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MyApp()),
            );
          },
          icon: const Icon(
            Icons.output_outlined,
            color: Colors.white,
          ),
        )
      ],
      // flexibleSpace: Padding(
      //   padding: const EdgeInsets.fromLTRB(0,70,0,0),
      //   child: Column(
      //
      //    children: [
      //      const CircleAvatar(
      //        radius: 35,
      //        child: Icon(
      //          Icons.person,
      //          size: 60,
      //        ),
      //      ),
      //      const SizedBox(height: 20),
      //      ProfileInfoRow(
      //        label: 'Farm Owner: ',
      //        value: farmUser.ownerName,
      //      ),
      //    ]
      //   ),
      // ),
    );
  }

  @override
  // TODO: implement preferredSize
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class ProfilePage extends StatefulWidget implements PreferredSizeWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();

  @override
  // TODO: implement preferredSize
  Size get preferredSize => throw UnimplementedError();
}

class _ProfilePageState extends State<ProfilePage> {
  final user = FirebaseAuth.instance.currentUser;
  final uid = FirebaseAuth.instance.currentUser!.uid;
  late final Future<DocumentSnapshot<Map<String, dynamic>>>? _futureController;

  late FarmUser farmUser;
  late DatabaseServicesForUser userDb;

  @override
  void initState() {
    super.initState();
    userDb = DatabaseServicesForUser(uid);

    setState(() {

      _futureController = userDb.infoFromServer(uid);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _futureController,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasData) {
          farmUser = FarmUser.fromFireStore(snapshot.requireData, null);

          return Padding(
            padding: const EdgeInsets.all(0),
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.center,
              // crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  decoration: const BoxDecoration(

                    color: Color.fromRGBO(13, 166, 186, 0.9),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20.0),
                      bottomRight: Radius.circular(20.0),
                    ),
                  ),
                  height: 180,
                  width: double.infinity,
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      const CircleAvatar(
                        radius: 35,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.person,
                          size: 35,
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            " Farm Owner : ",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w800),
                          ),
                          Text(
                            farmUser.ownerName.toUpperCase(),
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // const CircleAvatar(
                //   radius: 50,
                //   child: Icon(
                //     Icons.person,
                //     size: 60,
                //   ),
                // ),
                const SizedBox(height: 50),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12.0, 0, 12, 0),
                  child: Container(
                    color: Colors.blueGrey[100],
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8.0, 18, 8, 18),
                      child: Column(
                        children: [
                          Row(
                            children: [

                              // Image.asset("asset/profile_dairy_logo.jpg",width: 40,height: 40),
                              const SizedBox(
                              child:Icon(Icons.home,color: Color.fromRGBO(13, 166, 186, 1),),
                              ),
                              const SizedBox(width: 16,),
                              // Image.asset("asset/profile_dairy_logo.jpg",width: 40,height: 40),
                              const SizedBox(
                                width: 100,
                                  child: Text(
                                "Farm Name  ",style: TextStyle(fontSize: 18),)
        ),
                              const SizedBox(width: 60,),
                              Text(farmUser.farmName,style: const TextStyle(fontSize: 18),),
                            ],
                          ),
                          // SizedBox(height: 20,),

                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            children: [

                              const Icon(Icons.email,color: Color.fromRGBO(13, 166, 186, 1),),
                              const SizedBox(width: 16,),

                              // Image.asset("asset/profile_dairy_logo.jpg",width: 40,height: 40),
                              const SizedBox(
                                  width: 100,
                                  child: Text(
                                    "Email  ",
                                    style: TextStyle(fontSize: 18),
                                  )),
                              const SizedBox(
                                width: 60,
                              ),
                              Expanded(
                                  child: Text(
                                user!.email ?? "",
                                style: const TextStyle(fontSize: 18),
                              )),
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.phone,
                                color: Color.fromRGBO(13, 166, 186, 1),
                              ),
                              const SizedBox(
                                width: 16,
                              ),
                              // Icon(Icons.location_pin,color: Color.fromRGBO(13, 166, 186, 1),),
                              // SizedBox(width: 16,),
                              // Image.asset("asset/profile_dairy_logo.jpg",width: 40,height: 40),
                              const SizedBox(
                                  width: 100,
                                  child: Text(
                                    "Phone No.  ",
                                    style: TextStyle(fontSize: 18),
                                  )),
                              const SizedBox(
                                width: 60,
                              ),
                              Expanded(
                                  child: Text(
                                "${farmUser.phoneNo}",
                                style: const TextStyle(fontSize: 18),
                              )),
                            ],
                          ),
                          const SizedBox(
                            height: 25,
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_pin,
                                color: Color.fromRGBO(13, 166, 186, 1),
                              ),
                              const SizedBox(
                                width: 16,
                              ),
                              // Image.asset("asset/profile_dairy_logo.jpg",width: 40,height: 40),
                              const SizedBox(
                                  width: 120,
                                  child: Text(
                                    "Farm Address ",
                                    style: TextStyle(fontSize: 18),
                                  )),
                              const SizedBox(
                                width: 40,
                              ),
                              Expanded(
                                  child: Text(
                                farmUser.location,
                                style: const TextStyle(fontSize: 18),
                              )),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // ProfileInfoRow(
                //   label: 'Farm Owner: ',
                //   value: farmUser.ownerName,
                // ),
                // ProfileInfoRow(
                //   label: 'Farm Name: ',
                //   value: farmUser.farmName,
                // ),
                // ProfileInfoRow(
                //   label: 'Email: ',
                //   value: user!.email ?? "",
                // ),
                // ProfileInfoRow(
                //   label: 'Phone Number: ',
                //   value: '${farmUser.phoneNo}',
                // ),
                // ProfileInfoRow(
                //   label: 'Address: ',
                //   value: farmUser.location,
                // ),
                const SizedBox(height: 40),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(13, 166, 186, 0.9),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfileEditPage(farmUser: farmUser,refresh: () {
                          setState(() {
                            final snapshot1 = userDb.infoFromServer(uid) as AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>>;
                            farmUser = FarmUser.fromFireStore(snapshot1.requireData, null);
                          });
                        },),
                      ),
                    );
                  },
                  child: const Text('Edit Profile'),
                ),
              ],
            ),
          );
        } else {
          return const Center(
            child: Text('Error in Fetch'),
          );
        }
      },
    );
  }
}

class ProfileEditPage extends StatefulWidget {
  final FarmUser farmUser;
  final Function refresh;
  const ProfileEditPage({super.key,required this.farmUser,required this.refresh});

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  final user = FirebaseAuth.instance.currentUser;
  final uid = FirebaseAuth.instance.currentUser!.uid;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _controllerName = TextEditingController();
  final _controllerOwnerName = TextEditingController();
  final _controllerPhone = TextEditingController();
  final _controllerAddress = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controllerName.text =  widget.farmUser.farmName;
    _controllerOwnerName.text =  widget.farmUser.ownerName;
    _controllerPhone.text =  widget.farmUser.phoneNo.toString();
    _controllerAddress.text =  widget.farmUser.location;

  }

  Future updateUser(FarmUser user) async{
    final db = DatabaseServicesForUser(uid);
    db.infoToServer(uid, user);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(13, 166, 186, 0.9),
        title: const Text(
          'Edit Profile',
          style: TextStyle(
              fontWeight: FontWeight.bold
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.fromLTRB(20.0, 40, 20, 20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _controllerOwnerName,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hintText: 'Owner Name',
                ),
              ),
              const SizedBox(height: 25),
              TextFormField(
                controller: _controllerName,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hintText: 'Farm Name',
                ),
              ),
              const SizedBox(height: 25),
              TextFormField(
                readOnly: true,
                controller: _controllerPhone,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hintText: 'Phone No.',
                ),
              ),
              const SizedBox(height: 25),
              TextFormField(
                controller: _controllerAddress,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hintText: 'Farm Address',
                ),
              ),
              const SizedBox(height: 25),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(13, 166, 186, 0.9),
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  final FarmUser farmUser = FarmUser(
                      ownerName: _controllerOwnerName.text,
                      farmName: _controllerName.text,
                      location: _controllerAddress.text,
                      phoneNo: int.parse(_controllerPhone.text)
                  );
                  updateUser(farmUser);
                  Navigator.pop(context);
                },
                child: const Text(
                  'Save Changes',
                  style: TextStyle(fontSize: 17,
                      color: Colors.black),)
                ),

      ])

        )
    ));

  }
}

class ProfileInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const ProfileInfoRow({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
