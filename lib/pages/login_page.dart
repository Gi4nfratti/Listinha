import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:listinha/pages/menu_page.dart';
import 'package:listinha/utils/dao.dart';
import 'package:listinha/utils/static_texts.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  var controllerEmail = TextEditingController(text: "");
  var controllerPassword = TextEditingController(text: "");
  var normalTextStyle =
      TextStyle(fontFamily: 'ITC', fontSize: 18, color: Colors.grey.shade700);
  var hintTextStyle = TextStyle(fontFamily: 'ITC', fontSize: 18);
  var errText = "";
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Container(
        decoration: BoxDecoration(
            gradient: RadialGradient(radius: 2, colors: [
          Theme.of(context).colorScheme.background,
          Theme.of(context).colorScheme.onPrimary,
        ])),
        child: Center(
          child: Container(
            height: MediaQuery.of(context).size.height / 1.5,
            width: MediaQuery.of(context).size.width - 30,
            child: Card(
              elevation: 4,
              shape: OutlineInputBorder(
                  borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(10), top: Radius.circular(20))),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Image.asset('lib/images/icon.png'),
                        Text(
                          'Listinha',
                          style: TextStyle(
                              fontFamily: 'Yeseva',
                              fontSize: 32,
                              color: Colors.grey.shade700),
                        )
                      ],
                    ),
                    Column(
                      children: [
                        _generateTextField(controllerEmail, 'E-mail'),
                        _generateTextField(controllerPassword, 'Senha',
                            isObscure: true),
                      ],
                    ),
                    Column(
                      children: [
                        _isLoading
                            ? CircularProgressIndicator()
                            : Column(
                                children: [
                                  ElevatedButton(
                                      style: ButtonStyle(
                                          elevation:
                                              MaterialStatePropertyAll(4)),
                                      onPressed: () => _createUser(
                                            controllerEmail.text,
                                            controllerPassword.text,
                                          ),
                                      child: Text(
                                        'Cadastre-se',
                                        style: normalTextStyle,
                                      )),
                                  ElevatedButton(
                                      style: ButtonStyle(
                                          elevation:
                                              MaterialStatePropertyAll(4)),
                                      onPressed: () => _signIn(
                                          controllerEmail.text,
                                          controllerPassword.text),
                                      child: Text(
                                        'Entrar',
                                        style: normalTextStyle,
                                      )),
                                ],
                              ),
                        SizedBox(height: 10),
                        Text(errText,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontFamily: 'ITC',
                                fontSize: 16,
                                color: Colors.red.shade700)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      )),
    );
  }

  _generateTextField(TextEditingController controller, String hint,
      {bool isObscure = false}) {
    return TextFormField(
      onTap: () => setState(() => errText = ""),
      controller: controller,
      style: normalTextStyle,
      obscureText: isObscure,
      decoration: InputDecoration(hintText: hint, hintStyle: hintTextStyle),
    );
  }

  _createUser(String email, String pwd) async {
    try {
      setState(() => _isLoading = true);
      var user = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: pwd,
      );
      if (user.user!.email!.isNotEmpty) {
        if (await _createFirebaseUserTable(email) == false) {
          _handleExceptions("");
        } else {
          await _signIn(email, pwd);
        }
      }
    } on FirebaseAuthException catch (code) {
      _handleExceptions(code.code);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  _signIn(String email, String pwd) async {
    try {
      DAO dao = new DAO();
      setState(() => _isLoading = true);
      var user = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: pwd,
      );
      if (user.user!.email!.isNotEmpty) {
        if (await dao.saveUser(email, pwd) == 0) {
          _handleExceptions("");
        } else {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => MenuPage()),
              (Route<dynamic> route) => false);
        }
      } else {
        _handleExceptions("");
      }
    } on FirebaseAuthException catch (code) {
      _handleExceptions(code.code);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<bool> _createFirebaseUserTable(String email) async {
    try {
      await FirebaseFirestore.instance.collection('task').doc(email).set({
        'base': {
          'lists': Map<String, Object>(),
        }
      });
      return true;
    } on Exception {
      return false;
    }
  }

  _handleExceptions(String code) {
    String errorText = "";
    if (code == "email-already-in-use")
      errorText = firebaseExceptionList[0];
    else if (code == "invalid-email")
      errorText = firebaseExceptionList[1];
    else if (code == "operation-not-allowed")
      errorText = firebaseExceptionList[2];
    else if (code == "weak-password")
      errorText = firebaseExceptionList[3];
    else if (code == "wrong-password")
      errorText = firebaseExceptionList[4];
    else if (code == "invalid-email")
      errorText = firebaseExceptionList[1];
    else if (code == "user-disabled")
      errorText = firebaseExceptionList[5];
    else if (code == "user-not-found" ||
        code == "invalid-credential" ||
        code == "channel-error")
      errorText = firebaseExceptionList[6];
    else
      errorText = firebaseExceptionList[7];

    setState(() {
      errText = errorText;
    });
  }
}
