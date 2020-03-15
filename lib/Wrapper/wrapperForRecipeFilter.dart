import 'package:app_tesi/Recipe/GroupOfRecipesBasedOnCategory/onlyDessertRecipes.dart';
import 'package:app_tesi/Recipe/GroupOfRecipesBasedOnCategory/onlyFavoriteRecipes.dart';
import 'package:app_tesi/Recipe/GroupOfRecipesBasedOnCategory/onlyFirstRecipes.dart';
import 'package:app_tesi/Recipe/GroupOfRecipesBasedOnCategory/onlySecondsRecipes.dart';
import 'package:app_tesi/Recipe/GroupOfRecipesBasedOnCategory/onlyStarterRecipes.dart';
import 'package:app_tesi/Recipe/allRecipe.dart';
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
    }
    if (typeOfRecipeSelected == 2) {
      return OnlyFirstRecipes();
    }
    if (typeOfRecipeSelected == 3) {
      return OnlySecondRecipes();
    }
    if (typeOfRecipeSelected == 4) {
      return OnlyDessertRecipes();
    } else {
      return AllRecipe();
    }
  }
}
