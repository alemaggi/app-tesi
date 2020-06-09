import 'package:app_tesi/HomePage/food.dart';
import 'package:app_tesi/HomePage/homepage.dart';
import 'package:app_tesi/Recipe/singleRecipe.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';

class AddToShoppingList extends StatefulWidget {
  List<dynamic> shoppingList;
  AddToShoppingList({Key key, @required this.shoppingList}) : super(key: key);
  @override
  _AddToShoppingListState createState() => _AddToShoppingListState();
}

class _AddToShoppingListState extends State<AddToShoppingList> {
  @override
  void initState() {
    loadElementstoCheckList();
    filterIngredientBeforeAddingToTheDB(widget.shoppingList, ingrCheckList);
    super.initState();
  }

  List<dynamic> elementToAddToShoppingListTmp = [];
  List<dynamic> elementToAddToShoppingListFinal = [];
  var notAddedList = List<String>();
  bool addedWithoutDupes = true;
  bool actionComplete = false;

  void filterIngredientBeforeAddingToTheDB(
      List<dynamic> shoppingList, List<dynamic> ingredientsList) {
    for (int i = 0; i < shoppingList.length; i++) {
      for (int k = 0; k < ingredientsList.length; k++) {
        if (shoppingList[i].contains(ingredientsList[k])) {
          if (!elementToAddToShoppingListTmp.contains(ingredientsList[k])) {
            print(shoppingList[i] + " Contiene " + ingredientsList[k]);
            elementToAddToShoppingListTmp.add(ingredientsList[k]);
          }
        }
      }
    }
    //TODO: Temporaneo
    for (int i = 0; i < elementToAddToShoppingListTmp.length - 1; i++) {
      if (elementToAddToShoppingListTmp[i]
          .contains(elementToAddToShoppingListTmp[i + 1])) {
        elementToAddToShoppingListTmp[i + 1] = "";
      }
    }
    setState(() {
      for (int i = 0; i < elementToAddToShoppingListTmp.length; i++) {
        if (elementToAddToShoppingListTmp[i] != "") {
          elementToAddToShoppingListFinal.add(elementToAddToShoppingListTmp[i]);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(233, 0, 45, 1),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            elementToAddToShoppingListFinal.clear();
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Aggiungi alla lista della spesa",
          style: TextStyle(fontSize: 24),
        ),
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Center(
              child: Text(
                widget.shoppingList.toString(),
              ),
            ),
            Center(
              child: Container(
                margin: EdgeInsets.only(top: 5),
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.7,
                child: ListView.builder(
                  itemCount: elementToAddToShoppingListFinal.length,
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.only(left: 10),
                              child: Text(
                                elementToAddToShoppingListFinal[index],
                                style: TextStyle(fontSize: 22),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              color: Color.fromRGBO(233, 0, 45, 1),
                              onPressed: () async {
                                setState(() {
                                  elementToAddToShoppingListFinal
                                      .removeAt(index);
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.8,
              child: Stack(
                children: <Widget>[
                  Center(
                    child: OutlineButton(
                      borderSide: BorderSide(
                          width: 2.0, color: Color.fromRGBO(233, 0, 45, 1)),
                      child: Text(
                        'Aggiungi alla listsa della spesa',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Color.fromRGBO(233, 0, 45, 1),
                        ),
                      ),
                      onPressed: () async {
                        var list = List<String>();

                        List<dynamic> output = Iterable.generate(math.max(
                                list.length,
                                elementToAddToShoppingListFinal.length))
                            .expand((i) sync* {
                          if (i < list.length) yield list[i];
                          if (i < elementToAddToShoppingListFinal.length)
                            yield elementToAddToShoppingListFinal[i];
                        }).toList();
                        if (shoppingList != null) {
                          //Controllo che gli elementi aggiunti non siano gia presenti nel frigo
                          for (int i = 0; i < output.length; i++) {
                            if (shoppingList.contains(output[i])) {
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

                          var user = await FirebaseAuth.instance.currentUser();
                          Firestore.instance
                              .collection('users')
                              .document(user.uid)
                              .updateData({
                            "shoppingList": FieldValue.arrayUnion(output)
                          });
                          setState(() {
                            actionComplete = true;
                          });
                        } else {
                          //Se il DB non contiene ingredienti li posso aggiungere senza problemi
                          var user = await FirebaseAuth.instance.currentUser();
                          Firestore.instance
                              .collection('users')
                              .document(user.uid)
                              .updateData({
                            "shoppingList": FieldValue.arrayUnion(output)
                          });
                          setState(() {
                            actionComplete = true;
                          });
                        }
                      },
                    ),
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
                                setState(() {
                                  notAddedList.clear();
                                  actionComplete = false;
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Homepage()),
                                  );
                                });
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
