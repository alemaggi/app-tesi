import 'package:app_tesi/Recipe/singleRecipe.dart';
import 'package:app_tesi/Wrapper/wrapperForRecipeFilter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AllRecipeTemplate extends StatefulWidget {
  @override
  _AllRecipeTemplateState createState() => _AllRecipeTemplateState();
}

class _AllRecipeTemplateState extends State<AllRecipeTemplate> {
  bool soloAntipasti = false;
  bool soloPrimi = false;
  bool soloSecondi = false;
  //I primi tre vediamo se farli o no
  bool soloPreferiti = false;

  var typeOfRecipeSelected =
      0; //0 = Nessuno, 1 = Antipasti, 2 = Secondi, 3 = Dolci

  //Questo mi serve per avere la lista delle ricette preferite
  List<dynamic> favoriteRecipes;
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
            favoriteRecipes = data.documents[0].data['favoriteRecipes'];
            print(favoriteRecipes);
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text("Tutte Le Ricette"),
      ),
      body: Container(
        margin: EdgeInsets.only(top: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                FlatButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(10.0),
                  ),
                  color: (typeOfRecipeSelected == 1)
                      ? Color.fromRGBO(255, 0, 87, 1)
                      : Color.fromRGBO(230, 219, 221, 100),
                  onPressed: (typeOfRecipeSelected != 1)
                      ? () {
                          setState(() {
                            typeOfRecipeSelected = 1;
                          });
                        }
                      : () {
                          setState(() {
                            typeOfRecipeSelected = 0;
                          });
                        },
                  child: Text(
                    "Antipasti",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                FlatButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(10.0),
                  ),
                  color: (typeOfRecipeSelected == 2)
                      ? Color.fromRGBO(255, 0, 87, 1)
                      : Color.fromRGBO(230, 219, 221, 100),
                  onPressed: () {
                    setState(() {
                      typeOfRecipeSelected = 2;
                    });
                  },
                  child: Text(
                    "Primi",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                FlatButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(10.0),
                  ),
                  color: (typeOfRecipeSelected == 3)
                      ? Color.fromRGBO(255, 0, 87, 1)
                      : Color.fromRGBO(230, 219, 221, 100),
                  onPressed: () {
                    setState(() {
                      typeOfRecipeSelected = 3;
                    });
                  },
                  child: Text(
                    "Secondi",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                FlatButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(10.0),
                  ),
                  color: (typeOfRecipeSelected == 4)
                      ? Color.fromRGBO(255, 0, 87, 1)
                      : Color.fromRGBO(230, 219, 221, 100),
                  onPressed: () {
                    setState(() {
                      typeOfRecipeSelected = 4;
                    });
                  },
                  child: Text(
                    "Dolci",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                FlatButton(
                  color: soloPreferiti
                      ? Color.fromRGBO(255, 0, 87, 1)
                      : Color.fromRGBO(230, 219, 221, 100),
                  onPressed: () {
                    setState(() {
                      soloPreferiti = !soloPreferiti;
                    });
                  },
                  child: Text(
                    "Mostra Solo Preferiti",
                    style: TextStyle(
                        fontSize: 18,
                        color: soloPreferiti ? Colors.white : Colors.black),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(10.0),
                  ),
                ),
              ],
            ),
            WrapperForRecipeFilter(
              soloPreferiti: soloPreferiti,
              typeOfRecipeSelected: typeOfRecipeSelected,
            ),
          ],
        ),
      ),
    );
  }
}

class QueryRecord {
  final String title;
  final String duration;
  final bool isFavorite;

  final DocumentReference reference;

  QueryRecord.fromMap(Map<String, dynamic> map, {this.reference})
      : title = map['title'],
        duration = map['duration'],
        isFavorite = map['isFavorite'];

  QueryRecord.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  @override
  String toString() => "QueryRecord<$title:$duration:$isFavorite>";
}
