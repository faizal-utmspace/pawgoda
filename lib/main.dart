import 'package:pawgoda/pages/get_started.dart';
import 'package:pawgoda/pages/home.dart';
import 'package:pawgoda/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize for web
  if (Firebase.apps.isNotEmpty) {
    FirebaseAuth.instanceFor(app: Firebase.app());
  }


  try {
    final test = await FirebaseFirestore.instance.collection('test').get();
    print('Firestore connected! Found ${test.docs.length} docs.');
  } catch (e) {
    print('Firestore error: $e');
  }

  runApp(const MyApp());

}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PawGoda',
      theme: ThemeData(
          fontFamily: 'Poppins',
          primaryColor: Styles.blackColor,
          colorScheme:
              ColorScheme.fromSwatch().copyWith(primary: Styles.blackColor)),
      // home: const GetStarted(),
      home: const Home(),
    );
  }
}
