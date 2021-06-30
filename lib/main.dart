import 'package:flutter/material.dart';
import 'package:iot_app/app.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Import the firebase_core plugin
import 'package:firebase_core/firebase_core.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(home: Login()));
}

/// We are using a StatefulWidget such that we only create the [Future] once,
/// no matter how many times our widget rebuild.
/// If we used a [StatelessWidget], in the event where [App] is rebuilt, that
/// would re-initialize FlutterFire and make our application re-enter loading state,
/// which is undesired.
class Login extends StatefulWidget {
  // Create the initialization Future outside of `build`:
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  /// The future is part of the state of our widget. We should not call `initializeApp`
  /// directly inside [build].
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();
  TextEditingController _email = TextEditingController();
  TextEditingController _password = TextEditingController();
  bool _success = false;
  String _errorMsg = '';
  String _userEmail = '';

  Future _register(_email, _password) async {
    try {
      UserCredential user = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: _email.text, password: _password.text);
      if (user != null) {
        setState(() {
          _success = true;
          _userEmail = user.user!.email.toString();
        });
      } else {
        setState(() {
          _success = false;
        });
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        _errorMsg = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        _errorMsg = 'The account already exists for that email.';
      }
    } catch (e) {
      _errorMsg = e.toString();
    }
  }

  Future _login(_email, _password) async {
    try {
      UserCredential user = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: _email.text, password: _password.text);

      if (user != null) {
        setState(() {
          _success = true;
          _userEmail = user.user!.email.toString();
        });
      } else {
        setState(() {
          _success = false;
        });
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        _errorMsg = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        _errorMsg = 'Wrong password provided for that user.';
      } else {
        _errorMsg = e.toString();
      }
    }
  }

  void msgDialog(_errorMsg, _actionText) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 0,
            backgroundColor: Colors.white,
            actions: [
              FlatButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(_actionText))
            ],
            content: Text(_errorMsg),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // Initialize FlutterFire:
      future: _initialization,
      builder: (context, snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }

        // Once complete, show your application
        if (snapshot.connectionState == ConnectionState.done) {
          return MaterialApp(
            title: 'My Home',
            home: Scaffold(
              appBar: AppBar(
                title: Text('My Home'),
              ),
              body: Align(
                alignment: Alignment.center,
                child: Container(
                  width: 300,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        margin: EdgeInsets.only(top: 5, bottom: 30),
                        padding: EdgeInsets.only(left: 5),
                        alignment: Alignment.centerLeft,
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Email',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            TextFormField(
                              controller: _email,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 5, bottom: 30),
                        padding: EdgeInsets.only(left: 5),
                        alignment: Alignment.centerLeft,
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Password',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            TextFormField(
                              controller: _password,
                            ),
                          ],
                        ),
                      ),
                      RaisedButton(
                        color: Colors.blue,
                        onPressed: () async {
                          await _login(_email, _password);
                          if (_success) {
                            _success = false;
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => MyApp(),
                              ),
                            );
                          } else {
                            msgDialog(_errorMsg, 'Okay');
                          }
                        },
                        child: Text(
                          'Sign In',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      RaisedButton(
                        color: Colors.orange,
                        onPressed: () async {
                          await _register(_email, _password);
                          if (_success) {
                            _success = false;
                            msgDialog(
                                'You have registered successfully. You may now login.',
                                'Continue');
                          } else {
                            msgDialog(_errorMsg, 'Okay');
                          }
                        },
                        child: Text(
                          'Register',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        // Otherwise, show something whilst waiting for initialization to complete
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}
