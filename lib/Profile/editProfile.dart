import 'dart:io';
import 'package:app_tesi/Profile/profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as Path;

class EditProfile extends StatefulWidget {
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  String _name;
  String _surname;

  final _formKey = GlobalKey<FormState>();

  //Per il caricamento dell' immagine del profilo
  File _image;
  String _uploadedFileURL;

  //Faccio l'update di nome e cognome
  _updateUserInfo(String userID) async {
    await Firestore.instance.collection('users').document(userID).updateData({
      'name': _name,
      'surname': _surname,
      'profilePicUrl': _uploadedFileURL,
    });
  }

  Future chooseFile() async {
    await ImagePicker.pickImage(source: ImageSource.gallery).then((image) {
      setState(() {
        _image = image;
      });
    });
  }

  Future uploadFile() async {
    StorageReference storageReference = FirebaseStorage.instance
        .ref()
        .child('profilePic/${Path.basename(_image.path)}}');
    StorageUploadTask uploadTask = storageReference.putFile(_image);
    await uploadTask.onComplete;
    print('File Uploaded');
    storageReference.getDownloadURL().then((fileURL) {
      setState(() {
        _uploadedFileURL = fileURL;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(255, 0, 87, 1),
        title: Text("Edit Profile"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(
                  top: MediaQuery.of(context).size.width * 0.05,
                  bottom: MediaQuery.of(context).size.width * 0.02),
              width: MediaQuery.of(context).size.width * 0.8,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Edit Your Profile",
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
              width: MediaQuery.of(context).size.width * 0.8,
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      keyboardType: TextInputType.text,
                      controller: null, //TODO: Fare controller
                      decoration: InputDecoration(
                        hintText: "Name",
                      ),
                      validator: (val) =>
                          val.isEmpty ? 'Enter your name' : null,
                      onChanged: (val) {
                        setState(() {
                          _name = val;
                        });
                      },
                    ),
                    Container(
                      height: MediaQuery.of(context).size.width * 0.05,
                    ),
                    TextFormField(
                      keyboardType: TextInputType.text,
                      controller: null, //TODO: Fare controller
                      decoration: InputDecoration(
                        hintText: "Surname",
                      ),
                      validator: (val) =>
                          val.isEmpty ? 'Enter your surname' : null,
                      onChanged: (val) {
                        setState(() {
                          _surname = val;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            //TEST
            Center(
              child: Column(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(
                      top: MediaQuery.of(context).size.width * 0.05,
                    ),
                    child: Text(
                      'Selected Image',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  _image != null
                      ? Image.asset(
                          _image.path,
                          height: 150,
                        )
                      : Container(
                          child: Text("No image selected"),
                        ),
                  Container(
                    margin: EdgeInsets.only(
                      top: MediaQuery.of(context).size.width * 0.05,
                    ),
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: MediaQuery.of(context).size.width * 0.12,
                    child: _image == null
                        ? FlatButton(
                            child: Text(
                              'Choose File',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 22),
                            ),
                            onPressed: chooseFile,
                            color: Color.fromRGBO(255, 0, 87, 1),
                          )
                        : Container(),
                  ),
                ],
              ),
            ),

            //FINE TEST
            Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.width * 0.12,
              margin: EdgeInsets.only(
                top: MediaQuery.of(context).size.width * 0.1,
              ),
              child: FlatButton(
                child: Text(
                  "Submit",
                  style: TextStyle(
                      color: Color.fromRGBO(255, 0, 87, 1),
                      fontSize: 22,
                      fontWeight: FontWeight.bold),
                ),
                onPressed: () async {
                  uploadFile();
                  FirebaseUser user = await FirebaseAuth.instance.currentUser();
                  var userID = user.uid;
                  if (userID != null) {
                    _updateUserInfo(userID);
                  }
                  setState(() {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Profile()),
                    );
                  });
                },
                shape: RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(10.0),
                  side: BorderSide(
                    color: Color.fromRGBO(255, 0, 87, 1),
                    width: 3,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
