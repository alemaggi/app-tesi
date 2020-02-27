import 'package:app_tesi/Login/login.dart';
import 'package:flutter/material.dart';
import 'package:expandable_card/expandable_card.dart';

import 'package:dio/dio.dart';

class Homepage extends StatefulWidget {
  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final TextEditingController _filter = new TextEditingController();
  final dio = new Dio();
  String _searchText = "";
  List names = new List();
  List filteredNames = new List();
  Icon _searchIcon = new Icon(Icons.search);
  Widget _appBarTitle = new Text('Search Example');

  Widget _buildBar(BuildContext context) {
    return new AppBar(
      backgroundColor: Color.fromRGBO(255, 0, 87, 1),
      centerTitle: true,
      title: _appBarTitle,
      actions: <Widget>[
        IconButton(
          icon: _searchIcon,
          onPressed: _searchPressed,
        ),
      ],
    );
  }

  void _searchPressed() {
    setState(() {
      if (this._searchIcon.icon == Icons.search) {
        this._searchIcon = Icon(Icons.close);
        this._appBarTitle = TextField(
          controller: _filter,
          decoration: InputDecoration(
              prefixIcon: Icon(Icons.search), hintText: 'Search...'),
        );
      } else {
        this._searchIcon = Icon(Icons.search);
        this._appBarTitle = Text('Search Example');
        filteredNames = names;
        _filter.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildBar(context),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text(
                "Alessandro Maggi",
                style: TextStyle(fontSize: 18, color: Colors.black),
              ),
              accountEmail: Text(
                "alessandromaggi@gmail.com",
                style: TextStyle(fontSize: 18, color: Colors.black),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.black,
                child: Text(
                  "A",
                  style: TextStyle(
                      fontSize: 40.0, color: Color.fromRGBO(255, 0, 87, 1)),
                ),
              ),
              decoration: BoxDecoration(
                color: Color.fromRGBO(255, 0, 87, 1),
              ),
            ),
            ListTile(
              leading: Icon(Icons.apps),
              title: Text('Qualcosa'),
            ),
            ListTile(
              leading: Icon(Icons.whatshot),
              title: Text("Qualcos' altro"),
            ),
            ListTile(
              leading: Icon(Icons.account_balance),
              title: Text("Qualcos' altro ancora"),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text("Torna indietro"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Login()),
                );
              },
            ),
          ],
        ),
      ),
      body: ExpandableCardPage(
        page: Center(
          child: Text(
            "Lista di ricette",
            style: TextStyle(
              color: Colors.black,
              fontSize: 44,
            ),
          ),
        ),
        expandableCard: ExpandableCard(
          backgroundColor: Color.fromRGBO(255, 0, 87, 1),
          minHeight: MediaQuery.of(context).size.height * 0.18,
          maxHeight: MediaQuery.of(context).size.height * 0.7,
          hasRoundedCorners: true,
          children: <Widget>[
            Column(
              children: <Widget>[
                Text(
                  "Qui inserisci la roba",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
