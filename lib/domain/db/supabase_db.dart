import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseDB {
  static final SupabaseDB _instance = SupabaseDB._internal();

  factory SupabaseDB() {
    return _instance;
  }

  SupabaseDB._internal();

  final SupabaseClient client = Supabase.instance.client;
}
