import 'package:app_tesi/Fridge/myFridge.dart';
import 'package:app_tesi/Profile/profile.dart';
import 'package:app_tesi/Recipe/allRecipeTemplate.dart';
import 'package:app_tesi/Services/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:expandable_card/expandable_card.dart';
import 'dart:math' as math;

import 'package:dio/dio.dart';

class Homepage extends StatefulWidget {
  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final TextEditingController _filter = new TextEditingController();
  final dio = new Dio();
  String _searchText = "";
  List names = new List();
  List filteredNames = new List();
  Icon _searchIcon = new Icon(Icons.search);
  Widget _appBarTitle = new Text('Search Example');
  final _addFoodToFridgeKey = GlobalKey<FormState>();
  String _nomeAlimentoDaAggiungereAlF;
  var user;
  List<dynamic> ingredients;
  List<String> _listOfIngredientsToAdd = [];
  final TextEditingController _controller = new TextEditingController();
  bool isLoaded = false;

  List<dynamic> recipes;

  _getUserFridge() async {
    user = await FirebaseAuth.instance.currentUser();
    var userQuery = Firestore.instance
        .collection('users')
        .where('email', isEqualTo: user.email)
        .limit(1);
    userQuery.getDocuments().then(
      (data) {
        if (data.documents.length > 0) {
          print(user.email);
          setState(() {
            ingredients = data.documents[0].data['myFridge'];
            print(ingredients);
            isLoaded = true;
          });
        }
      },
    );
  }

  @override
  void initState() {
    _getUserFridge();
    // _searchForPossibleRecipes(ingredients);
    super.initState();
  }

  Widget _buildBar(BuildContext context) {
    return AppBar(
      backgroundColor: Color.fromRGBO(255, 0, 87, 1),
      centerTitle: true,
      title: _appBarTitle,
      actions: <Widget>[
        IconButton(
          icon: _searchIcon,
          onPressed: _searchPressed,
        ),
      ],
    );
  }

  void _searchPressed() {
    setState(() {
      if (this._searchIcon.icon == Icons.search) {
        this._searchIcon = Icon(Icons.close);
        this._appBarTitle = TextField(
          controller: _filter,
          decoration: InputDecoration(
              prefixIcon: Icon(Icons.search), hintText: 'Search...'),
        );
      } else {
        this._searchIcon = Icon(Icons.search);
        this._appBarTitle = Text('Search Example');
        filteredNames = names;
        _filter.clear();
      }
    });
  }

