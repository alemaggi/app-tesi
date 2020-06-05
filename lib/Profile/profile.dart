import 'package:app_tesi/HomePage/homepage.dart';
import 'package:app_tesi/Profile/addAllergensPage.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:app_tesi/Profile/addAllergens.dart';
import 'package:app_tesi/Profile/editProfile.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

//void main() => runApp(ProfilePageDesign());

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  static var _url;
  static String _name;
  static String _surname;
  static String _email;
  List<dynamic> _allergens;
  bool isLoaded = false;
  var user;
  bool showRecipeImAllergicTo = false;

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
            _allergens = data.documents[0].data['allergens'];
            showRecipeImAllergicTo =
                data.documents[0].data['showRecipeWithAllergens'];
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

  Future<void> _refreshRecipes() async {
    initState();
  }

  TextStyle _style() {
    return TextStyle(fontWeight: FontWeight.bold, fontSize: 20);
  }

  @override
  Widget build(BuildContext context) {
    return isLoaded
        ? Scaffold(
            appBar: CustomAppBar(
              url: _url,
              name: _name,
              surname: _surname,
            ),
            body: Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Email",
                    style: _style(),
                  ),
                  SizedBox(
                    height: 2,
                  ),
                  Text(
                    _email,
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Divider(
                    color: Colors.grey,
                  ),
                  Text(
                    "Intolleranze & Allergie: ",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  //Provas
                  Container(
                    margin: EdgeInsets.only(
                        top: MediaQuery.of(context).size.width * 0.01,
                        bottom: MediaQuery.of(context).size.width * 0.01),
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Flexible(
                          child: Text(
                            "Mostra ricette con ingredienti allergici",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                        ),
                        Switch(
                          value: showRecipeImAllergicTo,
                          onChanged: (value) async {
                            setState(() {
                              showRecipeImAllergicTo = value;
                            });
                            final db = Firestore.instance;
                            await db
                                .collection('users')
                                .document(user.uid)
                                .updateData({"showRecipeWithAllergens": value});
                          },
                          activeTrackColor: Color.fromRGBO(233, 0, 60, 1),
                          activeColor: Color.fromRGBO(233, 0, 45, 1),
                        ),
                      ],
                    ),
                  ),
                  Center(
                    child: RefreshIndicator(
                      onRefresh: _refreshRecipes,
                      child: Container(
                        height: 300,
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: ListView.builder(
                          itemCount: _allergens.length,
                          itemBuilder: (BuildContext ctxt, int index) {
                            return Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Container(
                                decoration: new BoxDecoration(
                                  borderRadius: new BorderRadius.only(
                                    topLeft: const Radius.circular(7.0),
                                    topRight: const Radius.circular(7.0),
                                    bottomLeft: const Radius.circular(7.0),
                                    bottomRight: const Radius.circular(7.0),
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Container(
                                      margin: EdgeInsets.only(left: 10),
                                      child: Text(
                                        _allergens[index],
                                        style: TextStyle(fontSize: 22),
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete),
                                      color: Color.fromRGBO(233, 0, 45, 1),
                                      onPressed: () async {
                                        var list = List<String>();
                                        list.add(_allergens[index]);
                                        final db = Firestore.instance;
                                        await db
                                            .collection('users')
                                            .document(user.uid)
                                            .updateData({
                                          "allergens":
                                              FieldValue.arrayRemove(list)
                                        });
                                        initState(); //TODO: Soluzione brutta e temporanea
                                      },
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton(
              backgroundColor: Colors.white,
              elevation: 5,
              child: Icon(
                Icons.add,
                color: Color.fromRGBO(233, 0, 45, 1),
                size: 36,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddAllergenesPage()),
                );
              },
            ),
          )
        : Container(
            height: double.infinity,
            width: double.infinity,
            color: Colors.white,
            child: Center(
              child: Container(
                height: 100,
                width: 100,
                margin: EdgeInsets.all(5),
                child: CircularProgressIndicator(
                  strokeWidth: 6.0,
                  valueColor: AlwaysStoppedAnimation(
                    Color.fromRGBO(233, 0, 45, 1),
                  ),
                ),
              ),
            ),
          );
  }
}

class CustomAppBar extends StatefulWidget with PreferredSizeWidget {
  final String url;
  final String name;
  final String surname;
  CustomAppBar(
      {Key key,
      @required this.url,
      @required this.name,
      @required this.surname})
      : super(key: key);

  Size get preferredSize => Size(double.infinity, 340);
  HomePages createState() => HomePages();
}

class HomePages extends State<CustomAppBar> {
  Size get preferredSize => Size(double.infinity, 340);

  var user;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: MyClipper(),
      child: Container(
        padding: EdgeInsets.only(top: 20),
        decoration:
            BoxDecoration(color: Color.fromRGBO(233, 0, 45, 1), boxShadow: [
          BoxShadow(
              color: Color.fromRGBO(233, 0, 45, 1),
              blurRadius: 20,
              offset: Offset(0, 0))
        ]),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 26,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Homepage()),
                    );
                  },
                ),
                Container(
                  width: 10,
                ),
                Text(
                  "Profilo utente",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.9,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Container(
                        width: 125,
                        height: 125,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: NetworkImage(widget.url),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      Text(
                        widget.name + " " + widget.surname,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Container(
                    height: 220.0,
                    width: 220.0,
                    child: Image(
                      image: AssetImage(
                        "assets/Logo.png",
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.8,
              child: Align(
                alignment: Alignment.bottomRight,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) {
                          return EditProfile();
                        },
                        transitionsBuilder:
                            (context, animation1, animation2, child) {
                          return FadeTransition(
                            opacity: animation1,
                            child: child,
                          );
                        },
                        transitionDuration: Duration(milliseconds: 20),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 16, 0),
                    child: Transform.rotate(
                      angle: (math.pi * 0),
                      child: Container(
                        width: 130,
                        height: 32,
                        child: Center(
                          child: Text("Modifica Profilo"),
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(16)),
                          boxShadow: [
                            BoxShadow(color: Colors.black12, blurRadius: 20)
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

//Per la linea ''spezzata''
class MyClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path p = Path();
    p.lineTo(0, size.height - 70);
    p.lineTo(size.width, size.height);
    p.lineTo(size.width, 0);
    p.close();
    return p;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}
