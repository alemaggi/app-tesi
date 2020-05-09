import 'package:app_tesi/Login/login.dart';
import 'package:app_tesi/Services/auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class Signup extends StatefulWidget {
  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  _setNewUserIntoFirestore(String userEmail, String uid) async {
    Firestore.instance.runTransaction((transaction) async {
      await transaction
          .set(Firestore.instance.collection("users").document(uid), {
        'email': userEmail,
        'name': 'Anonimo',
        'surname': 'Anonimo',
        'profilePicUrl':
            'https://firebasestorage.googleapis.com/v0/b/app-tesi-16e05.appspot.com/o/profilePic%2FgenericProfilePic.png?alt=media&token=d5710a15-35a7-42ff-9999-5c977f9325a9',
        'myFridge': [],
        'allergens': [],
        'favoriteRecipes': [],
        'showRecipeWithAllergens': false,
      });
    });
  }

  final _signupFormKey = GlobalKey<FormState>();
  //Per autenticazione
  final AuthService _auth = AuthService();
  String _email;
  String _password;
  String _confirmPassword;
  String error = ' ';

  bool showPassword = false;
  bool showConfirmPassword = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.65,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(50),
          topRight: Radius.circular(50),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(
                top: MediaQuery.of(context).size.width * 0.1,
                bottom: MediaQuery.of(context).size.width * 0.01),
            width: MediaQuery.of(context).size.width * 0.8,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Text(
                  "Create Account",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.8,
            constraints: BoxConstraints(minWidth: 100, maxWidth: 500),
            child: Form(
              key: _signupFormKey,
              child: Column(
                children: <Widget>[
                  TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: "Email",
                      prefixIcon: Icon(Icons.email),
                    ),
                    validator: (val) =>
                        val.isEmpty ? 'Enter a valid email' : null,
                    onChanged: (val) {
                      setState(() {
                        String tmp = val.toLowerCase();
                        _email = tmp.trim();
                      });
                    },
                  ),
                  Container(
                    height: MediaQuery.of(context).size.width * 0.05,
                  ),
                  TextFormField(
                    keyboardType: TextInputType.text,
                    obscureText: !showPassword,
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                          icon: showPassword
                              ? Icon(Icons.visibility_off)
                              : Icon(Icons.remove_red_eye),
                          onPressed: () {
                            setState(() {
                              showPassword = !showPassword;
                            });
                          }),
                      hintText: "Password",
                      prefixIcon: Icon(Icons.lock),
                    ),
                    validator: (val) =>
                        val.length < 6 ? 'Enter a valid password' : null,
                    onChanged: (val) {
                      setState(() {
                        _password = val;
                      });
                    },
                  ),
                  Container(
                    height: MediaQuery.of(context).size.width * 0.05,
                  ),
                  TextFormField(
                    keyboardType: TextInputType.text,
                    obscureText: !showConfirmPassword,
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                          icon: showConfirmPassword
                              ? Icon(Icons.visibility_off)
                              : Icon(Icons.remove_red_eye),
                          onPressed: () {
                            setState(() {
                              showConfirmPassword = !showConfirmPassword;
                            });
                          }),
                      hintText: "Confirm Password",
                      prefixIcon: Icon(Icons.lock),
                    ),
                    validator: (val) =>
                        val.length < 6 ? 'Enter a valid password' : null,
                    onChanged: (val) {
                      setState(() {
                        _confirmPassword = val;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          Container(
            constraints: BoxConstraints(minWidth: 100, maxWidth: 500),
            width: MediaQuery.of(context).size.width * 0.8,
            margin: EdgeInsets.only(
              top: 10,
            ),
            child: Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color.fromRGBO(233, 0, 45, 1),
                fontSize: 14,
              ),
            ),
          ),
          Container(
            constraints:
                BoxConstraints(minWidth: 100, maxWidth: 500, maxHeight: 75),
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.width * 0.12,
            margin: EdgeInsets.only(
              top: MediaQuery.of(context).size.width * 0.1,
            ),
            child: FlatButton(
              child: Text(
                "Sign Up",
                style: TextStyle(
                    color: Color.fromRGBO(233, 0, 45, 1),
                    fontSize: 26,
                    fontWeight: FontWeight.bold),
              ),
              onPressed: () async {
                setState(() {
                  error = ''; //Cosi togliamo eventuali errori precedenti
                });
                if (_signupFormKey.currentState.validate()) {
                  if (_password == _confirmPassword) {
                    print(_email);
                    print(_password);
                    dynamic result = await _auth.registerWithEmailAndPassword(
                        _email, _password);
                    if (result == null) {
                      setState(() {
                        setState(() {
                          error = 'ERROR: Supply a valid email and password';
                        });
                      });
                    } else {
                      _setNewUserIntoFirestore(_email, result.uid);
                      send_mail();
                    }
                  } else {
                    setState(() {
                      error = 'ERROR: Non matching password';
                    });
                    print("Le password non metchano");
                  }
                } else {
                  setState(() {
                    error = 'ERROR: Some fields are not valid';
                  });
                  print("Some fields are not valid");
                }
              },
              shape: RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(10.0),
                side: BorderSide(
                  color: Color.fromRGBO(233, 0, 45, 1),
                  width: 3,
                ),
              ),
            ),
          ),
          Container(
            margin:
                EdgeInsets.only(top: MediaQuery.of(context).size.width * 0.05),
            child: Text(
              "Or",
              style: TextStyle(
                fontSize: 14,
              ),
            ),
          ),
          Center(
            child: FlatButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Login()),
                );
              },
              child: Text("I already have an account"),
            ),
          ),
        ],
      ),
    );
  }

//Funzione send_mail quando uno si registra:
  void send_mail() async {
    String username = "sauceforyou2019@gmail.com"; //Your Email;
    String password = "spinaxomis"; //Your Email's password;

    final smtpServer = gmail(username, password);
    // Creating the Gmail server

    // Create our email message.
    final message = Message()
      ..from = Address(username)
      ..recipients.add(_email) //recipent email
      ..subject = 'Benvenuto nel nostro servizio' //subject of the email
      ..text =
          'Ti ringraziamo di aver scelto di iscriverti alla nostra applicazione, di seguito troverai un riepilogo dei dati inseriti: \n\nemail: ' +
              _email +
              ' \npassword: ' +
              _password; //body of the email

    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' +
          sendReport.toString()); //print if the email is sent
    } on MailerException catch (e) {
      print('Message not sent. \n' +
          e.toString()); //print if the email is not sent
      // e.toString() will show why the email is not sending
    }
  }
}
