//classe che definisce i singoli titoli

class Title {
  String title;
  String id;

  //costruttore
  Title({
    this.title,
    this.id,
  });

  String getTitle() {
    return title;
  }

  String getId() {
    return id;
  }
}

Title elemento0 = Title(title: 'Focaccia (fügassa) alla genovese', id: '0');
Title elemento1 = Title(title: 'Piadina Romagnola', id: '1');
Title elemento2 = Title(title: 'Taralli', id: '2');
Title elemento3 = Title(title: 'Crocchette di patate', id: '3');
Title elemento4 = Title(title: 'Arancini di riso', id: '4');
Title elemento5 = Title(title: 'Gnocchi di patate', id: '5');
Title elemento6 = Title(title: 'Spaghetti all Amatriciana', id: '6');
Title elemento7 = Title(title: 'Ravioli cinesi al vapore', id: '7');
Title elemento8 = Title(title: 'Spaghetti Cacio e Pepe', id: '8');
Title elemento9 = Title(title: 'Ravioli ricotta e spinaci', id: '9');
Title elemento10 = Title(title: 'Polpette al sugo', id: '10');
Title elemento11 = Title(title: 'Gateau di patate', id: '11');
Title elemento12 = Title(title: 'Pollo alle mandorle', id: '12');
Title elemento13 = Title(title: 'Polpettine di tonno e ricotta', id: '13');
Title elemento14 = Title(title: 'Spezzatino di manzo', id: '14');
Title elemento15 = Title(title: 'Torta tenerina', id: '15');
Title elemento16 = Title(title: 'Nutellotti', id: '16');
Title elemento17 = Title(title: 'Brownies', id: '17');
Title elemento18 = Title(title: 'Crepe alla Nutella', id: '18');
Title elemento19 = Title(title: 'Crema pasticcera', id: '19');

List<Title> titleList = [
  elemento0,
  elemento1,
  elemento2,
  elemento3,
  elemento4,
  elemento5,
  elemento6,
  elemento7,
  elemento8,
  elemento9,
  elemento10,
  elemento11,
  elemento12,
  elemento13,
  elemento14,
  elemento15,
  elemento16,
  elemento17,
  elemento18,
  elemento19,
];

List<String> listOfTitle = [];

void loadElementToSearchList() {
  for (int i = 0; i < titleList.length; i++) {
    listOfTitle.add((titleList[i].title).toString());
    //print(listOfTitle[i]);
    //print("Added: " + titleList[i].title+" ID: "+titleList[i].id);
  }
}
