import 'package:app_tesi/Profile/editProfile.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math' as math;

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  var _url;
  String _name;
  String _surname;
  String _email;
  List<dynamic> _allergens;
  bool isLoaded = false;
  var user;
  bool showRecipeImAllergicTo = false;

  final _addAllergensKey = GlobalKey<FormState>();
  List<String> _listOfAllergensToAdd = [];
  String _allergenName;
  final TextEditingController _controller = new TextEditingController();

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
            _allergens = data.documents[0].data['allergens'];
            showRecipeImAllergicTo =
                data.documents[0].data['showRecipeWithAllergens'];
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

  Future<void> _refreshRecipes() async {
    initState();
  }

  @override
  Widget build(BuildContext context) {
    return isLoaded
        ? Scaffold(
            appBar: AppBar(
              backgroundColor: Color.fromRGBO(255, 0, 87, 1),
              title: Text(
                "Profile",
                style: TextStyle(fontSize: 24),
              ),
              leading: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) {
                          return EditProfile();
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
                    );
                  },
                )
              ],
            ),
            body: Center(
              child: Column(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(
                        top: MediaQuery.of(context).size.width * 0.05,
                        bottom: MediaQuery.of(context).size.width * 0.02),
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "Your Profile",
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
                    margin: EdgeInsets.only(
                        bottom: MediaQuery.of(context).size.width * 0.05),
                    width: MediaQuery.of(context).size.width * 0.4,
                    height: MediaQuery.of(context).size.width * 0.4,
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(_url),
                    ),
                  ),
                  Text(
                    _name + " " + _surname,
                    style: TextStyle(fontSize: 22),
                  ),
                  Text(
                    _email,
                    style: TextStyle(fontSize: 22),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                        top: MediaQuery.of(context).size.width * 0.05),
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "Intolleranze & Allergie",
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                        top: MediaQuery.of(context).size.width * 0.01,
                        bottom: MediaQuery.of(context).size.width * 0.01),
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Flexible(
                          child: Text(
                            "Mostra ricette che contengono i miei allergeni",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                        ),
                        Switch(
                          value: showRecipeImAllergicTo,
                          onChanged: (value) async {
                            setState(() {
                              showRecipeImAllergicTo = value;
                            });
                            final db = Firestore.instance;
                            await db
                                .collection('users')
                                .document(user.uid)
                                .updateData({"showRecipeWithAllergens": value});
                          },
                          activeTrackColor: Color.fromRGBO(255, 0, 87, 100),
                          activeColor: Color.fromRGBO(255, 0, 87, 1),
                        ),
                      ],
                    ),
                  ),
                  Center(
                    child: RefreshIndicator(
                      onRefresh: _refreshRecipes,
                      child: Container(
                        height: 300,
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: ListView.builder(
                          itemCount: _allergens.length,
                          itemBuilder: (BuildContext ctxt, int index) {
                            return Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Container(
                                decoration: new BoxDecoration(
                                  borderRadius: new BorderRadius.only(
                                    topLeft: const Radius.circular(10.0),
                                    topRight: const Radius.circular(10.0),
                                    bottomLeft: const Radius.circular(10.0),
                                    bottomRight: const Radius.circular(10.0),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color.fromRGBO(0, 0, 0, 200),
                                      blurRadius:
                                          5.0, // has the effect of softening the shadow
                                      spreadRadius:
                                          0.5, // has the effect of extending the shadow
                                      offset: Offset(
                                        2.0, // horizontal, move right 10
                                        2.0, // vertical, move down 10
                                      ),
                                    ),
                                  ],
                                  color: Colors.white,
                                ),
                                margin: EdgeInsets.only(top: 5, bottom: 5),
                                padding: EdgeInsets.all(5),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Container(
                                      margin: EdgeInsets.only(left: 10),
                                      child: Text(
                                        _allergens[index],
                                        style: TextStyle(fontSize: 22),
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete),
                                      color: Colors.red,
                                      onPressed: () async {
                                        var list = List<String>();
                                        list.add(_allergens[index]);
                                        final db = Firestore.instance;
                                        await db
                                            .collection('users')
                                            .document(user.uid)
                                            .updateData({
                                          "allergens":
                                              FieldValue.arrayRemove(list)
                                        });
                                        initState(); //TODO: Soluzione brutta e temporanea
                                      },
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton(
              backgroundColor: Colors.white,
              elevation: 6,
              child: Icon(
                Icons.add,
                color: Color.fromRGBO(255, 0, 87, 1),
                size: 36,
              ),
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (_) {
                      return MyDialog();
                    });
              },
            ),
          )
        : Container(
            height: 20,
            width: 20,
            margin: EdgeInsets.all(5),
            child: CircularProgressIndicator(
              strokeWidth: 6.0,
              valueColor: AlwaysStoppedAnimation(Colors.transparent),
              value: 0,
            ),
          );
  }
}

class MyDialog extends StatefulWidget {
  @override
  _MyDialogState createState() => new _MyDialogState();
}

class _MyDialogState extends State<MyDialog> {
  final _addAllergensKey = GlobalKey<FormState>();
  List<String> _listOfAllergensToAdd = [];
  String _allergenName;
  final TextEditingController _controller = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Aggiungi Allergeni',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Column(
        children: <Widget>[
          Container(
            width: double.maxFinite,
            height: 45.0,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _listOfAllergensToAdd.length,
              itemBuilder: (context, index) {
                return Container(
                  height: 30,
                  child: Card(
                    color: Colors.transparent,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(left: 15),
                          child: Center(
                              child: Text(
                            _listOfAllergensToAdd[index].toString(),
                            style:
                                TextStyle(color: Colors.white, fontSize: 26.0),
                          )),
                        ),
                        IconButton(
                            icon: Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              setState(() {
                                _listOfAllergensToAdd.removeAt(index);
                              });
                            }),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Form(
            key: _addAllergensKey,
            child: Column(
              children: <Widget>[
                TextFormField(
                  keyboardType: TextInputType.text,
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: "Alimento da aggiungere",
                    hintStyle: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  validator: (val) =>
                      val.isEmpty ? 'Inserisci un alimento' : null,
                  onChanged: (val) {
                    setState(() {
                      _allergenName = val;
                    });
                  },
                ),
                Container(
                  margin: EdgeInsets.only(
                    top: MediaQuery.of(context).size.width * 0.1,
                  ),
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.width * 0.12,
                  child: FlatButton(
                    onPressed: () {
                      if (_addAllergensKey.currentState.validate()) {
                        setState(() {
                          _listOfAllergensToAdd.add(_allergenName);
                          _controller.clear();
                        });
                      }
                    },
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(10.0),
                      side: BorderSide(
                        color: Color.fromRGBO(255, 0, 87, 1),
                        width: 3,
                      ),
                    ),
                    child: Text(
                      "Add Element To List",
                      style: TextStyle(
                        fontSize: 24,
                        color: Color.fromRGBO(255, 0, 87, 1),
                      ),
                    ),
                  ),
                ),
                (_listOfAllergensToAdd.isNotEmpty)
                    ? Container(
                        margin: EdgeInsets.only(
                          top: MediaQuery.of(context).size.width * 0.1,
                        ),
                        width: MediaQuery.of(context).size.width * 0.8,
                        height: MediaQuery.of(context).size.width * 0.12,
                        child: FlatButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(10.0),
                            side: BorderSide(
                              color: Color.fromRGBO(255, 0, 87, 1),
                              width: 3,
                            ),
                          ),
                          color: Colors.white,
                          onPressed: () async {
                            if (_listOfAllergensToAdd.isNotEmpty) {
                              var list = List<String>();
                              var user =
                                  await FirebaseAuth.instance.currentUser();
                              List<String> output = Iterable.generate(math.max(
                                      list.length,
                                      _listOfAllergensToAdd.length))
                                  .expand((i) sync* {
                                if (i < list.length) yield list[i];
                                if (i < _listOfAllergensToAdd.length)
                                  yield _listOfAllergensToAdd[i];
                              }).toList();
                              print(output);
                              Firestore.instance
                                  .collection('users')
                                  .document(user.uid)
                                  .updateData({
                                "allergens": FieldValue.arrayUnion(output)
                              });
                              setState(() {
                                _listOfAllergensToAdd.clear();
                              });
                              Navigator.pop(context);
                            }
                          },
                          child: Text(
                            "Submit",
                            style: TextStyle(
                              fontSize: 24,
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
    );
  }
}
