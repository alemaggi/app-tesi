import 'package:app_tesi/Recipe/allRecipe.dart';
import 'package:app_tesi/Recipe/onlyFavoriteRecipes.dart';
import 'package:flutter/material.dart';

class WrapperForRecipeFilter extends StatelessWidget {
  final bool soloPreferiti;

  WrapperForRecipeFilter({Key key, @required this.soloPreferiti})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    //Return either Home or login page
    if (soloPreferiti == true) {
      return OnlyFavoriteRecipes();
    } else {
      return AllRecipe();
    }
  }
}
