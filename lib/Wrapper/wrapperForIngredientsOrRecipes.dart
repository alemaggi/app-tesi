import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class WrapperForIngredientsOrRecipes extends StatefulWidget {
  List<dynamic> ingredients;
  List<dynamic> preparation;
  bool showIngredients;

  WrapperForIngredientsOrRecipes(
      {Key key,
      @required this.ingredients,
      @required this.preparation,
      @required this.showIngredients})
      : super(key: key);
  @override
  _WrapperForIngredientsOrRecipesState createState() =>
      _WrapperForIngredientsOrRecipesState();
}

class _WrapperForIngredientsOrRecipesState
    extends State<WrapperForIngredientsOrRecipes> {
  var user;

  List<dynamic> userIngredients;
  bool isLoaded = false;

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
            userIngredients = data.documents[0].data['myFridge'];
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
    return Material(
      child: isLoaded
          ? Container(
              child: widget.showIngredients
                  ? Container(
                      margin: EdgeInsets.only(top: 5),
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: ListView.builder(
                        itemCount: widget.ingredients.length,
                        itemBuilder: (BuildContext ctxt, int index) {
                          return Container(
                            margin: EdgeInsets.only(top: 3, bottom: 3),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                (userIngredients
                                        .contains(widget.ingredients[index]))
                                    ? Icon(
                                        Icons.check,
                                        size: 32,
                                      )
                                    : Icon(
                                        Icons.block,
                                        size: 32,
                                      ),
                                Container(
                                  margin: EdgeInsets.only(left: 10),
                                  child: Text(
                                    widget.ingredients[index],
                                    style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    )
                  : Container(
                      margin: EdgeInsets.only(top: 5),
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: ListView.builder(
                        itemCount: widget.preparation.length,
                        itemBuilder: (BuildContext ctxt, int index) {
                          return Padding(
                            padding: const EdgeInsets.all(3),
                            child: Container(
                              margin: EdgeInsets.only(top: 3, bottom: 3),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    child: Expanded(
                                      child: Text(
                                        (index + 1).toString() +
                                            ". " +
                                            widget.preparation[index],
                                        style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            )
          : CircularProgressIndicator(
              strokeWidth: 6.0,
              valueColor: AlwaysStoppedAnimation(Colors.transparent),
            ),
    );
  }
}
