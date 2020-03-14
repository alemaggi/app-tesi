import 'package:app_tesi/Recipe/allRecipe.dart';
import 'package:app_tesi/Recipe/onlyFavoriteRecipes.dart';
import 'package:app_tesi/Recipe/onlyStarterRecipes.dart';
import 'package:flutter/material.dart';

class WrapperForRecipeFilter extends StatelessWidget {
  final bool soloPreferiti;
  final int typeOfRecipeSelected;

  WrapperForRecipeFilter(
      {Key key,
      @required this.soloPreferiti,
      @required this.typeOfRecipeSelected})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    //Return either Home or login page
    if (soloPreferiti == true) {
      return OnlyFavoriteRecipes();
    }
    if (typeOfRecipeSelected == 1) {
      return OnlyStarterRecipes();
    } else {
      return AllRecipe();
    }
  }
}
