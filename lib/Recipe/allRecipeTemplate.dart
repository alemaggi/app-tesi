import 'package:app_tesi/Recipe/singleRecipe.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Recipe/RecipeSearch/title.dart';
import 'package:basic_utils/basic_utils.dart';
import 'onlyOneCategoryRecipe.dart';

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

  bool showFilterBox = false;
  List<String> _possibleFilter = [
    'Nessuno',
    'Calorie Crescenti',
    'Crescente Difficoltà',
    'Decrescente Difficoltà',
    'Tempo di Preparazione',
  ];

  String _selectedFilterTmp = 'Nessuno';
  String _selectedFilter = 'Nessuno';

  var typeOfRecipeSelected =
      0; //0 = Nessuno, 1 = Antipasti, 2 = Primi, 3 = Secondi, 4 = Dolci

  //Questo mi serve per avere la lista delle ricette preferite
  List<dynamic> favoriteRecipes;
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
    items.addAll(duplicateItems);
    super.initState();
  }

  Icon _searchIcon = new Icon(Icons.search);
  Widget _appBarTitle = new Text('Tutte le ricette');
  final TextEditingController _filter = new TextEditingController();
  List names = new List();
  List filteredNames = new List();
  bool showCardForSearchResults = false;

  void costruttore() {
    for (int i = 0; i < titleList.length; i++) {
      duplicateItems.add(titleList[i].getTitle());
    }
  }

  String printId(String titleInput) {
    var index = null;
    if (titleInput.isEmpty) {
      print("Error! no input!");
    } else {
      for (int i = 0; i < titleList.length; i++) {
        if (titleList[i].getTitle().toString().contains(titleInput)) {
          index = i;
          return titleList[i].getId();
        }
      }
    }
  }

  void filterSearchResults(String query) {
    if (listOfTitle.isEmpty) {
      loadElementToSearchList();
    }
    String capitalized = StringUtils.capitalize(query);
    List<String> dummySearchList = List<String>();
    dummySearchList.addAll(duplicateItems);
    if (query.isNotEmpty) {
      List<String> dummyListData = List<String>();
      dummySearchList.forEach((item) {
        if (item.contains(capitalized)) {
          dummyListData.add(item);
          printId(item);
        }
      });
      setState(() {
        items.clear();
        items.addAll(dummyListData);
      });
      return;
    } else {
      setState(() {
        items.clear();
        items.addAll(duplicateItems);
      });
    }
  }

  var duplicateItems = listOfTitle;
  var items = List<String>();

  void _searchPressed() {
    setState(() {
      if (this._searchIcon.icon == Icons.search) {
        showCardForSearchResults = true;
        this._searchIcon = Icon(Icons.close);
        this._appBarTitle = TextField(
          onChanged: (val) {
            filterSearchResults(val);
          },
          controller: _filter,
          decoration: InputDecoration(
              prefixIcon: Icon(Icons.search), hintText: 'Search...'),
        );
      } else {
        showCardForSearchResults = false;
        this._searchIcon = Icon(Icons.search);
        this._appBarTitle = Text('Tutte le Ricette');
        filteredNames = names;
        _filter.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(233, 0, 45, 1),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: _searchIcon,
            onPressed: _searchPressed,
          ),
          IconButton(
            icon: Icon(Icons.filter_list, color: Colors.white),
            onPressed: () {
              setState(() {
                showFilterBox = !showFilterBox;
              });
            },
          ),
        ],
        title: _appBarTitle,
      ),
      body: Container(
        margin: EdgeInsets.only(top: 5),
        child: Stack(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    FlatButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(10.0),
                      ),
                      color: (typeOfRecipeSelected == 1)
                          ? Color.fromRGBO(233, 0, 45, 1)
                          : Color.fromRGBO(230, 219, 221, 100),
                      onPressed: (typeOfRecipeSelected != 1)
                          ? () {
                              setState(() {
                                typeOfRecipeSelected = 1;
                              });
                            }
                          : () {
                              setState(() {
                                typeOfRecipeSelected = 0;
                              });
                            },
                      child: Text(
                        "Antipasti",
                        style: TextStyle(
                          fontSize: 18,
                          color: (typeOfRecipeSelected == 1)
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    ),
                    FlatButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(10.0),
                      ),
                      color: (typeOfRecipeSelected == 2)
                          ? Color.fromRGBO(233, 0, 45, 1)
                          : Color.fromRGBO(230, 219, 221, 100),
                      onPressed: (typeOfRecipeSelected != 2)
                          ? () {
                              setState(() {
                                typeOfRecipeSelected = 2;
                              });
                            }
                          : () {
                              setState(() {
                                typeOfRecipeSelected = 0;
                              });
                            },
                      child: Text(
                        "Primi",
                        style: TextStyle(
                          fontSize: 18,
                          color: (typeOfRecipeSelected == 2)
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    ),
                    FlatButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(10.0),
                      ),
                      color: (typeOfRecipeSelected == 3)
                          ? Color.fromRGBO(233, 0, 45, 1)
                          : Color.fromRGBO(230, 219, 221, 100),
                      onPressed: (typeOfRecipeSelected != 3)
                          ? () {
                              setState(() {
                                typeOfRecipeSelected = 3;
                              });
                            }
                          : () {
                              setState(() {
                                typeOfRecipeSelected = 0;
                              });
                            },
                      child: Text(
                        "Secondi",
                        style: TextStyle(
                          fontSize: 18,
                          color: (typeOfRecipeSelected == 3)
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    ),
                    FlatButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(10.0),
                      ),
                      color: (typeOfRecipeSelected == 4)
                          ? Color.fromRGBO(233, 0, 45, 1)
                          : Color.fromRGBO(230, 219, 221, 100),
                      onPressed: (typeOfRecipeSelected != 4)
                          ? () {
                              setState(() {
                                typeOfRecipeSelected = 4;
                              });
                            }
                          : () {
                              setState(() {
                                typeOfRecipeSelected = 0;
                              });
                            },
                      child: Text(
                        "Dolci",
                        style: TextStyle(
                          fontSize: 18,
                          color: (typeOfRecipeSelected == 4)
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    FlatButton(
                      color: (typeOfRecipeSelected == 5)
                          ? Color.fromRGBO(233, 0, 45, 1)
                          : Color.fromRGBO(230, 219, 221, 100),
                      onPressed: (typeOfRecipeSelected != 5)
                          ? () {
                              setState(() {
                                typeOfRecipeSelected = 5;
                              });
                            }
                          : () {
                              setState(() {
                                typeOfRecipeSelected = 0;
                              });
                            },
                      child: Text(
                        "Mostra Solo Preferiti",
                        style: TextStyle(
                          fontSize: 18,
                          color: (typeOfRecipeSelected == 5)
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(10.0),
                      ),
                    ),
                  ],
                ),
                OnlyOneCategoryRecipe(
                  categoryToShow: typeOfRecipeSelected,
                  filterSelected: _selectedFilter,
                ),
                showFilterBox
                    ? Container(
                        height: 130,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(233, 0, 45, 1),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                        ),
                        child: Column(
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                FlatButton(
                                  onPressed: () {
                                    setState(() {
                                      showFilterBox = false;
                                    });
                                  },
                                  child: Text(
                                    "DISMISS",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 18),
                                  ),
                                ),
                                FlatButton(
                                  onPressed: () {
                                    setState(() {
                                      _selectedFilter = _selectedFilterTmp;
                                      print("FINAL: " + _selectedFilter);
                                      showFilterBox = false;
                                    });
                                  },
                                  child: Text(
                                    "CONFIRM",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 18),
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.8,
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
                                    print("-->" + _selectedFilterTmp);
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
            ),
            //SOPRA
            showCardForSearchResults
                ? Container(
                    color: Colors.white,
                    height: MediaQuery.of(context).size.height,
                    width: double.infinity,
                    child: Column(
                      children: <Widget>[
                        Expanded(
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: Text('${items[index]}'),
                                onTap: () {
                                  String tit = '${items[index]}';
                                  String id = printId(tit);
                                  List<String> fav = [];
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SingleRecipe(
                                        documentId: id,
                                        title: tit,
                                        favoriteRecipes: fav,
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
