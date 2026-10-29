import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/profile_selection_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://lekqsenksrmxelwxdknt.supabase.co',
    anonKey: 'sb_publishable_uEnlkScb4PFtNVdqBPwgEQ_-YXeaGea', 
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ADU Stock Control',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF2848A6),
        useMaterial3: true,
      ),
      home: const ProfileSelectionScreen(),
    );
  }
}