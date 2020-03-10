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
        .where('email', isEqualTo: 'alessandromaggi1997@libero.it')
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
          ? Container(
              child: ListView.builder(
                itemCount: ingredients.length,
                itemBuilder: (BuildContext ctxt, int index) {
                  return Container(
                    padding: EdgeInsets.all(5),
                    child: Center(
                      child: new Text(
                        ingredients[index],
                        style: TextStyle(fontSize: 22),
                      ),
                    ),
                  );
                },
              ),
            )
          : CircularProgressIndicator(
              strokeWidth: 6.0,
              valueColor: AlwaysStoppedAnimation(Colors.transparent),
            ),
    );
  }
}
