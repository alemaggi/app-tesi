import 'package:app_tesi/HomePage/homepage.dart';
import 'package:app_tesi/Login/forgotPassword.dart';
import 'package:app_tesi/Services/auth.dart';
import 'package:app_tesi/Signup/signup.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  _setNewUserIntoFirestoreWhenUsingGoogleLogin(
      String userEmail, String uid) async {
    //Devo controlloare se l'utete ha già effettuato un accesso quindi controllo se ho la sua email in 'user'
    Firestore.instance
        .collection('users')
        .where('email', isEqualTo: userEmail)
        .snapshots()
        .listen((data) {
      if (data == null || data.documents.length == 0) {
        Firestore.instance.runTransaction((transaction) async {
          await transaction
              .set(Firestore.instance.collection("users").document(uid), {
            'email': userEmail,
            'name': 'Anonimo',
            'surname': 'Anonimo',
            'profilePicUrl':
                'https://firebasestorage.googleapis.com/v0/b/app-tesi-16e05.appspot.com/o/profilePic%2FgenericProfilePic.png?alt=media&token=d5710a15-35a7-42ff-9999-5c977f9325a9',
            'myFridge': [
              'Acqua',
            ],
            'allergens': [],
            'favoriteRecipes': [],
            'showRecipeWithAllergens': true,
          });
        });
      } else {
        print("Lo abbiamo gia nel DB");
      }
    });
  }

  //Form key --> Serve per validare gli input e procedere con il login
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();

  //Per autenticazione
  AuthService _auth = AuthService();

  bool isLogin = true;

  String _email;
  String _password;
  String error = ' ';

  bool showPassword = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            color: Color.fromRGBO(233, 0, 45, 1),
            height: MediaQuery.of(context).size.height * 0.5,
            child: Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.6,
                height: MediaQuery.of(context).size.width * 0.6,
                child: Image(
                  image: AssetImage("assets/Logo.png"),
                ),
                margin: EdgeInsets.only(
                    bottom: MediaQuery.of(context).size.width * 0.1),
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.6,
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
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(
                              top: MediaQuery.of(context).size.width * 0.04,
                            ),
                            width: MediaQuery.of(context).size.width * 0.8,
                            constraints:
                                BoxConstraints(minWidth: 100, maxWidth: 500),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  "Benvenuto",
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
                            constraints:
                                BoxConstraints(minWidth: 100, maxWidth: 500),
                            width: MediaQuery.of(context).size.width * 0.8,
                            child: Form(
                              key: _formKey,
                              child: Column(
                                children: <Widget>[
                                  TextFormField(
                                    keyboardType: TextInputType.emailAddress,
                                    controller: _controller,
                                    decoration: InputDecoration(
                                      hintText: "Email",
                                      prefixIcon: Icon(Icons.email),
                                    ),
                                    validator: (val) => val.isEmpty
                                        ? 'Inserisci la tua email'
                                        : null,
                                    onChanged: (val) {
                                      setState(() {
                                        _email = val.trim();
                                      });
                                    },
                                  ),
                                  Container(
                                    height: MediaQuery.of(context).size.width *
                                        0.05,
                                  ),
                                  TextFormField(
                                    keyboardType: TextInputType.text,
                                    obscureText: showPassword ? false : true,
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
                                    validator: (val) => val.length < 6
                                        ? 'Inserisci una password valida'
                                        : null,
                                    onChanged: (val) {
                                      setState(() {
                                        _password = val;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            constraints:
                                BoxConstraints(minWidth: 100, maxWidth: 500),
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
                            constraints: BoxConstraints(
                                minWidth: 100, maxWidth: 500, maxHeight: 75),
                            width: MediaQuery.of(context).size.width * 0.8,
                            height: MediaQuery.of(context).size.width * 0.12,
                            margin: EdgeInsets.only(
                              top: 10,
                            ),
                            child: FlatButton(
                              child: Text(
                                "Sign In",
                                style: TextStyle(
                                    color: Color.fromRGBO(233, 0, 45, 1),
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold),
                              ),
                              onPressed: () async {
                                setState(() {
                                  error =
                                      ''; //Cosi togliamo eventuali errori precedenti
                                });
                                if (_formKey.currentState.validate()) {
                                  dynamic result =
                                      await _auth.signinWithEmailAndPassword(
                                          _email, _password);
                                  if (result == null) {
                                    setState(() {
                                      error =
                                          'ERROR: Non ho potuto eseguire il login con queste credenziali';
                                    });
                                  }
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
                          FlatButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ForgotPassword(),
                                ),
                              );
                            },
                            child: Text(
                              "Password Dimenticata?",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                          Container(
                            child: OutlineButton(
                              splashColor: Colors.grey,
                              onPressed: () async {
                                dynamic result = await _auth.signInWithGoogle();
                                if (result != null) {
                                  print("Signed in");
                                  print("UID: " + result.uid);
                                  print(result.email);
                                  _setNewUserIntoFirestoreWhenUsingGoogleLogin(
                                      result.email, result.uid);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Homepage()),
                                  );
                                } else {
                                  setState(() {
                                    error = 'Error Sigin in con google';
                                  });
                                  print("Error Sigin in with google");
                                }
                              },
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(40),
                              ),
                              highlightElevation: 0,
                              borderSide: BorderSide(
                                width: 3,
                                color: Color.fromRGBO(233, 0, 45, 1),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Image(
                                        image: AssetImage(
                                            "assets/google_logo.png"),
                                        height: 25.0),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 10),
                                      child: Text(
                                        'Sign in con Google',
                                        style: TextStyle(
                                          fontSize: 20,
                                          color: Color.fromRGBO(233, 0, 45, 1),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Container(
                            constraints: BoxConstraints(
                                minWidth: 100, maxWidth: 500, maxHeight: 75),
                            width: MediaQuery.of(context).size.width * 0.8,
                            height: MediaQuery.of(context).size.width * 0.12,
                            margin: EdgeInsets.only(
                              top: MediaQuery.of(context).size.width * 0.03,
                            ),
                            child: FlatButton(
                              color: Color.fromRGBO(233, 0, 45, 1),
                              child: Text(
                                "Crea un Account",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 26,
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
                          /*
                          Container(
                            margin: EdgeInsets.only(
                                top: MediaQuery.of(context).size.width * 0.02),
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
                              onPressed: () async {
                                dynamic result = await _auth.signInAnon();
                                if (result != null) {
                                  print("Signed in");
                                  print(result.uid);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Homepage()),
                                  );
                                } else {
                                  print("Error Sigin in anon");
                                }
                              },
                              child: Text(
                                "Continue Without an Account",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                          */
                        ],
                      )
                    : Signup(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
