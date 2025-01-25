import 'package:danventory/domain/interfaces/icategory_model.dart';
import 'package:danventory/domain/interfaces/iorder_model.dart';
import 'package:danventory/domain/interfaces/iproduct_model.dart';
import 'package:danventory/domain/interfaces/iuser_model.dart';
import 'package:danventory/infraestructure/repository/category_repository.dart';
import 'package:danventory/infraestructure/repository/order_repository.dart';
import 'package:danventory/infraestructure/repository/product_repository.dart';
import 'package:danventory/infraestructure/repository/user_repository.dart';
import 'package:danventory/providers/category_provider.dart';
import 'package:danventory/providers/order_provider.dart';
import 'package:danventory/providers/product_provider.dart';
import 'package:danventory/providers/user_provider.dart';
import 'package:danventory/ui/pages/bottom_navigation_page.dart';
import 'package:danventory/ui/pages/initial_page.dart';
import 'package:danventory/ui/pages/login_page.dart';
import 'package:danventory/ui/pages/signup_page.dart';
import 'package:danventory/ui/utils/theme_setting.dart';
import 'package:danventory/ui/widgets/safe_scaffold.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

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
              iUserModel: Provider.of<IUserModel>(context, listen: false))),
      Provider<ICategoryModel>(create: (_) => CategoryRepository()),
      ChangeNotifierProvider<CategoryProvider>(
          create: (context) => CategoryProvider(
              categoryModel:
                  Provider.of<ICategoryModel>(context, listen: false))),
      Provider<IProductModel>(create: (_) => ProductRepository()),
      ChangeNotifierProvider<ProductProvider>(
          create: (context) => ProductProvider(
              iProductModel:
                  Provider.of<IProductModel>(context, listen: false))),
      Provider<IOrderModel>(create: (_) => OrderRepository()),
      ChangeNotifierProvider<OrderProvider>(
          create: (context) => OrderProvider(
              iOrderModel: Provider.of<IOrderModel>(context, listen: false))),
    ],
    child: MaterialApp(
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: const [
         Locale('es', ''),
        Locale('en', ''),
       
      ],
      debugShowCheckedModeBanner: false,
      theme: ThemeSetting.themeData,
      themeMode: ThemeMode.light,
      initialRoute: "/",
      routes: {
        "/": (context) =>
            Consumer<UserProvider>(builder: (context, userProvider, _) {
              return StreamBuilder(
                  stream: FirebaseAuth.instance.authStateChanges(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return FutureBuilder(
                          future: userProvider.loadCurrentUser(),
                          builder: (context, userSnapshot) {
                            if (userProvider.userModel == null) {
                              return const SafeScaffold(
                                body: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
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
