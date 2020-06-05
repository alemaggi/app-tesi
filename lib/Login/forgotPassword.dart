import 'package:app_tesi/Login/login.dart';
import 'package:flutter/material.dart';
import 'package:app_tesi/Services/auth.dart';

class ForgotPassword extends StatefulWidget {
  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final _formKey = GlobalKey<FormState>();
  String _email;
  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              child: Text(
                "Forgot Password?",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 20),
              //TODO: Fare in modo che resti bella anche su altri devices
              child: Image(image: AssetImage('assets/forgotPassword.png')),
            ),
            Container(
              margin: EdgeInsets.only(top: 40),
              width: MediaQuery.of(context).size.width * 0.7,
              constraints: BoxConstraints(minWidth: 100, maxWidth: 475),
              child: Text(
                "Enter the email address associated with your account",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 20),
              width: MediaQuery.of(context).size.width * 0.7,
              constraints: BoxConstraints(minWidth: 100, maxWidth: 475),
              child: Text(
                "We will email you a link to reset your password",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w300,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.8,
              constraints: BoxConstraints(minWidth: 100, maxWidth: 500),
              margin: EdgeInsets.only(top: 40),
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: "Inserisci un Indirizzo Email",
                        hintStyle: TextStyle(fontSize: 24),
                      ),
                      style: TextStyle(
                        fontSize: 24,
                      ),
                      textAlign: TextAlign.center,
                      validator: (val) =>
                          val.isEmpty ? 'Inserisci un email' : null,
                      onChanged: (val) {
                        setState(() {
                          _email = val.trim();
                        });
                      },
                    ),
                  ],
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
                color: Color.fromRGBO(233, 0, 45, 1),
                child: Text(
                  "Invia",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold),
                ),
                onPressed: () async {
                  _auth.sendPasswordResetEmail(_email);
                },
                shape: RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(10.0),
                ),
              ),
            ),
            FlatButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Login(),
                  ),
                );
              },
              child: Text(
                "Torna Indietro",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
