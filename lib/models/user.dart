import 'package:listinha/utils/dao.dart';

class User {
  final String email;
  final String pwd;
  final String name;

  User({this.email = "", this.pwd = "", this.name = ""});

  Future<String> getEmail() async {
    DAO dao = new DAO();
    var result = await dao
        .openDB()
        .then((value) => value.query('user', columns: ['email'], limit: 1));
    return result.map((e) => e['email']).single as String;
  }
}
