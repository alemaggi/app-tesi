import 'package:app_tesi/HomePage/homepage.dart';
import 'package:flutter/material.dart';
import 'dart:io';
//import per mlkit
import 'package:image_picker/image_picker.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'food.dart';
import 'dart:math' as math;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OcrReader extends StatefulWidget {
  @override
  _OcrReaderState createState() => _OcrReaderState();
}

class _OcrReaderState extends State<OcrReader> {
  File pickedImage;
  bool isImageLoaded = false;
  var user;

  Future pickImage() async {
    var tempStore = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      pickedImage = tempStore;
      isImageLoaded = true;
    });
  }

  List<String> _listOfIngredientsToAdd = [];

  Future readText() async {
    user = await FirebaseAuth.instance.currentUser();
    String tmp;
    FirebaseVisionImage ourImage = FirebaseVisionImage.fromFile(pickedImage);
    TextRecognizer recognizeText = FirebaseVision.instance.textRecognizer();
    VisionText readText = await recognizeText.processImage(ourImage);
    if (ingrCheckList.isEmpty) {
      loadElementstoCheckList();
    }
    for (TextBlock block in readText.blocks) {
      for (TextLine line in block.lines) {
        if (ingrCheckList.contains(line.text)) {
          tmp = line.text;
          print("Ho trovato: " + tmp);
          setState(() {
            _listOfIngredientsToAdd.add(tmp);
          });
          print("Lista --> " + _listOfIngredientsToAdd.toString());
        }
        for (TextElement word in line.elements) {
          if (line.elements.length == 0) {
            print("Impossibile trovare testo.");
          }
        }
      }
    }
    print("Fine");
  }

  //Widget che dovrebbe mostrare il testo, non so bene come incorporarlo alla classe principale.
  Widget _buildTextRow(temp) {
    return ListTile(
      title: Text(
        temp.text,
      ),
      dense: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Ocr Reader",
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color.fromRGBO(255, 0, 87, 1),
      ),
      body: Container(
        margin: EdgeInsets.only(top: 20),
        child: Column(
          children: <Widget>[
            isImageLoaded
                ? Center(
                    child: Container(
                      height: MediaQuery.of(context).size.width * 0.6,
                      width: MediaQuery.of(context).size.width * 0.6,
                      constraints: BoxConstraints(
                          minWidth: 100, maxWidth: 350, maxHeight: 350),
                      decoration: BoxDecoration(
                        image: DecorationImage(
                            image: FileImage(pickedImage), fit: BoxFit.contain),
                      ),
                    ),
                  )
                : Container(),
            Container(
              constraints: BoxConstraints(minWidth: 100, maxWidth: 350),
              width: MediaQuery.of(context).size.width * 0.4,
              height: 50,
              child: FlatButton(
                color: Color.fromRGBO(255, 0, 87, 1),
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: Text(
                    "Carica Immagine",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                onPressed: pickImage,
                shape: RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(10.0),
                ),
              ),
            ),
            SizedBox(height: 10.0),
            isImageLoaded
                ? Container(
                    constraints: BoxConstraints(minWidth: 10, maxWidth: 350),
                    width: MediaQuery.of(context).size.width * 0.4,
                    height: 50,
                    margin: EdgeInsets.only(
                      top: MediaQuery.of(context).size.width * 0.01,
                    ),
                    child: FlatButton(
                      color: Color.fromRGBO(255, 0, 87, 1),
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: Text(
                          "Leggi Testo",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      onPressed: () {
                        print("Leggo");
                        readText();
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(10.0),
                      ),
                    ),
                  )
                : Container(),
            SizedBox(height: 10.0),
            (_listOfIngredientsToAdd.isNotEmpty)
                ? Expanded(
                    child: Container(
                      constraints: BoxConstraints(minWidth: 100, maxWidth: 500),
                      margin: EdgeInsets.only(top: 5),
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: ListView.builder(
                        itemCount: _listOfIngredientsToAdd.length,
                        itemBuilder: (BuildContext ctxt, int index) {
                          return Padding(
                            padding: const EdgeInsets.all(4),
                            child: Container(
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Container(
                                    margin: EdgeInsets.only(left: 10),
                                    child: Text(
                                      _listOfIngredientsToAdd[index],
                                      style: TextStyle(fontSize: 22),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete),
                                    color: Colors.red,
                                    onPressed: () {
                                      setState(() {
                                        _listOfIngredientsToAdd.removeAt(index);
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  )
                : Container(),
            (_listOfIngredientsToAdd.isNotEmpty)
                ? Container(
                    constraints: BoxConstraints(minWidth: 100, maxWidth: 350),
                    width: MediaQuery.of(context).size.width * 0.4,
                    height: 50,
                    margin: EdgeInsets.only(
                        top: MediaQuery.of(context).size.width * 0.01,
                        bottom: MediaQuery.of(context).size.width * 0.02),
                    child: FlatButton(
                      color: Color.fromRGBO(255, 0, 87, 1),
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: Text(
                          "Aggiungi Al Frigo",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      onPressed: () async {
                        var user = await FirebaseAuth.instance.currentUser();
                        if (_listOfIngredientsToAdd.isNotEmpty) {
                          var list = List<String>();
                          List<String> output = Iterable.generate(math.max(
                                  list.length, _listOfIngredientsToAdd.length))
                              .expand((i) sync* {
                            if (i < list.length) yield list[i];
                            if (i < _listOfIngredientsToAdd.length)
                              yield _listOfIngredientsToAdd[i];
                          }).toList();
                          print(output);
                          Firestore.instance
                              .collection('users')
                              .document(user.uid)
                              .updateData(
                                  {"myFridge": FieldValue.arrayUnion(output)});
                          setState(
                            () {
                              _listOfIngredientsToAdd.clear();
                            },
                          );
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Homepage()),
                        );
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(10.0),
                      ),
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
