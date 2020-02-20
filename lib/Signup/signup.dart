import 'package:app_tesi/Login/login.dart';
import 'package:flutter/material.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Signup extends StatefulWidget {
  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final _signupFormKey = GlobalKey<FormState>();

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
              onPressed: () {},
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
          Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.width * 0.12,
            margin: EdgeInsets.only(
              top: MediaQuery.of(context).size.width * 0.03,
            ),
            child: FlatButton(
              color: Color.fromRGBO(255, 0, 87, 1),
              child: Text(
                "Go Back (Poi lo togliamo)", //TODO: Toglerlo
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Login()),
                );
              },
              shape: RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(10.0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
