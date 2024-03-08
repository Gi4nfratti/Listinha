import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:listinha/pages/list_detail_page.dart';
import 'package:listinha/pages/loginormenu_page.dart';
import 'package:listinha/pages/menu_page.dart';
import 'package:listinha/pages/onboarding_page.dart';
import 'package:listinha/pages/sub_menu_page.dart';
import 'package:listinha/stores/lists_store.dart';
import 'package:listinha/utils/app_routes.dart';
import 'package:listinha/utils/dao.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: Colors.transparent));
  final prefs = await SharedPreferences.getInstance();
  final showHome = prefs.getBool('showHome') ?? false;

  DAO dao = new DAO();
  await dao.openDB();

  runApp(MyApp(showHome: showHome));
}

class MyApp extends StatelessWidget {
  final bool showHome;
  const MyApp({
    Key? key,
    required this.showHome,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [Provider<ListsStore>(create: (context) => ListsStore())],
        child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSwatch(
                backgroundColor: Color(0xFFD9D9D9),
                accentColor: Color(0xFF000000),
                primarySwatch: Colors.grey,
              ),
              useMaterial3: true,
            ),
            home: showHome ? LoginOrMenuPage() : OnboardingPage(),
            routes: {
              AppRoutes.LOGIN_OR_MENU: (context) => LoginOrMenuPage(),
              AppRoutes.MENU: (context) => MenuPage(),
              AppRoutes.SUB_MENU: (context) => SubMenuPage(),
              AppRoutes.LIST_DETAIL: (context) => ListDetailPage(),
            }));
  }
}
