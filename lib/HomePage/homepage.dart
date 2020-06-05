import 'package:app_tesi/Fridge/myFridge.dart';
import 'package:app_tesi/HomePage/ocrReader.dart';
import 'package:app_tesi/Profile/profile.dart';
import 'package:app_tesi/Recipe/allRecipeTemplate.dart';
import 'package:app_tesi/Recipe/singleRecipe.dart';
import 'package:app_tesi/Wrapper/wrapperForFirstPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:expandable_card/expandable_card.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'dart:math' as math;
import 'food.dart';

import 'package:dio/dio.dart';

class Homepage extends StatefulWidget {
  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  AutoCompleteTextField searchTextField;
  AutoCompleteTextField searchTextFieldTwo;
  TextEditingController controller = new TextEditingController();
  TextEditingController controllerTwo = new TextEditingController();
  GlobalKey<AutoCompleteTextFieldState<Alimento>> key = new GlobalKey();
  GlobalKey<AutoCompleteTextFieldState<Alimento>> keyTwo = new GlobalKey();
  final TextEditingController _filter = new TextEditingController();
  final dio = new Dio();
  List names = new List();
  List filteredNames = new List();
  Icon _searchIcon = new Icon(Icons.search);
  Widget _appBarTitle = new Text('Le ricette che puoi fare subito');
  final _addFoodToFridgeKey = GlobalKey<FormState>();
  var notAddedList = List<String>();
  String _nomeAlimentoDaAggiungereAlF;
  var user;
  List<dynamic> favoriteRecipes;
  List<dynamic> ingredients; //Serve anche per fare un check che gli ingredienti
  List<String> _listOfIngredientsToAdd = [];
  bool isLoaded = false;
  bool actionComplete = false;
  bool addedWithoutDupes = true;
  int counter = 0;
  bool hoAlmenoUnaRicetta = false;
  List<dynamic> recipeList = [];

  bool _showFilterBox = false;

  List<dynamic> recipes;
  List<dynamic> allergens;
  bool showRecipeWithAllergens = false;

  List<String> _possibleFilter = [
    'Nessuno',
    'Calorie Crescenti',
    'Crescente Difficoltà',
    'Decrescente Difficoltà',
    'Tempo di Preparazione',
  ];

  String _selectedFilterTmp = 'Nessuno';
  String _selectedFilter = 'Nessuno';

