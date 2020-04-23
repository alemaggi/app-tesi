import 'package:app_tesi/Wrapper/wrapperForIngredientsOrRecipes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:share/share.dart';

class SingleRecipe extends StatefulWidget {
  final String documentId;
  final String title;
  final List<dynamic> favoriteRecipes;

  SingleRecipe(
      {Key key,
      @required this.documentId,
      @required this.title,
      @required this.favoriteRecipes})
      : super(key: key);
  @override
  _SingleRecipeState createState() => _SingleRecipeState();
}

String _title;
String _duration;
List<dynamic> _ingredients;
List<dynamic> _preparation;
String _imageLink;
bool _isLoaded = false;
bool _showIngredients = true;
String _calories = "5"; //TODO: Prenderlo dal DB
String _doses = "6"; //TODO: Prenderlo dal DB
String _difficolta = "Facile"; //TODO: Prenderlo dal DB
var user;

class _SingleRecipeState extends State<SingleRecipe> {
  _getRecipe() async {
    user = await FirebaseAuth.instance.currentUser();
    Firestore.instance
        .collection('recipes')
        .document(widget.documentId)
        .get()
        .then(
      (data) {
        setState(() {
          _title = data['title'];
          _duration = data['duration'].toString();
          _ingredients = data['ingredients'];
          _preparation = data['preparation'];
          _imageLink = data['imageLink'];
          _isLoaded = true;
        });

        print(_title);
        print(_duration);
        print(_ingredients);
        print(_preparation);
      },
    );
  }

  @override
  void initState() {
    _getRecipe();
    super.initState();
  }

  void share(BuildContext context, String link) {
    final RenderBox box = context.findRenderObject();
    final String text = "${link}";

    Share.share(text,
        subject: "Prova questa ricetta",
        sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(255, 0, 87, 1),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            //TODO: Sistemare problema quando si apre la pagina
            _showIngredients = true;
            Navigator.pop(context);
          },
        ),
        title: Text(
          widget.title,
          style: TextStyle(fontSize: 24),
        ),
      ),
      body: _isLoaded
          ? Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                constraints: BoxConstraints(minWidth: 100, maxWidth: 500),
                padding:
                    EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Flexible(
                          child: Text(
                            _title,
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.share,
                            size: 28,
                          ),
                          onPressed: () {
                            share(context, _imageLink);
                          },
                        ),
                      ],
                    ),
                    Container(
                      margin: EdgeInsets.only(
                          top: MediaQuery.of(context).size.width * 0.02,
                          bottom: MediaQuery.of(context).size.width * 0.02),
                      height: MediaQuery.of(context).size.height * 0.2,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: NetworkImage(_imageLink),
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        color: Colors.redAccent,
                      ),
                    ),
                    Container(
                      constraints: BoxConstraints(minWidth: 100, maxWidth: 500),
                      margin: EdgeInsets.only(
                          top: MediaQuery.of(context).size.width * 0.01),
                      child: Table(
                        border: TableBorder.all(width: 4, color: Colors.grey),
                        children: [
                          TableRow(
                            children: [
                              TableCell(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Padding(
                                      padding: EdgeInsets.all(5),
                                      child: Icon(
                                        Icons.timer,
                                        color: Colors.black,
                                        size: 25,
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(5),
                                      child: Text(
                                        _duration + " minuti",
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              TableCell(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Padding(
                                      padding: EdgeInsets.all(5),
                                      child: Text(
                                        "Calorie: " + _calories,
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                          TableRow(
                            children: [
                              TableCell(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Padding(
                                      padding: EdgeInsets.all(5),
                                      child: Text(
                                        "Dosi per " + _doses,
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              TableCell(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: <Widget>[
                                    Padding(
                                      padding: EdgeInsets.all(5),
                                      child: Text(
                                        "Difficoltà: " + _difficolta,
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(
                          top: MediaQuery.of(context).size.width * 0.05),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          OutlineButton(
                            borderSide: BorderSide(
                                width: 2.0,
                                color: _showIngredients
                                    ? Color.fromRGBO(255, 0, 87, 1)
                                    : Colors.black),
                            child: Text(
                              'Ingredienti',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                                color: _showIngredients
                                    ? Color.fromRGBO(255, 0, 87, 1)
                                    : Colors.black,
                              ),
                            ),
                            onPressed: (() {
                              if (!_showIngredients) {
                                setState(() {
                                  _showIngredients = !_showIngredients;
                                });
                              }
                            }),
                          ),
                          OutlineButton(
                            borderSide: BorderSide(
                              width: 2.0,
                              color: _showIngredients
                                  ? Colors.black
                                  : Color.fromRGBO(255, 0, 87, 1),
                            ),
                            child: Text(
                              'Preparazione',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                                color: _showIngredients
                                    ? Colors.black
                                    : Color.fromRGBO(255, 0, 87, 1),
                              ),
                            ),
                            onPressed: (() {
                              if (_showIngredients) {
                                setState(() {
                                  _showIngredients = !_showIngredients;
                                });
                              }
                            }),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: MediaQuery.of(context).size.width * 0.02,
                    ),
                    Container(
                      child: Expanded(
                        child: WrapperForIngredientsOrRecipes(
                            ingredients: _ingredients,
                            preparation: _preparation,
                            showIngredients: _showIngredients),
                      ),
                    ),
                    Container(
                      height: MediaQuery.of(context).size.width * 0.02,
                    ),
                  ],
                ),
              ),
            )
          : Center(
              child: Container(
                height: 100,
                width: 100,
                margin: EdgeInsets.all(5),
                child: CircularProgressIndicator(
                  strokeWidth: 6.0,
                  valueColor: AlwaysStoppedAnimation(
                    Color.fromRGBO(255, 0, 87, 1),
                  ),
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        elevation: 6,
        child: Icon(
          Icons.favorite,
          color: (widget.favoriteRecipes.contains(widget.documentId))
              ? Colors.red
              : Color.fromRGBO(230, 219, 221, 100),
          size: 36,
        ),
        onPressed: (widget.favoriteRecipes.contains(widget.documentId))
            ? () async {
                var list = List<String>();
                list.add(widget.documentId);
                final db = Firestore.instance;
                await db.collection('users').document(user.uid).updateData(
                    {"favoriteRecipes": FieldValue.arrayRemove(list)});
                setState(() {
                  widget.favoriteRecipes.remove(widget.documentId);
                });
              }
            : () async {
                var list = List<String>();
                list.add(widget.documentId);
                final db = Firestore.instance;
                await db.collection('users').document(user.uid).updateData(
                    {"favoriteRecipes": FieldValue.arrayUnion(list)});
                setState(() {
                  widget.favoriteRecipes.add(widget.documentId);
                });
              },
      ),
    );
  }
}