  void _searchForPossibleRecipes(List<dynamic> ingredienti) {
    List<dynamic> _ingredientiDiUnaRicetta = ["Carote", "Piselli", "insalata"];

    for (var i = 0; i < _ingredientiDiUnaRicetta.length; i++) {
      if (!ingredienti.contains(_ingredientiDiUnaRicetta[i])) {
        print("Non posso fare sta ricetta");
      }
    }
    print("Posso fare sta ricetta");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildBar(context),
      drawer: NavDrawer(),
      body: ExpandableCardPage(
        page: Center(
          child: Text(
            "Lista di ricette",
            style: TextStyle(
              color: Colors.black,
              fontSize: 44,
            ),
          ),
        ),
        expandableCard: ExpandableCard(
          backgroundColor: Color.fromRGBO(255, 0, 87, 1),
          minHeight: MediaQuery.of(context).size.height * 0.18,
          maxHeight: MediaQuery.of(context).size.height * 0.7,
          hasRoundedCorners: true,
          children: <Widget>[
            Column(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(
                      bottom: MediaQuery.of(context).size.width * 0.01),
                  child: Text(
                    "Aggiungi elementi al tuo frigo",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                  height: 95,
                  child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _listOfIngredientsToAdd.length,
                      itemBuilder: (context, index) {
                        return Container(
                          child: Card(
                            color: Colors.transparent,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.only(left: 15),
                                  child: Center(
                                      child: Text(
                                    _listOfIngredientsToAdd[index].toString(),
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 26.0),
                                  )),
                                ),
                                IconButton(
                                    icon: Icon(
                                      Icons.delete,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _listOfIngredientsToAdd.removeAt(index);
                                      });
                                    }),
                              ],
                            ),
                          ),
                        );
                      }),
                ),
                Form(
                  key: _addFoodToFridgeKey,
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        keyboardType: TextInputType.text,
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: "Alimento da aggiungere",
                          hintStyle:
                              TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        validator: (val) =>
                            val.isEmpty ? 'Inserisci un alimento' : null,
                        onChanged: (val) {
                          setState(() {
                            _nomeAlimentoDaAggiungereAlF = val;
                          });
                        },
                      ),
                      Container(
                        margin: EdgeInsets.only(
                          top: MediaQuery.of(context).size.width * 0.1,
                        ),
                        color: Colors.white,
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: FlatButton(
                          onPressed: () {
                            if (_addFoodToFridgeKey.currentState.validate()) {
                              setState(() {
                                _listOfIngredientsToAdd
                                    .add(_nomeAlimentoDaAggiungereAlF);
                                _controller.clear();
                              });
                            }
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(10.0),
                            side: BorderSide(
                              color: Colors.white,
                              width: 3,
                            ),
                          ),
                          child: Text(
                            "Add Element To List",
                            style: TextStyle(
                              fontSize: 22,
                              color: Color.fromRGBO(255, 0, 87, 1),
                            ),
                          ),
                        ),
                      ),
                      (_listOfIngredientsToAdd.isNotEmpty)
                          ? Container(
                              margin: EdgeInsets.only(
                                top: MediaQuery.of(context).size.width * 0.1,
                              ),
                              color: Colors.white,
                              width: MediaQuery.of(context).size.width * 0.8,
                              child: FlatButton(
                                onPressed: () async {
                                  if (_listOfIngredientsToAdd.isNotEmpty) {
                                    var list = List<String>();

                                    List<String> output = Iterable.generate(
                                            math.max(list.length,
                                                _listOfIngredientsToAdd.length))
                                        .expand((i) sync* {
                                      if (i < list.length) yield list[i];
                                      if (i < _listOfIngredientsToAdd.length)
                                        yield _listOfIngredientsToAdd[i];
                                    }).toList();
                                    print(output);
                                    Firestore.instance
                                        .collection('users')
                                        .document(user.uid)
                                        .updateData({
                                      "myFridge": FieldValue.arrayUnion(output)
                                    });
                                    setState(() {
                                      _listOfIngredientsToAdd.clear();
                                    });

                                    //TODO: Far chiudere la card quando viene premuto il bottone
                                  }
                                },
                                child: Text(
                                  "Submit",
                                  style: TextStyle(
                                    fontSize: 22,
                                    color: Color.fromRGBO(255, 0, 87, 1),
                                  ),
                                ),
                              ),
                            )
                          : Container(
                              height: 0,
                            ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/*
* Side menu qui sotto
*/
class NavDrawer extends StatefulWidget {
  @override
  _NavDrawerState createState() => _NavDrawerState();
}

class _NavDrawerState extends State<NavDrawer> {
  var _url;
  String _name;
  String _surname;
  String _email;
  bool isLoaded = false;
  var user;

  _getUserInfo() async {
    user = await FirebaseAuth.instance.currentUser();
    var userQuery = Firestore.instance
        .collection('users')
        .where('email', isEqualTo: user.email)
        .limit(1);
    userQuery.getDocuments().then(
      (data) {
        if (data.documents.length > 0) {
          print(user.email);
          setState(() {
            _name = data.documents[0].data['name'];
            _surname = data.documents[0].data['surname'];
            _email = user.email;
            _url = data.documents[0].data['profilePicUrl'];
            isLoaded = true;
          });
        }
      },
    );
  }

  @override
  void initState() {
    _getUserInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final AuthService _auth = AuthService();
    return isLoaded
        ? Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                UserAccountsDrawerHeader(
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(255, 0, 87, 1),
                  ),
                  currentAccountPicture: CircleAvatar(
                    backgroundImage: NetworkImage(_url),
                  ),
                  accountName: Text(
                    _name + " " + _surname,
                  ),
                  accountEmail: Text(_email),
                ),
                ListTile(
                  title: Text('Profile'),
                  onTap: () => {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) {
                          return Profile();
                        },
                        transitionsBuilder:
                            (context, animation1, animation2, child) {
                          return FadeTransition(
                            opacity: animation1,
                            child: child,
                          );
                        },
                        transitionDuration: Duration(milliseconds: 20),
                      ),
                    ),
                  },
                ),
                ListTile(
                  title: Text('Il Mio Frigorifero'),
                  onTap: () => {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) {
                          return MyFridge();
                        },
                        transitionsBuilder:
                            (context, animation1, animation2, child) {
                          return FadeTransition(
                            opacity: animation1,
                            child: child,
                          );
                        },
                        transitionDuration: Duration(milliseconds: 20),
                      ),
                    ),
                  },
                ),
                ListTile(
                  title: Text('Tutte le ricette'),
                  onTap: () => {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) {
                          return AllRecipeTemplate();
                        },
                        transitionsBuilder:
                            (context, animation1, animation2, child) {
                          return FadeTransition(
                            opacity: animation1,
                            child: child,
                          );
                        },
                        transitionDuration: Duration(milliseconds: 20),
                      ),
                    ),
                  },
                ),
                ListTile(
                  title: Text('LogOut'),
                  onTap: () async {
                    await _auth.signout();
                  },
                ),
              ],
            ),
          )
        : CircularProgressIndicator(
            value: null,
            strokeWidth: 7.0,
            valueColor: AlwaysStoppedAnimation(Colors.transparent),
          );
  }
}
