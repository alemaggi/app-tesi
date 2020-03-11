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
bool isLoaded = false;

class _SingleRecipeState extends State<SingleRecipe> {
  _getRecipe() async {
    var query = Firestore.instance
        .collection('recipes')
        .document(widget.documentId)
        .get()
        .then(
      (data) {
        _title = data['title'];

        _duration = data['duration'];
        _ingredients = data['ingredients'];
        _preparation = data['preparation'];
        print(_title);
        print(_duration);
        print(_ingredients);
        print(_preparation);
        isLoaded = true;
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
      ),
      body: isLoaded
          ? Container(
              child: Column(
                children: <Widget>[
                  Text(
                    _title,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
