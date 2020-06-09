import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:expandable_card/expandable_card.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:app_tesi/HomePage/food.dart';
import 'dart:math' as math;

class ShoppingList extends StatefulWidget {
  @override
  _ShoppingListState createState() => _ShoppingListState();
}

class _ShoppingListState extends State<ShoppingList> {
  List<dynamic> ingredients;
  bool isLoaded = false;
  var user;

  AutoCompleteTextField searchTextField;
  AutoCompleteTextField searchTextFieldTwo;
  TextEditingController controller = new TextEditingController();
  TextEditingController controllerTwo = new TextEditingController();
  GlobalKey<AutoCompleteTextFieldState<Alimento>> key = new GlobalKey();
  GlobalKey<AutoCompleteTextFieldState<Alimento>> keyTwo = new GlobalKey();
  List<String> _listOfIngredientsToAdd = [];
  final _addFoodToFridgeKey = GlobalKey<FormState>();
  String _nomeAlimentoDaAggiungereAlF;
  bool addedWithoutDupes = true;
  bool actionComplete = false;
  var notAddedList = List<String>();

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
            ingredients = data.documents[0].data['shoppingList'];
            print(ingredients);
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(233, 0, 45, 1),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text("La mia lista della spesa"),
      ),
      body: ExpandableCardPage(
        page: (isLoaded == true)
            ? Stack(
                children: <Widget>[
                  Center(
                    child: Column(
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(top: 5),
                          width: MediaQuery.of(context).size.width * 0.8,
                          height: MediaQuery.of(context).size.height * 0.75,
                          child: ListView.builder(
                            itemCount: ingredients.length,
                            itemBuilder: (BuildContext ctxt, int index) {
                              return Padding(
                                padding: const EdgeInsets.all(4),
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
                                          ingredients[index],
                                          style: TextStyle(fontSize: 22),
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete),
                                        color: Color.fromRGBO(233, 0, 45, 1),
                                        onPressed: () async {
                                          var list = List<String>();
                                          list.add(ingredients[index]);
                                          final db = Firestore.instance;
                                          await db
                                              .collection('users')
                                              .document(user.uid)
                                              .updateData({
                                            "shoppingList":
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
                        OutlineButton(
                          borderSide: BorderSide(
                              width: 2.0, color: Color.fromRGBO(233, 0, 45, 1)),
                          child: Text(
                            'Aggiugni tutti gli alimenti della lista al frigo',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: Color.fromRGBO(233, 0, 45, 1),
                            ),
                          ),
                          onPressed: () {
                            //TODO: Da fare
                          },
                        ),
                      ],
                    ),
                  )
                ],
              )
            : Center(
                child: Container(
                  height: 100,
                  width: 100,
                  margin: EdgeInsets.all(5),
                  child: CircularProgressIndicator(
                    strokeWidth: 6.0,
                    valueColor: AlwaysStoppedAnimation(
                      Color.fromRGBO(233, 0, 45, 1),
                    ),
                  ),
                ),
              ),
        expandableCard: ExpandableCard(
          backgroundColor: Color.fromRGBO(233, 0, 45, 1),
          minHeight: MediaQuery.of(context).size.height * 0.18,
          maxHeight: MediaQuery.of(context).size.height * 0.85,
          hasRoundedCorners: true,
          children: <Widget>[
            Column(
              children: <Widget>[
                Container(
                  child: Text(
                    "Aggiungi elementi alla tua lista della spesa",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  constraints: BoxConstraints(minWidth: 100, maxWidth: 500),
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
                    },
                  ),
                ),
                Container(
                  key: _addFoodToFridgeKey,
                  constraints: BoxConstraints(minWidth: 100, maxWidth: 475),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      new Column(
                        children: <Widget>[
                          searchTextField = AutoCompleteTextField<Alimento>(
                            suggestionsAmount: 4,
                            style: new TextStyle(
                              color: Colors.white,
                              fontSize: 24.0,
                            ),
                            submitOnSuggestionTap: true,
                            controller: controller,
                            decoration: new InputDecoration(
                              contentPadding:
                                  EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 20.0),
                              filled: true,
                              hintText: 'Inserisci un alimento',
                              hintStyle: TextStyle(
                                fontSize: 22,
                                color: Colors.white,
                              ),
                            ),
                            itemBuilder: (context, item) {
                              return Row(
                                children: <Widget>[
                                  Text(
                                    item.nome,
                                    style: TextStyle(fontSize: 20.0),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(15.0),
                                  ),
                                ],
                              );
                            },
                            itemFilter: (item, query) {
                              return item.nome
                                  .toLowerCase()
                                  .startsWith(query.toLowerCase());
                            },
                            itemSorter: (a, b) {
                              return a.nome.compareTo(b.nome);
                            },
                            itemSubmitted: (item) {
                              setState(() => searchTextField
                                  .textField.controller.text = item.nome);
                            },
                            key: key,
                            suggestions: foodList,
                            clearOnSubmit: false,
                          )
                        ],
                      ),
                      Container(
                        constraints:
                            BoxConstraints(minWidth: 100, maxWidth: 500),
                        margin: EdgeInsets.only(
                          top: MediaQuery.of(context).size.width * 0.1,
                        ),
                        width: MediaQuery.of(context).size.width * 0.8,
                        height: MediaQuery.of(context).size.width * 0.12,
                        child: FlatButton(
                          onPressed: () {
                            if (ingrCheckList.isEmpty) {
                              loadElementstoCheckList();
                            }
                            if (searchTextField
                                .textField.controller.text.isNotEmpty) {
                              String s =
                                  searchTextField.textField.controller.text;
                              s = s[0].toUpperCase() + s.substring(1);
                              if (ingrCheckList.contains(s)) {
                                _nomeAlimentoDaAggiungereAlF = s;
                                setState(() {
                                  _listOfIngredientsToAdd
                                      .add(_nomeAlimentoDaAggiungereAlF);
                                  controller.clear();
                                });
                              }
                            }
                          },
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(10.0),
                            side: BorderSide(
                              color: Color.fromRGBO(233, 0, 45, 1),
                              width: 3,
                            ),
                          ),
                          child: Text(
                            "Aggiungi alimento alla lista",
                            style: TextStyle(
                              fontSize: 24,
                              color: Color.fromRGBO(233, 0, 45, 1),
                            ),
                          ),
                        ),
                      ),
                      (_listOfIngredientsToAdd.isNotEmpty)
                          ? Container(
                              constraints:
                                  BoxConstraints(minWidth: 100, maxWidth: 500),
                              margin: EdgeInsets.only(
                                top: MediaQuery.of(context).size.width * 0.1,
                              ),
                              width: MediaQuery.of(context).size.width * 0.8,
                              height: MediaQuery.of(context).size.width * 0.12,
                              child: FlatButton(
                                shape: RoundedRectangleBorder(
                                  borderRadius: new BorderRadius.circular(10.0),
                                  side: BorderSide(
                                    color: Color.fromRGBO(233, 0, 45, 1),
                                    width: 3,
                                  ),
                                ),
                                color: Colors.white,
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
                                    if (ingredients != null) {
                                      //Controllo che gli elementi aggiunti non siano gia presenti nel frigo
                                      for (int i = 0; i < output.length; i++) {
                                        if (ingredients.contains(output[i])) {
                                          notAddedList.add(output[i]);
                                        }
                                      }
                                      for (String item in notAddedList) {
                                        output.remove(item);
                                      }
                                      print("Lista cose da non aggiungere :");
                                      print(notAddedList);
                                      if (notAddedList.length == 0) {
                                        addedWithoutDupes = true;
                                      } else {
                                        addedWithoutDupes = false;
                                      }
                                      Firestore.instance
                                          .collection('users')
                                          .document(user.uid)
                                          .updateData({
                                        "shoppingList":
                                            FieldValue.arrayUnion(output)
                                      });
                                      setState(() {
                                        actionComplete = true;
                                        _getUserInfo();
                                        _listOfIngredientsToAdd.clear();
                                      });
                                    } else {
                                      //Se il DB non contiene ingredienti li posso aggiungere senza problemi
                                      Firestore.instance
                                          .collection('users')
                                          .document(user.uid)
                                          .updateData({
                                        "shoppingList":
                                            FieldValue.arrayUnion(output)
                                      });
                                      setState(() {
                                        actionComplete = true;
                                        _listOfIngredientsToAdd.clear();
                                      });
                                    }
                                    //TODO: Far chiudere la card quando viene premuto il bottone
                                  }
                                },
                                child: Text(
                                  "Conferma",
                                  style: TextStyle(
                                    fontSize: 24,
                                    color: Color.fromRGBO(233, 0, 45, 1),
                                  ),
                                ),
                              ),
                            )
                          : Container(
                              height: 0,
                            ),
                      (actionComplete)
                          ? AlertDialog(
                              contentPadding: EdgeInsets.all(10.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              backgroundColor: Colors.white,
                              content: uploadMessage(),
                              actions: [
                                FlatButton(
                                  child: Text("Ok"),
                                  onPressed: () {
                                    notAddedList.clear();
                                    actionComplete = false;
                                    setState(() {});
                                  },
                                )
                              ],
                            )
                          : Container(),
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

  Widget uploadMessage() {
    print(addedWithoutDupes);
    if (!addedWithoutDupes) {
      return Column(children: <Widget>[
        Text(
          "I seguenti alimenti non sono stati aggiunti perchè già presenti nella lista della spesa :",
        ),
        for (var item in notAddedList) Text(item)
      ]);
    } else {
      return Column(children: <Widget>[
        Text(
            "Tutti gli ingredienti sono stati aggiunti alla tua lista della spesa")
      ]);
    }
  }
}
