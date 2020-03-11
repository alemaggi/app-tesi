import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyFridge extends StatefulWidget {
  @override
  _MyFridgeState createState() => _MyFridgeState();
}

class _MyFridgeState extends State<MyFridge> {
  var user;

  List<dynamic> ingredients;
  bool isLoaded = false;

  _getUserInfo() async {
    user = await FirebaseAuth.instance.currentUser();
    var userQuery = Firestore.instance
        .collection('users')
        .where('email',
            isEqualTo:
                'alessandromaggi1997@libero.it') //TODO: Togliere hard code
        .limit(1);
    userQuery.getDocuments().then(
      (data) {
        if (data.documents.length > 0) {
          print(user.email);
          setState(() {
            ingredients = data.documents[0].data['myFridge'];
            print(ingredients);
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
        title: Text("Il Mio Frigorifero"),
      ),
      body: isLoaded
          ? Center(
              child: Container(
                margin: EdgeInsets.only(top: 5),
                width: MediaQuery.of(context).size.width * 0.8,
                child: ListView.builder(
                  itemCount: ingredients.length,
                  itemBuilder: (BuildContext ctxt, int index) {
                    return Container(
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
                              ingredients[index],
                              style: TextStyle(fontSize: 22),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            color: Colors.red,
                            onPressed: () async {
                              var list = List<String>();
                              list.add(ingredients[index]);
                              final db = Firestore.instance;
                              await db
                                  .collection('users')
                                  .document(
                                      'DCby8PyNHoRI64PQPXrIUAEkKAh2') //TODO: Toglierlo hard coded
                                  .updateData({
                                "myFridge": FieldValue.arrayRemove(list)
                              });
                              initState(); //TODO: Soluzione brutta e temporanea
                            },
                          )
                        ],
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
