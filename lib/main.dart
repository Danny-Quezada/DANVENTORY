import 'package:danventory/domain/interfaces/iuser_model.dart';
import 'package:danventory/infraestructure/repository/user_repository.dart';
import 'package:danventory/providers/user_provider.dart';
import 'package:danventory/ui/pages/bottom_navigation_page.dart';
import 'package:danventory/ui/pages/initial_page.dart';
import 'package:danventory/ui/pages/login_page.dart';
import 'package:danventory/ui/pages/signup_page.dart';
import 'package:danventory/ui/utils/theme_setting.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
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
  



  runApp(MultiProvider(
    providers: [
       Provider<IUserModel>(create: (_) => UserRepository()),
       ChangeNotifierProvider<UserProvider>(
            create: (context) => UserProvider(
                iUserModel:
                    Provider.of<IUserModel>(context, listen: false))),
                  
    ],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeSetting.themeData,
      themeMode: ThemeMode.light,
      initialRoute: "/",
      routes: {
        "/": (context) => Consumer<UserProvider>(builder: (context, userProvider, _) {
                return StreamBuilder(
                    stream: FirebaseAuth.instance.authStateChanges(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return FutureBuilder(
                            future: userProvider.loadCurrentUser(),
                            builder: (context, userSnapshot) {
                              return const BottomNavigationPage();
                            });
                      } else {
                        return const InitialPage();
                      }
                    });
              }),
        "/login": (context) => LoginPage(),
        "/signup": (context) => SignUpPage(),
      },
    ),
  ));
}
