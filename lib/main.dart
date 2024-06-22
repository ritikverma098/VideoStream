import 'package:dynamic_color/dynamic_color.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video/firebase_options.dart';
import 'package:video/home_page.dart';
import 'package:video/number.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.playIntegrity,
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
    child: DynamicColorBuilder(builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
      return MaterialApp(
        title: 'Video Streaming',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: lightDynamic,
          useMaterial3: true,

        ),
        darkTheme: ThemeData(
          colorScheme: darkDynamic,
          brightness: Brightness.dark,
          useMaterial3: true,
        ),
        home: Consumer<User?>(
          builder: (context, user, _) {
            if (user == null){
              return const NumberReq();
            }else{
              return const HomePage();
            }
          },

        ),);
    },),
    );
  }
}

