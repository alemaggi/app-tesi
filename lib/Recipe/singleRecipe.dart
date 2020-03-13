import 'package:app_tesi/Wrapper/wrapperForRecipeFilter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SingleRecipe extends StatefulWidget {
  final String documentId;

  SingleRecipe({Key key, @required this.documentId}) : super(key: key);
  @override
  _SingleRecipeState createState() => _SingleRecipeState();
}

String _title;
String _duration;
List<dynamic> _ingredients;
List<dynamic> _preparation;
bool _isLoaded = false;

class _SingleRecipeState extends State<SingleRecipe> {
  _getRecipe() async {
    Firestore.instance
        .collection('recipes')
        .document(widget.documentId)
        .get()
        .then(
      (data) {
        setState(() {
          _title = data['title'];
          _duration = data['duration'];
          _ingredients = data['ingredients'];
          _preparation = data['preparation'];
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            //TODO: Sistemare problema quando si apre la pagina
            Navigator.pop(context);
          },
        ),
        title: Text("Ricetta"),
      ),
      body: _isLoaded
          ? Container(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    _title,
                    style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Tempo di preparazione: " + _duration,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Ingredienti",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Container(
                    height: 100, //TODO: Soluzione vera
                    child: ListView.builder(
                      itemCount: _ingredients.length,
                      itemBuilder: (BuildContext ctxt, int index) {
                        return Container(
                          margin: EdgeInsets.only(top: 5, bottom: 5),
                          padding: EdgeInsets.all(5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.only(left: 10),
                                child: Text(
                                  _ingredients[index],
                                  style: TextStyle(fontSize: 22),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  Text(
                    "Passaggi Preparazione",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Container(
                    height: 200, //TODO: Soluzione vera da troavre
                    child: ListView.builder(
                      itemCount: _preparation.length,
                      itemBuilder: (BuildContext ctxt, int index) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              height: 35,
                              width: MediaQuery.of(context).size.width,
                              margin: EdgeInsets.only(top: 5, bottom: 5),
                              padding: EdgeInsets.all(5),
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.9,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    ((index + 1).toString() +
                                        ". " +
                                        _preparation[index]),
                                    style: TextStyle(fontSize: 22),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            )
          : CircularProgressIndicator(
              strokeWidth: 6.0,
              valueColor: AlwaysStoppedAnimation(Colors.transparent),
              value: 0,
            ),
    );
  }
}
