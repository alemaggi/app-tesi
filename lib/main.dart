import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'Models/user.dart';
import 'Services/auth.dart';
import 'Wrapper/wrapperForFirstPage.dart';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamProvider<User>.value(
      value: AuthService().user,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(primarySwatch: Colors.red),
        home: WrapperForFirstPage(),
      ),
    );
  }
}
