import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../singleRecipe.dart';

class OnlyDessertRecipes extends StatefulWidget {
  @override
  _OnlyDessertRecipesState createState() => _OnlyDessertRecipesState();
}

class _OnlyDessertRecipesState extends State<OnlyDessertRecipes> {
  bool isLoaded = false;
  List<dynamic> favoriteRecipes;
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

  Widget _buildBody(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance
          .collection('recipes')
          .where('type', isEqualTo: 'Dessert')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return LinearProgressIndicator(
            backgroundColor: Colors.transparent,
          );
        return _buildList(context, snapshot.data.documents);
      },
    );
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    return ListView(
      padding: const EdgeInsets.only(top: 20.0),
      children: snapshot.map((data) => _buildListItem(context, data)).toList(),
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    final queryRecord = QueryRecord.fromSnapshot(data);
    String documnetId = data.documentID;

    return Container(
      child: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(15),
            margin: EdgeInsets.only(top: 10),
            width: MediaQuery.of(context).size.width * 0.9,
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
                  blurRadius: 5.0, // has the effect of softening the shadow
                  spreadRadius: 0.5, // has the effect of extending the shadow
                  offset: Offset(
                    2.0, // horizontal, move right 10
                    2.0, // vertical, move down 10
                  ),
                ),
              ],
              color: Colors.white,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          queryRecord.title,
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                          ),
                        ),
                        Row(
                          children: <Widget>[
                            Icon(
                              Icons.timer,
                              size: 18,
                            ),
                            Container(
                              margin: EdgeInsets.only(left: 5),
                              child: Text("Durata: " + queryRecord.duration),
                            ),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.favorite,
                        color: (favoriteRecipes.contains(documnetId))
                            ? Colors.red
                            : Color.fromRGBO(230, 219, 221, 100),
                        size: 30,
                      ),
                      onPressed: (favoriteRecipes.contains(documnetId))
                          ? () async {
                              var list = List<String>();
                              list.add(documnetId);
                              final db = Firestore.instance;
                              await db
                                  .collection('users')
                                  .document(user.uid)
                                  .updateData({
                                "favoriteRecipes": FieldValue.arrayRemove(list)
                              });
                              initState(); //TODO: Soluzione brutta e temporanea
                            }
                          : () async {
                              var list = List<String>();
                              list.add(documnetId);
                              final db = Firestore.instance;
                              await db
                                  .collection('users')
                                  .document(user.uid)
                                  .updateData({
                                "favoriteRecipes": FieldValue.arrayUnion(list)
                              });
                              initState(); //TODO: Soluzione brutta e temporanea
                            },
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      child: FlatButton(
                        color: Color.fromRGBO(255, 0, 87, 1),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SingleRecipe(
                                documentId: documnetId,
                                favoriteRecipes: favoriteRecipes,
                              ),
                            ),
                          );
                        },
                        child: Text(
                          "Vedi Ricetta Completa",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isLoaded
        ? Expanded(
            child: Container(
              child: _buildBody(context),
            ),
          )
        : CircularProgressIndicator(
            strokeWidth: 6.0,
            valueColor: AlwaysStoppedAnimation(Colors.transparent),
            value: 0,
          );
  }
}

class QueryRecord {
  final String title;
  final String duration;

  final DocumentReference reference;

  QueryRecord.fromMap(Map<String, dynamic> map, {this.reference})
      : title = map['title'],
        duration = map['duration'];

  QueryRecord.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  @override
  String toString() => "QueryRecord<$title:$duration>";
}