  _getUserFridge() async {
    user = await FirebaseAuth.instance.currentUser();
    print("EMAIL" + user.email);
    var userQuery = Firestore.instance
        .collection('users')
        .where('email', isEqualTo: user.email)
        .limit(1);
    userQuery.getDocuments().then(
      (data) {
        if (data.documents.length > 0) {
          setState(() {
            ingredients = data.documents[0].data['myFridge'];
            allergens = data.documents[0].data['allergens'];
            showRecipeWithAllergens =
                data.documents[0].data['showRecipeWithAllergens'];
            print("INGREDIENTI" + ingredients.toString());
            print("ALLERGENI" + allergens.toString());
          });
        }
      },
    );
  }

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
            print("Preferiti: " + favoriteRecipes.toString());
          });
        }
      },
    );
  }

  @override
  void initState() {
    _getUserFridge();
    _getUserInfo();
    setState(() {
      isLoaded = true;
    });
    super.initState();
  }

  bool checkIfRecipeIsDoable(
      List<dynamic> userIngredients, List<dynamic> recipeIngredients) {
    if (userIngredients != null && recipeIngredients != null) {
      for (var i = 0; i < recipeIngredients.length; i++) {
        bool trovataCorrispondenza = false;
        for (var k = 0; k < userIngredients.length; k++) {
          if (recipeIngredients[i].contains(userIngredients[k])) {
            trovataCorrispondenza = true;
          }
        }
        if (trovataCorrispondenza == false) return false;
        //print("Non posso fare sta ricetta");
      }
      //print("Posso fare sta ricetta");
      return true;
    } else
      return false;
  }

  bool checkIfRecipeContainsAllergens(
      List<dynamic> userAllergenes, List<dynamic> recipeIngredients) {
    if (userAllergenes != null && recipeIngredients != null) {
      print("Allergeni: " + userAllergenes.toString());
      print("Ingredienti: " + recipeIngredients.toString());
      for (var i = 0; i < recipeIngredients.length; i++) {
        bool trovatoAllergene = false;
        for (var k = 0; k < userAllergenes.length; k++) {
          print("Negli allergeni sto confrontadno: " +
              recipeIngredients[i] +
              "e: " +
              userAllergenes[k] +
              ". Il valore di trovatoAllergene è: " +
              trovatoAllergene.toString());
          if (recipeIngredients[i].contains(userAllergenes[k])) {
            print("Trovato allergene ed è: " + userAllergenes[k]);
            trovatoAllergene = true;
          }
        }
        if (trovatoAllergene == true) {
          print("----> Non posso fare sta ricetta senza morire");
          return true; //Quindi contiene un allergene
        }
      }
      print("----> Posso fare sta ricetta senza morire");
      return false; //La ricetta non contiene nessuno degli allergeni
    } else
      return false;
  }

  bool checkIfRecipeCanBeOutputted(List<dynamic> userIngredients,
      List<dynamic> recipeIngredients, List<dynamic> userAllergenes) {
    if (showRecipeWithAllergens == true) {
      //Vuol dire che voglio vedere le ricette anche che mi fanno morire
      print("showRecipeWithAllergens = " +
          showRecipeWithAllergens.toString() +
          "e checkIfRecipeIsDoable ritorna" +
          checkIfRecipeIsDoable(userIngredients, recipeIngredients).toString());
      //Quindi controllo solo se ho gli ingredienti per farla
      if (checkIfRecipeIsDoable(userIngredients, recipeIngredients)) {
        recipeList.add(1);
      }
      return checkIfRecipeIsDoable(userIngredients, recipeIngredients);
    }
    //Se non voglio vedere le ricette che mi farebbero morire
    else {
      print("showRecipeWithAllergens = " +
          showRecipeWithAllergens.toString() +
          "e checkIfRecipeContainsAllergens ritorna: " +
          checkIfRecipeContainsAllergens(allergens, recipeIngredients)
              .toString());
      //Controllo se sta ricetta la posso fare senza morire
      if (checkIfRecipeContainsAllergens(allergens, recipeIngredients) ==
          false) {
        //Se entro qui dentro vuol dire che sta ricetta non mi uccide
        //Se posso farla senza morire guardo se ho gli ingredienti per farla
        if (checkIfRecipeIsDoable(userIngredients, recipeIngredients)) {
          recipeList.add(1);
        }
        return checkIfRecipeIsDoable(userIngredients, recipeIngredients);
      } else {
        print("Fallito checkIfRecipeContainsAllergens");
        return false;
      }
    }
  }

  //Display delle ricette
  Widget _buildBody(BuildContext context) {
    if (_selectedFilter == 'Nessuno') {
      print("-->" + _selectedFilter);
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
    if (_selectedFilter == 'Calorie Crescenti') {
      print("-->" + _selectedFilter);
      return StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance
            .collection('recipes')
            .orderBy('calories', descending: false)
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
    if (_selectedFilter == 'Crescente Difficoltà') {
      print("-->" + _selectedFilter);
      return StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance
            .collection('recipes')
            .orderBy('difficultyNumber', descending: false)
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
    if (_selectedFilter == 'Decrescente Difficoltà') {
      print("-->" + _selectedFilter);
      return StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance
            .collection('recipes')
            .orderBy('difficultyNumber', descending: true)
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
    if (_selectedFilter == 'Tempo di Preparazione') {
      print("-->" + _selectedFilter);
      return StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance
            .collection('recipes')
            .orderBy('duration', descending: false)
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

    return checkIfRecipeCanBeOutputted(
            ingredients, queryRecord.ingredients, allergens)
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
                          color: Color.fromRGBO(233, 0, 45, 1),
                        ),
                      ),
                      FittedBox(
                        fit: BoxFit.contain,
                        child: Text(
                          queryRecord.title,
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
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
                          Container(
                            child: Row(
                              children: <Widget>[
                                (showRecipeWithAllergens == true &&
                                        (checkIfRecipeContainsAllergens(
                                                allergens,
                                                queryRecord.ingredients) ==
                                            true))
                                    ? IconButton(
                                        icon: Icon(
                                            Icons.sentiment_very_dissatisfied,
                                            color:
                                                Color.fromRGBO(233, 0, 45, 1),
                                            size: 30),
                                        onPressed: () => showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AllergensInfo();
                                          },
                                        ),
                                      )
                                    : Container(),
                                IconButton(
                                  icon: Icon(
                                    Icons.favorite,
                                    color: (favoriteRecipes
                                            .contains(documnetId))
                                        ? Color.fromRGBO(233, 0, 45, 1)
                                        : Color.fromRGBO(230, 219, 221, 100),
                                    size: 30,
                                  ),
                                  onPressed:
                                      (favoriteRecipes.contains(documnetId))
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
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            child: FlatButton(
                              color: Color.fromRGBO(233, 0, 45, 1),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SingleRecipe(
                                      documentId: documnetId,
                                      title: queryRecord.title,
                                      favoriteRecipes: favoriteRecipes,
                                      userIngredients: ingredients,
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
  //FINE DISPLAY RICETTE

  Widget _buildBar(BuildContext context) {
    return AppBar(
      backgroundColor: Color.fromRGBO(233, 0, 45, 1),
      centerTitle: true,
      title: _appBarTitle,
      actions: <Widget>[
        IconButton(
          icon: Icon(
            Icons.filter_list,
            color: Colors.white,
          ),
          onPressed: () {
            setState(() {
              _showFilterBox = !_showFilterBox;
            });
          },
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
        this._appBarTitle = Text('Le ricette che puoi fare subito');
        filteredNames = names;
        _filter.clear();
      }
    });
  }

  Future<void> _refreshRecipes() async {
    setState(() {
      initState();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false, //SERVE ?
      appBar: _buildBar(context),
      drawer: NavDrawer(),
      body: RefreshIndicator(
        onRefresh: _refreshRecipes,
        child: ExpandableCardPage(
          page: (isLoaded == true)
              ? Stack(
                  children: <Widget>[
                    (ingredients != null &&
                            ((ingredients.length == 1 &&
                                    ingredients[0] == "Acqua") ||
                                ingredients.isEmpty))
                        ? Container(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.width,
                            child: Image(
                              image: AssetImage("assets/emptyFridge.png"),
                            ),
                          )
                        : Container(),
                    Container(
                      child: _buildBody(context),
                      margin: EdgeInsets.only(
                        bottom: MediaQuery.of(context).size.height * 0.11,
                      ),
                    ),
                    _showFilterBox
                        ? Container(
                            height: 125,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Color.fromRGBO(233, 0, 45, 1),
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(20),
                                bottomRight: Radius.circular(20),
                              ),
                            ),
                            child: Column(
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    FlatButton(
                                      onPressed: () {
                                        setState(() {
                                          _showFilterBox = false;
                                        });
                                      },
                                      child: Text(
                                        "ANNULLA",
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 18),
                                      ),
                                    ),
                                    FlatButton(
                                      onPressed: () {
                                        setState(() {
                                          _selectedFilter = _selectedFilterTmp;
                                          _showFilterBox = false;
                                        });
                                      },
                                      child: Text(
                                        "CONFERMA",
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 18),
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.8,
                                  child: DropdownButton(
                                    underline: Container(
                                      height: 1,
                                      color: Colors.black87,
                                    ),
                                    icon: Icon(
                                      Icons.arrow_drop_down,
                                      color: Colors.black87,
                                    ),
                                    iconSize: 32,
                                    isExpanded: true,
                                    value: _selectedFilterTmp,
                                    onChanged: (newValue) {
                                      setState(() {
                                        _selectedFilterTmp = newValue;
                                      });
                                    },
                                    items: _possibleFilter.map((location) {
                                      return DropdownMenuItem(
                                        child: Center(
                                          child: new Text(
                                            location,
                                            style: TextStyle(fontSize: 18),
                                          ),
                                        ),
                                        value: location,
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Container(),
                  ],
                )
              : Center(
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
          expandableCard: ExpandableCard(
            backgroundColor: Color.fromRGBO(233, 0, 45, 1),
            minHeight: MediaQuery.of(context).size.height * 0.18,
            maxHeight: MediaQuery.of(context).size.height * 0.85,
            hasRoundedCorners: true,
            children: <Widget>[
              Column(
                children: <Widget>[
                  Container(
                    child: Text(
                      "Aggiungi elementi al tuo frigo",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    constraints: BoxConstraints(minWidth: 100, maxWidth: 500),
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                    height: 95,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _listOfIngredientsToAdd.length,
                      itemBuilder: (context, index) {
                        return Container(
                          child: Card(
                            color: Colors.transparent,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.only(left: 15),
                                  child: Center(
                                      child: Text(
                                    _listOfIngredientsToAdd[index].toString(),
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 26.0),
                                  )),
                                ),
                                IconButton(
                                    icon: Icon(
                                      Icons.delete,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _listOfIngredientsToAdd.removeAt(index);
                                      });
                                    }),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Container(
                    key: _addFoodToFridgeKey,
                    constraints: BoxConstraints(minWidth: 100, maxWidth: 475),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        new Column(
                          children: <Widget>[
                            searchTextField = AutoCompleteTextField<Alimento>(
                              suggestionsAmount: 4,
                              style: new TextStyle(
                                color: Colors.white,
                                fontSize: 24.0,
                              ),
                              submitOnSuggestionTap: true,
                              controller: controller,
                              decoration: new InputDecoration(
                                contentPadding:
                                    EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 20.0),
                                filled: true,
                                hintText: 'Inserisci un alimento',
                                hintStyle: TextStyle(
                                  fontSize: 22,
                                  color: Colors.white,
                                ),
                              ),
                              itemBuilder: (context, item) {
                                return Row(
                                  children: <Widget>[
                                    Text(
                                      item.nome,
                                      style: TextStyle(fontSize: 20.0),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(15.0),
                                    ),
                                  ],
                                );
                              },
                              itemFilter: (item, query) {
                                return item.nome
                                    .toLowerCase()
                                    .startsWith(query.toLowerCase());
                              },
                              itemSorter: (a, b) {
                                return a.nome.compareTo(b.nome);
                              },
                              itemSubmitted: (item) {
                                setState(() => searchTextField
                                    .textField.controller.text = item.nome);
                              },
                              key: key,
                              suggestions: foodList,
                              clearOnSubmit: false,
                            )
                          ],
                        ),
                        Container(
                          constraints:
                              BoxConstraints(minWidth: 100, maxWidth: 500),
                          margin: EdgeInsets.only(
                            top: MediaQuery.of(context).size.width * 0.1,
                          ),
                          width: MediaQuery.of(context).size.width * 0.8,
                          height: MediaQuery.of(context).size.width * 0.12,
                          child: FlatButton(
                            onPressed: () {
                              if (ingrCheckList.isEmpty) {
                                loadElementstoCheckList();
                              }
                              if (searchTextField
                                  .textField.controller.text.isNotEmpty) {
                                String s =
                                    searchTextField.textField.controller.text;
                                s = s[0].toUpperCase() + s.substring(1);
                                if (ingrCheckList.contains(s)) {
                                  _nomeAlimentoDaAggiungereAlF = s;
                                  setState(() {
                                    _listOfIngredientsToAdd
                                        .add(_nomeAlimentoDaAggiungereAlF);
                                    controller.clear();
                                  });
                                }
                              }
                            },
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(10.0),
                              side: BorderSide(
                                color: Color.fromRGBO(233, 0, 45, 1),
                                width: 3,
                              ),
                            ),
                            child: Text(
                              "Aggiungi alimento alla lista",
                              style: TextStyle(
                                fontSize: 24,
                                color: Color.fromRGBO(233, 0, 45, 1),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          constraints:
                              BoxConstraints(minWidth: 100, maxWidth: 500),
                          margin: EdgeInsets.only(
                            top: MediaQuery.of(context).size.width * 0.1,
                          ),
                          width: MediaQuery.of(context).size.width * 0.8,
                          height: MediaQuery.of(context).size.width * 0.12,
                          child: FlatButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => OcrReader()),
                              );
                            },
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(10.0),
                              side: BorderSide(
                                color: Color.fromRGBO(233, 0, 45, 1),
                                width: 3,
                              ),
                            ),
                            child: Text(
                              "Usa l' OCR",
                              style: TextStyle(
                                fontSize: 24,
                                color: Color.fromRGBO(233, 0, 45, 1),
                              ),
                            ),
                          ),
                        ),
                        (_listOfIngredientsToAdd.isNotEmpty)
                            ? Container(
                                constraints: BoxConstraints(
                                    minWidth: 100, maxWidth: 500),
                                margin: EdgeInsets.only(
                                  top: MediaQuery.of(context).size.width * 0.1,
                                ),
                                width: MediaQuery.of(context).size.width * 0.8,
                                height:
                                    MediaQuery.of(context).size.width * 0.12,
                                child: FlatButton(
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        new BorderRadius.circular(10.0),
                                    side: BorderSide(
                                      color: Color.fromRGBO(233, 0, 45, 1),
                                      width: 3,
                                    ),
                                  ),
                                  color: Colors.white,
                                  onPressed: () async {
                                    if (_listOfIngredientsToAdd.isNotEmpty) {
                                      var list = List<String>();
                                      List<String> output = Iterable.generate(
                                              math.max(
                                                  list.length,
                                                  _listOfIngredientsToAdd
                                                      .length))
                                          .expand((i) sync* {
                                        if (i < list.length) yield list[i];
                                        if (i < _listOfIngredientsToAdd.length)
                                          yield _listOfIngredientsToAdd[i];
                                      }).toList();
                                      print("Prima :");
                                      print(output);
                                      if (ingredients != null) {
                                        //Controllo che gli elementi aggiunti non siano gia presenti nel frigo
                                        for (int i = 0;
                                            i < output.length;
                                            i++) {
                                          if (ingredients.contains(output[i])) {
                                            print("Trovato : " + output[i]);
                                            notAddedList.add(output[i]);
                                          }
                                        }
                                        for (String item in notAddedList)
                                          output.remove(item);
                                        print(ingredients);
                                        print("Lista cose da non aggiungere :");
                                        print(notAddedList);
                                        if (notAddedList.length == 0) {
                                          addedWithoutDupes = true;
                                        } else {
                                          addedWithoutDupes = false;
                                        }
                                        Firestore.instance
                                            .collection('users')
                                            .document(user.uid)
                                            .updateData({
                                          "myFridge":
                                              FieldValue.arrayUnion(output)
                                        });
                                        setState(() {
                                          actionComplete = true;
                                          _getUserInfo();
                                          _listOfIngredientsToAdd.clear();
                                        });
                                      } else {
                                        //Se il DB non contiene ingredienti li posso aggiungere senza problemi
                                        Firestore.instance
                                            .collection('users')
                                            .document(user.uid)
                                            .updateData({
                                          "myFridge":
                                              FieldValue.arrayUnion(output)
                                        });
                                        setState(() {
                                          actionComplete = true;
                                          _listOfIngredientsToAdd.clear();
                                        });
                                      }
                                      //TODO: Far chiudere la card quando viene premuto il bottone
                                    }
                                  },
                                  child: Text(
                                    "Conferma",
                                    style: TextStyle(
                                      fontSize: 24,
                                      color: Color.fromRGBO(233, 0, 45, 1),
                                    ),
                                  ),
                                ),
                              )
                            : Container(
                                height: 0,
                              ),
                        (actionComplete)
                            ? AlertDialog(
                                contentPadding: EdgeInsets.all(10.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                backgroundColor: Colors.white,
                                content: uploadMessage(),
                                actions: [
                                  FlatButton(
                                    child: Text("Ok"),
                                    onPressed: () {
                                      notAddedList.clear();
                                      actionComplete = false;
                                      _getUserFridge();
                                      setState(() {});
                                    },
                                  )
                                ],
                              )
                            : Container(),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget uploadMessage() {
    print(addedWithoutDupes);
    if (!addedWithoutDupes) {
      return Column(children: <Widget>[
        Text(
          "I seguenti alimenti non sono stati aggiunti perchè già presenti nel tuo frigo :",
          style: TextStyle(fontSize: 16),
        ),
        for (var item in notAddedList) Text(item)
      ]);
    } else {
      return Column(
        children: <Widget>[
          Text(
            "Tutti gli ingredienti sono stati aggiunti al tuo frigo",
            style: TextStyle(fontSize: 16),
          ),
        ],
      );
    }
  }
}

/*
* Side menu qui sotto
*/
class NavDrawer extends StatefulWidget {
  @override
  _NavDrawerState createState() => _NavDrawerState();
}

class _NavDrawerState extends State<NavDrawer> {
  var _url;
  String _name;
  String _surname;
  String _email;
  bool isLoaded = false;
  var user;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  _getUserInfo() async {
    user = await FirebaseAuth.instance.currentUser();
    var userQuery = Firestore.instance
        .collection('users')
        .where('email', isEqualTo: user.email)
        .limit(1);
    print(user.email);
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
        ? Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                UserAccountsDrawerHeader(
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(233, 0, 45, 1),
                  ),
                  currentAccountPicture: CircleAvatar(
                    backgroundImage: NetworkImage(_url),
                  ),
                  accountName: Text(
                    _name + " " + _surname,
                  ),
                  accountEmail: Text(_email),
                ),
                ListTile(
                  title: Text("Home"),
                  onTap: () => {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) {
                          return Homepage();
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
                    ),
                  },
                ),
                ListTile(
                  title: Text('Profilo'),
                  onTap: () => {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) {
                          return Profile();
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
                    ),
                  },
                ),
                ListTile(
                  title: Text('Il mio frigorifero'),
                  onTap: () => {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) {
                          return MyFridge();
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
                    ),
                  },
                ),
                ListTile(
                  title: Text('Tutte le ricette'),
                  onTap: () => {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) {
                          return AllRecipeTemplate();
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
                    ),
                  },
                ),
                ListTile(
                  title: Text('La mia lista della spesa'),
                  onTap: () => {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) {
                          return MyFridge();
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
                    ),
                  },
                ),
                ListTile(
                  title: Text('LogOut'),
                  onTap: () async {
                    await _auth.signOut();
                    setState(() async {
                      user = await FirebaseAuth.instance.currentUser();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WrapperForFirstPage(),
                        ),
                      );
                    });
                  },
                ),
              ],
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
                  Color.fromRGBO(233, 0, 45, 1),
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

  final List<dynamic> ingredients;

  final DocumentReference reference;

  QueryRecord.fromMap(Map<String, dynamic> map, {this.reference})
      : title = map['title'],
        duration = map['duration'].toString(),
        imageLink = map['imageLink'],
        ingredients = map['ingredients'];

  QueryRecord.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  @override
  String toString() => "QueryRecord<$title:$duration:$imageLink:$ingredients>";
}

class AutoComplete extends StatefulWidget {
  @override
  _AutoCompleteState createState() => new _AutoCompleteState();
}

class _AutoCompleteState extends State<AutoComplete> {
  _AutoCompleteState();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Auto Complete List Demo'),
        ),
        body: new Center(
            child: new Column(children: <Widget>[
          new Column(children: <Widget>[
            //AutoCompleteTextField code here
          ]),
        ])));
  }
}

class AllergensInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Attenzione',
        style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
      ),
      content: Container(
        height: 150,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              "Attenzione questa ricetta contiene uno o più ingredienti che hai inserito nel tuo profilo come allergeni",
              textAlign: TextAlign.justify,
              style: TextStyle(
                fontSize: 22,
              ),
            ),
            Container(
              margin: EdgeInsets.only(bottom: 20),
              child: FlatButton(
                color: Color.fromRGBO(233, 0, 45, 1),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  "Chiudi",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(10.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
