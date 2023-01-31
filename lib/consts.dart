import 'package:balapp/utils/ticket.dart';
import 'package:flutter/material.dart';

const Color kPurple = Color(0xFF8140C1);
const Color kPurpleLight = Color(0xFFC2A4E2);
const Color kGreen = Color(0xFF69C140);
const Color kGreenLight = Color(0xFF8BDC65);
const Color kRed = Color(0xFFEF3737);
const Color kBlack = Color(0xFF332A22);
const Color kWhite = Color(0xFFF2F2F2);

const int kCodesLength = 4;
const TextStyle h3 = TextStyle(fontSize: 24, fontWeight: FontWeight.bold);
const TextStyle h2 =
    TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -.4);
const TextStyle bodyTitle =
    TextStyle(fontSize: 19, fontWeight: FontWeight.w600, letterSpacing: -.1);
const TextStyle body = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w500,
);

const Map<String, String> postHeaders = {
  "content-type": "application/json",
  "accept": "application/json",
};

String toFirstCharUpperCase(String str) {
  return str.substring(0, 1).toUpperCase() + str.substring(1);
}

const String alreadyUsedString = """Ce ticket a déjà été utilisé
Ne rendez le ticket disponible que si vous êtes sûr·e qu'il s'agit d'une erreur""";
const String alreadySoldString = """Ce ticket a déjà été vendu
Ne modifiez le ticket que si vous êtes sûr·e qu'il s'agit d'une erreur""";
const List<Widget> fakeWidgetArray = [SizedBox()];

List<Ticket> searchAlgorithm(
  SearchBy searchBy,
  List<Ticket> fullList,
  String searchValue,
) {
  searchValue = searchValue.toLowerCase();
  if (searchBy == SearchBy.none) {
    List<Ticket> emptyList =
        fullList.where((Ticket element) => element.prenom == "").toList();
    fullList.removeWhere((element) => element.prenom == "");
    if (searchBy == SearchBy.none) fullList.addAll(emptyList);
    return fullList;
  }
  fullList = fullList.where((Ticket el) {
    if (searchBy.isDropdown == true) {
      return el.toJson()[searchBy.keyValue].toLowerCase() == searchValue.toLowerCase();
    } else {
      String text = el.toJson()[searchBy.keyValue];
      text = text.toLowerCase();
      Map<String, int> lastSeenChar = {};
      int totalCorrectChars = 0;
      for (String char in searchValue.characters) {
        int charIndex = text.indexOf(char, (lastSeenChar[char] ?? -1)+1);
        if (charIndex != -1) {
          lastSeenChar[char] = charIndex;
          totalCorrectChars += 1;
        }
      }
      return totalCorrectChars == searchValue.length;
    }
  }).toList();
  fullList.sort((a,b) {
    int aScore = searchScore(a, searchBy, searchValue);
    int bScore = searchScore(b, searchBy, searchValue);


    return bScore- aScore;
  });
  //TODO: better search would be to then sort by longest string in correct order

  return fullList;
}

int searchScore(Ticket b, SearchBy searchBy, String searchValue){
  String text = b.toJson()[searchBy.keyValue].toLowerCase();
  int maxLength = 0;
  for (int i =0; i<searchValue.length; i++){
    if(text.startsWith(searchValue.substring(0,i+1))) {
      maxLength = i+2; // One bonus point bc the string is correct
      // from the start (not really working)
    } else if(text.contains(searchValue.substring(0,i+1))){
      maxLength = i+1;
    }
  }
  return maxLength;
}

enum SearchBy {
  prenom("Prénom", false, "prenom"),
  id("Id", false, "id"),
  nom("Nom", false, "nom"),
  vendeur("Vendeur", false, "whoEntered"),
  scanneur("Scanneur", false, "whoScanned"),
  salle("Salle", true, "salle"),
  couleur("Couleur", true, "couleur"),
  none("Aucun", false, "none"),
  ;

  const SearchBy(this.value, this.isDropdown, this.keyValue);

  final bool isDropdown;
  final String value;
  final String keyValue;

  @override
  String toString() {
    return toFirstCharUpperCase("Mode: $value");
  }
}
List<String> salleValues = [
  "A", "B", "C", "D", "E", "F"
];
List<String> couleurValues = [
  "violet", "bleu", "vert", "jaune", "orange", "rose"
];
