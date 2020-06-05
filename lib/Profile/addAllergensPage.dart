import 'package:app_tesi/Profile/profile.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math' as math;
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import './../HomePage/food.dart';

class AddAllergenesPage extends StatefulWidget {
  @override
  _AddAllergenesPageState createState() => _AddAllergenesPageState();
}

class _AddAllergenesPageState extends State<AddAllergenesPage> {
  AutoCompleteTextField searchTextField;
  TextEditingController controller = new TextEditingController();
  GlobalKey<AutoCompleteTextFieldState<Alimento>> key = new GlobalKey();
  List names = new List();
  List filteredNames = new List();
  final _addFoodToFridgeKey = GlobalKey<FormState>();
  String _nomeAlimentoDaAggiungereAlF;
  var user;
  List<dynamic> favoriteRecipes;
  List<dynamic> ingredients;
  List<String> _listOfIngredientsToAdd = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Aggiungi Allergeni"),
        backgroundColor: Color.fromRGBO(233, 0, 45, 1),
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              height: 100,
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
                                  color: Color.fromRGBO(233, 0, 45, 1),
                                  fontSize: 26.0),
                            )),
                          ),
                          IconButton(
                              icon: Icon(
                                Icons.delete,
                                color: Color.fromRGBO(233, 0, 45, 1),
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
                          color: Color.fromRGBO(233, 0, 45, 1),
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
                            color: Color.fromRGBO(233, 0, 45, 1),
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
                    constraints: BoxConstraints(minWidth: 100, maxWidth: 500),
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
                          String s = searchTextField.textField.controller.text;
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
                                user =
                                    await FirebaseAuth.instance.currentUser();
                                Firestore.instance
                                    .collection('users')
                                    .document(user.uid)
                                    .updateData({
                                  "allergens": FieldValue.arrayUnion(output)
                                });
                                setState(() {
                                  _listOfIngredientsToAdd.clear();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Profile()),
                                  );
                                });
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
