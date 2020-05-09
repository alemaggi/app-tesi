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
Title elemento5 = Title(title: 'Casatiello napoletano', id: '5');
Title elemento6 = Title(title: 'Pasta Sfoglia', id: '6');
Title elemento7 = Title(title: 'Polpettine di tonno e ricotta', id: '7');
Title elemento8 = Title(title: 'Pizzette rosse', id: '8');
Title elemento9 = Title(title: 'Mozzarella in carrozza', id: '9');
Title elemento10 = Title(title: 'Mini calzoni al forno', id: '10');
Title elemento11 =
    Title(title: 'Muffin salati con piselli e prosciutto', id: '11');
Title elemento12 = Title(title: 'Involtini primavera', id: '12');
Title elemento13 = Title(title: 'Polpette di melanzane', id: '13');
Title elemento14 = Title(title: 'Hummus', id: '14');
Title elemento15 = Title(title: 'Torta rustica salata', id: '15');
Title elemento16 = Title(title: 'Cornetti salati', id: '16');
Title elemento17 = Title(title: 'Polpette di spinaci e ricotta', id: '17');
Title elemento18 = Title(title: 'Pizzette di sfoglia', id: '18');
Title elemento19 = Title(title: 'Plumcake salato', id: '19');

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
