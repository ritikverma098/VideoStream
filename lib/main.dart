import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video/firebase_options.dart';
import 'package:video/homePage.dart';
import 'package:video/number.dart';
Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
    @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: [
      StreamProvider<User?>.value(value:FirebaseAuth.instance.authStateChanges(),
          initialData: null),
    ],
    child: MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      useMaterial3: true,

      ),
      home: Consumer<User?>(
      builder: (context, user, _) {
      if (user == null){
      return const NumberReq();
      }else{
      return HomePage();
      }
      },

      ),),
    );
  }
}

