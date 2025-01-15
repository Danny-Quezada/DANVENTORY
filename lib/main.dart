import 'package:danventory/infraestructure/repository/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: "assets/.env");
  final url = dotenv.env["FLUTTER_APP_SUPABASE_URL"]!;
  final anonKey = dotenv.env['FLUTTER_APP_SUPABASE_ANON_KEY']!;

  // Using for SignIn (google, email)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
// Using for database, buckets
  await Supabase.initialize(url: url, anonKey: anonKey);
  
  final userRepository=UserRepository();
  userRepository.signInWithGoogle();



  runApp(const MaterialApp());
}
