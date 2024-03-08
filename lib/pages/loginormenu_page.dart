import 'package:flutter/material.dart';
import 'package:listinha/pages/login_page.dart';
import 'package:listinha/pages/menu_page.dart';
import 'package:listinha/utils/dao.dart';

class LoginOrMenuPage extends StatelessWidget {
  const LoginOrMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: FutureBuilder(
        future: _userIsLogged(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return Center(child: CircularProgressIndicator());
          } else {
            return snapshot.hasData == false ? LoginPage() : MenuPage();
          }
        },
      )),
    );
  }

  _userIsLogged() async {
    DAO dao = new DAO();
    var db = await dao.openDB();
    return await db.query('user');
  }
}
