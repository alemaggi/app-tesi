class User {
  //Questa classe la uso per convertire gli oggetti di tipo firebase user auth in oggetti di
  //tipo user in questo modo sono più leggeri e mi porto dietro solo lo uid che è l'unica cosa
  //che mi serve
  final String uid;

  User({this.uid});
}
