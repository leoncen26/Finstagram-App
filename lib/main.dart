import 'package:finstagram/pages/auth_wrapper.dart';
import 'package:finstagram/pages/home_page.dart';
import 'package:finstagram/pages/login_page.dart';
import 'package:finstagram/pages/register_page.dart';
import 'package:finstagram/provider/auth_provider.dart';
import 'package:finstagram/services/firebase_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  GetIt.instance.registerSingleton<FirebaseService>(
    FirebaseService(),
  );
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => AuthProvider()),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Finstagram',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.red,
          backgroundColor: Colors.red,
        ),
        primarySwatch: Colors.red,
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthWrapper(),
        'register': (context) => const RegisterPage(),
        'login': (context) => const LoginPage(),
        'home': (context) => const HomePage(),
      },
    );
  }
}
