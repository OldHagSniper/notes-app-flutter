import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:learningdart/constants/routes.dart';
import 'package:learningdart/views/notes_view.dart';

import 'dart:developer' as devtools show log;

import '../utils/dialogs.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Column(
        children: [
          TextField(
            controller: _email,
            enableSuggestions: false,
            autocorrect: false,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: 'Email',
            ),
          ),
          TextField(
            controller: _password,
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
            decoration: const InputDecoration(
              hintText: 'Password',
            ),
          ),
          TextButton(
            onPressed: () async {
              var email = _email.text;
              var password = _password.text;
              try {
                final userCreds = await FirebaseAuth.instance
                    .signInWithEmailAndPassword(
                        email: email, password: password);
                devtools.log("Login Successful");
                var emailVerified = userCreds.user?.emailVerified ?? false;
                if (emailVerified) {
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil(notesRoute, (_) => false);
                } else {
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil(verifyEmailRoute, (_) => false);
                }
                devtools.log(userCreds.toString());
              } on FirebaseAuthException catch (e) {
                if (e.code == 'user-not-found') {
                  devtools.log("User not found");
                  await showErrorDialog(context, e.code);
                  _email.clear();
                  _password.clear();
                } else if (e.code == 'wrong-password') {
                  devtools.log('Wrong Password');
                  await showErrorDialog(context, e.code);
                  _email.clear();
                  _password.clear();
                } else {
                  devtools.log('Something Wrong Happened');
                  await showErrorDialog(context, e.code);
                }
              } catch (e) {
                await showErrorDialog(context, e.toString());
              }
            },
            child: const Text("Login"),
          ),
          TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil(registerRoute, (route) => false);
              },
              child: const Text("Haven't registered yet? Register Here"))
        ],
      ),
    );
  }
}
