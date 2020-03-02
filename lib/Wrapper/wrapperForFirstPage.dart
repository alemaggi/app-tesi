import 'package:app_tesi/HomePage/homepage.dart';
import 'package:app_tesi/Login/login.dart';
import 'package:app_tesi/Models/user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WrapperForFirstPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);

    //Return either Home or login page
    if (user == null) {
      return Login();
    } else {
      return Homepage();
    }
  }
}
