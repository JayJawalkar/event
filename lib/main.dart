import 'package:event/features/auth/pages/signup_page.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://zmodgmvetxdandjbxdwq.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inptb2RnbXZldHhkYW5kamJ4ZHdxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzc2OTgzODEsImV4cCI6MjA1MzI3NDM4MX0.7MSHd0fPHK7PirE_jYP1ybMj1v13WNzmne1NoZPbZQw',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Event Hub',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: SignupPage(),
    );
  }
}
