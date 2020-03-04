import 'package:app_tesi/HomePage/homepage.dart';
import 'package:app_tesi/Profile/editProfile.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  var _url;
  String _name;
  String _surname;
  String _email;
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
            _name = data.documents[0].data['name'];
            _surname = data.documents[0].data['surname'];
            _email = user.email;
            _url = data.documents[0].data['profilePicUrl'];
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
    return isLoaded
        ? Scaffold(
            appBar: AppBar(
              backgroundColor: Color.fromRGBO(255, 0, 87, 1),
              title: Text("Profile"),
              leading: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Homepage()),
                    );
                  }),
              actions: <Widget>[
                IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => EditProfile()),
                      );
                    })
              ],
            ),
            body: Center(
              child: Column(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(
                        top: MediaQuery.of(context).size.width * 0.05,
                        bottom: MediaQuery.of(context).size.width * 0.02),
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "Your Profile",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                        bottom: MediaQuery.of(context).size.width * 0.05),
                    width: MediaQuery.of(context).size.width * 0.5,
                    height: MediaQuery.of(context).size.width * 0.5,
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(_url),
                    ),
                  ),
                  Text(
                    _name + " " + _surname,
                    style: TextStyle(fontSize: 22),
                  ),
                  Text(
                    _email,
                    style: TextStyle(fontSize: 22),
                  ),
                ],
              ),
            ),
          )
        : Container(
            height: 20,
            width: 20,
            margin: EdgeInsets.all(5),
            child: CircularProgressIndicator(
              strokeWidth: 6.0,
              valueColor: AlwaysStoppedAnimation(Colors.transparent),
            ),
          );
  }
}
