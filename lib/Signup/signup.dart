import 'package:app_tesi/HomePage/homepage.dart';
import 'package:app_tesi/Login/login.dart';
import 'package:app_tesi/Services/auth.dart';
import 'package:app_tesi/Wrapper/wrapperForFirstPage.dart';
import 'package:flutter/material.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Signup extends StatefulWidget {
  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final _signupFormKey = GlobalKey<FormState>();
  //Per autenticazione
  final AuthService _auth = AuthService();

  String _email;
  String _password;
  String _confirmPassword;
  String error = "";

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(50),
          topRight: Radius.circular(50),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(
                top: MediaQuery.of(context).size.width * 0.1,
                bottom: MediaQuery.of(context).size.width * 0.08),
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
            child: Form(
              key: _signupFormKey,
              child: Column(
                children: <Widget>[
                  TextFormField(
                    keyboardType: TextInputType.text,
                    controller: null, //TODO: Fare controller
                    decoration: InputDecoration(
                      hintText: "Email",
                      prefixIcon: Icon(Icons.email),
                    ),
                    validator: (val) =>
                        val.length < 6 ? 'Enter a valid email' : null,
                    onChanged: (val) {
                      setState(() {
                        _email = val;
                      });
                    },
                  ),
                  Container(
                    height: MediaQuery.of(context).size.width * 0.05,
                  ),
                  TextFormField(
                    keyboardType: TextInputType.text,
                    controller: null, //TODO: Fare controller
                    obscureText: true,
                    decoration: InputDecoration(
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
                    controller: null, //TODO: Fare controller
                    obscureText: true,
                    decoration: InputDecoration(
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
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.width * 0.12,
            margin: EdgeInsets.only(
              top: MediaQuery.of(context).size.width * 0.1,
            ),
            child: FlatButton(
              child: Text(
                "Sign Up",
                style: TextStyle(
                    color: Color.fromRGBO(255, 0, 87, 1),
                    fontSize: 22,
                    fontWeight: FontWeight.bold),
              ),
              onPressed: () async {
                if (_signupFormKey.currentState.validate()) {
                  if (_password == _confirmPassword) {
                    print(_email);
                    print(_password);
                    dynamic result = await _auth.registerWithEmailAndPassword(
                        _email, _password);
                    if (result == null) {
                      setState(() {
                        error = 'supply a valid email and password';
                      });
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Homepage()),
                      );
                    }
                  } else {
                    print("Le password non metchano");
                  }
                } else {
                  print("Some fields are not valid");
                }
              },
              shape: RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(10.0),
                side: BorderSide(
                  color: Color.fromRGBO(255, 0, 87, 1),
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
          Container(
            margin:
                EdgeInsets.only(top: MediaQuery.of(context).size.width * 0.02),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                FlatButton.icon(
                  label: Text('Signup with\n' + 'Facebook'),
                  onPressed: () {},
                  icon: FaIcon(
                    FontAwesomeIcons.facebook,
                    size: 32,
                  ),
                ),
                FlatButton.icon(
                  label: Text('Signup with\n' + 'Google'),
                  onPressed: () {},
                  icon: FaIcon(
                    FontAwesomeIcons.googlePlus,
                    size: 32,
                  ),
                ),
              ],
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
}
