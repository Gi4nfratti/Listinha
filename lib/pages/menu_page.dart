import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:listinha/components/list_listview.dart';
import 'package:listinha/components/misc.dart';
import 'package:listinha/pages/loginormenu_page.dart';
import 'package:listinha/utils/dao.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});
  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  DAO dao = new DAO();
  FirebaseDAO fDao = FirebaseDAO();
  late SharedPreferences prefs;

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    prefs = await SharedPreferences.getInstance();
    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.wifi ||
        connectivityResult == ConnectivityResult.ethernet ||
        connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.vpn) {
      await dao.getTime(prefs.getString('cloudTime') ?? "");
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Sem conexão com a internet')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 5,
                vertical: 40,
              ),
              child: Column(children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton.icon(
                      style: ButtonStyle(
                          backgroundColor: MaterialStatePropertyAll(
                              Theme.of(context).colorScheme.background)),
                      onPressed: () async => await dao
                          .processFirebaseRoutine()
                          .whenComplete(
                              () async => await dao.signOut().whenComplete(() {
                                    prefs.setBool('getCloudData', false);
                                    Navigator.of(context).pushAndRemoveUntil(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                LoginOrMenuPage()),
                                        (Route<dynamic> route) => false);
                                  })),
                      icon: Icon(
                        Icons.logout_rounded,
                        color: Colors.black,
                      ),
                      label: Text(
                        'Sair',
                        style: TextStyle(
                            fontFamily: 'ITC',
                            fontSize: 18,
                            color: Colors.black),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [Misc().getTitle('Olá!')],
                  ),
                ),
                Misc().getSpacer(),
                SizedBox(height: 60),
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "O que vai hoje?",
                      style: Misc().getStyle(),
                    ),
                  ),
                ),
                List_ListView(),
              ])),
        ));
  }
}
