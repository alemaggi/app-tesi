import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyFridge extends StatefulWidget {
  @override
  _MyFridgeState createState() => _MyFridgeState();
}

class _MyFridgeState extends State<MyFridge> {
  var user;

  String _fridgeElementOne;
  String _fridgeElementTwo;
  String _fridgeElementThree;

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
            print(_fridgeElementOne);
            _fridgeElementOne = data.documents[0].data['myFridge'][0];
            _fridgeElementTwo = data.documents[0].data['myFridge'][1];
            _fridgeElementThree = data.documents[0].data['myFridge'][2];
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
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    height: MediaQuery.of(context).size.width * 0.1,
                    child: Text(
                      _fridgeElementOne,
                      style: TextStyle(fontSize: 22),
                    ),
                  ),
                  Container(
                    height: MediaQuery.of(context).size.width * 0.1,
                    child: Text(
                      _fridgeElementTwo,
                      style: TextStyle(fontSize: 22),
                    ),
                  ),
                  Container(
                    height: MediaQuery.of(context).size.width * 0.1,
                    child: Text(
                      _fridgeElementThree,
                      style: TextStyle(fontSize: 22),
                    ),
                  ),
                ],
              ),
            )
          : CircularProgressIndicator(),
    );
  }
}
