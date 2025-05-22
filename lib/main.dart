import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wention/screen/SingIn_screen.dart';
import 'package:wention/screen/Singup_screen.dart';
import 'package:wention/screen/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangePlatformBrightness() {
    final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
    _setSystemUIOverlayStyle(brightness);
  }

  void _setSystemUIOverlayStyle(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: isDark ? const Color(0xFF0B1B3B) : Colors.white,
        systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
    _setSystemUIOverlayStyle(brightness);

    final user = FirebaseAuth.instance.currentUser;

    String initialRoute;
    if (user == null) {
      initialRoute = '/login';
    } else if (!user.emailVerified) {
      initialRoute = '/signup'; // If email not verified, go to signup/verification
    } else {
      initialRoute = '/home';
    }

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Wention",
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      initialRoute: initialRoute,
      getPages: [
        GetPage(name: '/login', page: () => const SignInScreen()),
        GetPage(name: '/signup', page: () => const SignupScreen()),
        GetPage(name: '/home', page: () => const HomeScreen()),
      ],
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
