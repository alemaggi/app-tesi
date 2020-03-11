import 'package:app_tesi/Recipe/singleRecipe.dart';
import 'package:app_tesi/Wrapper/wrapperForRecipeFilter.dart';
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
      //key: ValueKey(queryRecord.playerEmail),
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
              //TODO: Togliere tutti i valori e le dimensioni hard coded
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
                        Text("Durata: " + queryRecord.duration),
                      ],
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.favorite,
                        color: queryRecord.isFavorite
                            ? Colors.red
                            : Color.fromRGBO(230, 219, 221, 100),
                        size: 30,
                      ),
                      onPressed: queryRecord.isFavorite
                          ? () async {
                              final db = Firestore.instance;
                              await db
                                  .collection('recipes')
                                  .document(documnetId)
                                  .updateData({'isFavorite': false});
                            }
                          : () async {
                              final db = Firestore.instance;
                              await db
                                  .collection('recipes')
                                  .document(documnetId)
                                  .updateData({'isFavorite': true});
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
                  onPressed: () {},
                  child: Text(
                    "Antipasti",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                FlatButton(
                  onPressed: () {},
                  child: Text(
                    "Primi",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                FlatButton(
                  onPressed: () {},
                  child: Text(
                    "Secondi",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                FlatButton(
                  onPressed: () {},
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
            WrapperForRecipeFilter(soloPreferiti: soloPreferiti),
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
