import 'package:app_tesi/HomePage/homepage.dart';
import 'package:app_tesi/Signup/signup.dart';
import 'package:flutter/material.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  //Form key --> Serve per validare gli input e procedere con il login
  final _formKey = GlobalKey<FormState>();

  bool isLogin = true;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        color: Color.fromRGBO(255, 0, 87, 1),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
              ),
              child: isLogin
                  ? Column(
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
                                "Welcome",
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
                            key: _formKey,
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
                                  height:
                                      MediaQuery.of(context).size.width * 0.05,
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
                              "Sign In",
                              style: TextStyle(
                                  color: Color.fromRGBO(255, 0, 87, 1),
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Homepage()),
                              );
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
                        FlatButton(
                          onPressed: () {},
                          child: Text(
                            "Forgot Password?",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                        Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              FlatButton.icon(
                                label: Text('Login with\n' + 'Facebook'),
                                onPressed: () {},
                                icon: FaIcon(
                                  FontAwesomeIcons.facebook,
                                  size: 32,
                                ),
                              ),
                              FlatButton.icon(
                                label: Text('Login with\n' + 'Google'),
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
                            top: MediaQuery.of(context).size.width * 0.04,
                          ),
                          child: FlatButton(
                            color: Color.fromRGBO(255, 0, 87, 1),
                            child: Text(
                              "Create an Account",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold),
                            ),
                            onPressed: () {
                              setState(() {
                                isLogin = false;
                              });
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(10.0),
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(
                              top: MediaQuery.of(context).size.width * 0.04),
                          child: Text(
                            "Or",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Container(
                          child: FlatButton(
                            onPressed: () {},
                            child: Text(
                              "Continue Without an Account",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Signup(),
            ),
          ],
        ),
      ),
    );
  }
}
