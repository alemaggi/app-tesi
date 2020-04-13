import 'package:app_tesi/Recipe/singleRecipe.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class OnlyOneCategoryRecipe extends StatefulWidget {
  final int categoryToShow;

  OnlyOneCategoryRecipe({Key key, @required this.categoryToShow})
      : super(key: key);
  @override
  _OnlyOneCategoryRecipeState createState() => _OnlyOneCategoryRecipeState();
}

class _OnlyOneCategoryRecipeState extends State<OnlyOneCategoryRecipe> {
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

  //ALL RECIPES
  Widget _buildBody(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('recipes').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return LinearProgressIndicator(
            backgroundColor: Colors.transparent,
          );
        return _buildList(context, snapshot.data.documents);
      },
    );
  }

  //STARTED
  Widget _buildBodyStarter(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance
          .collection('recipes')
          .where('type', isEqualTo: 'Antipasto')
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

  //FIRST
  Widget _buildBodyFirst(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance
          .collection('recipes')
          .where('type', isEqualTo: 'Primo')
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

  //SECONDS
  Widget _buildBodySecond(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance
          .collection('recipes')
          .where('type', isEqualTo: 'Secondo')
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

  //DESSERT
  Widget _buildBodyDessert(BuildContext context) {
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

  //FAVORITES
  Widget _buildBodyFavorite(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('recipes').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return LinearProgressIndicator(
            backgroundColor: Colors.transparent,
            value: 0,
          );
        return _buildListOnlyFavorites(context, snapshot.data.documents);
      },
    );
  }

  Widget _buildListOnlyFavorites(
      BuildContext context, List<DocumentSnapshot> snapshot) {
    return ListView(
      padding: const EdgeInsets.only(top: 20.0),
      children: snapshot
          .map((data) => _buildListItemFavoriteRecipes(context, data))
          .toList(),
    );
  }

  //FAVORITES CUSTOM STUFF END

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
            constraints: BoxConstraints(minWidth: 100, maxWidth: 500),
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
                Container(
                  margin: EdgeInsets.only(
                      bottom: MediaQuery.of(context).size.width * 0.02),
                  height: MediaQuery.of(context).size.height * 0.2,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: NetworkImage(queryRecord.imageLink),
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    color: Colors.redAccent,
                  ),
                ),
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
                                title: queryRecord.title,
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

  //This is only for favorites
  Widget _buildListItemFavoriteRecipes(
      BuildContext context, DocumentSnapshot data) {
    final queryRecord = QueryRecord.fromSnapshot(data);
    String documnetId = data.documentID;

    return (favoriteRecipes.contains(documnetId))
        ? Container(
            child: Column(
              children: <Widget>[
                Container(
                  constraints: BoxConstraints(minWidth: 100, maxWidth: 475),
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
                  child: Column(
                    //TODO: Togliere tutti i valori e le dimensioni hard coded
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(
                            bottom: MediaQuery.of(context).size.width * 0.02),
                        height: MediaQuery.of(context).size.height * 0.2,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: NetworkImage(queryRecord.imageLink),
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                          color: Colors.redAccent,
                        ),
                      ),
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
                                    child:
                                        Text("Durata: " + queryRecord.duration),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.favorite,
                              color: Colors.red,
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
                                      "favoriteRecipes":
                                          FieldValue.arrayRemove(list)
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
                                      "favoriteRecipes":
                                          FieldValue.arrayUnion(list)
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
                                      title: queryRecord.title,
                                      favoriteRecipes: favoriteRecipes,
                                    ),
                                  ),
                                );
                              },
                              child: Text(
                                "Vedi Ricetta Completa",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16),
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
          )
        : Container(
            height: 0,
          );
  }

  @override
  Widget build(BuildContext context) {
    return isLoaded
        ? Expanded(
            child: Container(
              child: (widget.categoryToShow == 0)
                  ? _buildBody(context)
                  : (widget.categoryToShow == 1)
                      ? _buildBodyStarter(context)
                      : (widget.categoryToShow == 2)
                          ? _buildBodyFirst(context)
                          : (widget.categoryToShow == 3)
                              ? _buildBodySecond(context)
                              : (widget.categoryToShow == 4)
                                  ? _buildBodyDessert(context)
                                  : _buildBodyFavorite(context),
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
          );
  }
}

class QueryRecord {
  final String title;
  final String imageLink;
  final String duration;

  final DocumentReference reference;

  QueryRecord.fromMap(Map<String, dynamic> map, {this.reference})
      : title = map['title'],
        duration = map['duration'],
        imageLink = map['imageLink'];

  QueryRecord.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  @override
  String toString() => "QueryRecord<$title:$duration:$imageLink>";
}
