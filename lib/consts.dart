import 'dart:async';

import 'package:balapp/utils/ticket.dart';
import 'package:flutter/material.dart';

const Color kPurple = Color(0xFF8040C1);
const Color kPurpleLight = Color(0xFFC2A4E2);
const Color kGreen = Color(0xFF69C140);
const Color kGreenLight = Color(0xFF8BDC65);
const Color kRed = Color(0xFFFF1F41);
const Color kOrange = Color(0xFFFFA621);
const Color kYellow = Color(0xFFFFDD29);
const Color kPink = Color(0xFFFC5D96);
const Color kBlue = Color(0xFF3A97ED);
const Color kBlack = Color(0xFF332A22);
const Color kWhite = Color(0xFFF2F2F2);

const int kCodesLength = 4;
const TextStyle h3 = TextStyle(fontSize: 24, fontWeight: FontWeight.bold);
const TextStyle h2 = TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -.4);
const TextStyle bodyTitle = TextStyle(fontSize: 19, fontWeight: FontWeight.w600, letterSpacing: -.1);
const TextStyle body = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w500,
);
const TextStyle bodyBold = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w800,
);

const Map<String, String> postHeaders = {
  "content-type": "application/json",
  "accept": "application/json",
};

String toFirstCharUpperCase(String str) {
  return str.substring(0, 1).toUpperCase() + str.substring(1);
}

const String alreadyUsedString = """Ce ticket a déjà été scanné
Ne rendez le ticket disponible que si vous êtes sûr·e qu'il s'agit d'une erreur""";
const String alreadySoldString = """Ce ticket a déjà été vendu
Ne modifiez le ticket que si vous êtes sûr·e qu'il s'agit d'une erreur""";
const List<Widget> fakeWidgetArray = [SizedBox()];

class SearchData extends ChangeNotifier {
  SearchData(this.searchBy, this.searchText, this.searchResults, [this.loading = true]);

  void updateSearch(List<Ticket> searchResults) {
    this.searchResults = searchResults;
    notifyListeners();
  }

  List<Ticket> searchResults;
  SearchBy searchBy;
  bool loading;
  String searchText;

  void changeSearchParams(SearchBy searchBy, String searchText, {bool notify = true}) {
    print("test");
    this.searchBy = searchBy;
    this.searchText = searchText;
    if (notify) notifyListeners();
  }

  void changeLoadingState(bool loading) {
    this.loading = loading;
    notifyListeners();
  }
}

List<Ticket> searchAlgorithm(SearchBy searchBy, List<Ticket> fullList, String searchValue,
    [bool showUnregisteredTickets = true]) {
  if (!showUnregisteredTickets) {
    fullList.removeWhere((element) => element.prenom == "");
  }
  searchValue = searchValue.toLowerCase();
  if (searchBy == SearchBy.none) {
    List<Ticket> emptyList = fullList.where((Ticket element) => element.prenom == "").toList();
    fullList.removeWhere((element) => element.prenom == "");
    if (searchBy == SearchBy.none) fullList.addAll(emptyList);
    return fullList;
  }

  fullList = fullList.where((Ticket el) {
    if (searchBy.isDropdown == true) {
      return el.toJson()[searchBy.keyValue].toLowerCase() == searchValue.toLowerCase();
    } else {

      var x = [SearchBy.prenom, SearchBy.id, SearchBy.nom];
      bool hasFoundOne = false;
      for(int i=0; i< (searchBy.isGlobal ? x.length : 1); i++) {
        SearchBy searchBy1;
        if(searchBy.isGlobal) {
          searchBy1 = x[i];
        } else {
          searchBy1 = searchBy;
        }
        String text = el.toJson()[searchBy1.keyValue];
        text = text.toLowerCase();
        Map<String, int> lastSeenChar = {};
        int totalCorrectChars = 0;
        for (String char in searchValue.characters) {
          int charIndex = text.indexOf(char, (lastSeenChar[char] ?? -1) + 1);
          if (charIndex != -1) {
            lastSeenChar[char] = charIndex;
            totalCorrectChars += 1;
          }
        }
        if(totalCorrectChars == searchValue.length){
          hasFoundOne = true;
          break;
        }
      }
      return hasFoundOne;
    }
  }).toList();
  fullList.sort((a, b) {
    int aScore = (searchScore(a, searchBy, searchValue) * 10).toInt();
    int bScore = (searchScore(b, searchBy, searchValue) * 10).toInt();
    return bScore - aScore;
  });

  return fullList;
}

double searchScore(Ticket b, SearchBy searchBy, String searchValue) {
  var x = [SearchBy.prenom, SearchBy.id, SearchBy.nom];
  double score  = 0;
  for(int i=0; i< (searchBy.isGlobal ? x.length : 1); i++) {
    SearchBy searchBy1;
    if(searchBy.isGlobal) {
      searchBy1 = x[i];
    } else {
      searchBy1 = searchBy;
    }
  String text = b.toJson()[searchBy1.keyValue].toLowerCase();
    double maxLength = 0;
    for (int i = 0; i < searchValue.length; i++) {
      if (text.startsWith(searchValue.substring(0, i + 1))) {
        maxLength = i + 2.1; // One bonus point bc the string is correct
        // from the start (not really working)
      } else if (text.contains(searchValue.substring(0, i + 1))) {
        maxLength = i + 1;
      }
    }
    score += maxLength;
  }
  return score;
}

enum SearchBy {
  global("Global", false, "global", isGlobal: true),
  prenom("Prénom", false, "prenom"),
  id("Id", false, "id"),
  nom("Nom", false, "nom"),
  vendeur("Vendeur", false, "whoEntered"),
  scanneur("Scanneur", false, "whoScanned"),
  salle("Salle", true, "salle"),
  couleur("Couleur", true, "couleur"),
  none("Aucun", false, "none"),
  ;

  const SearchBy(this.value, this.isDropdown, this.keyValue, {this.isGlobal = false});

  final bool isDropdown;
  final String value;
  final String keyValue;
  final bool isGlobal;

  @override
  String toString() {
    return toFirstCharUpperCase("Mode: $value");
  }
}

List<String> salleValues = ["A", "B", "C", "D", "E", "F"];
List<String> couleurValues = ["violet", "bleu", "vert", "jaune", "orange", "rose"];

Map<String, Color> stringToColor = {
  "violet": kPurple,
  "bleu": kBlue,
  "vert": kGreen,
  "jaune": kYellow,
  "orange": kOrange,
  "rose": kPink,
};

List<String> kNiveaux = [
  // "Niveau",
  "2nde",
  "PG",
  "PSTMG",
  "TG",
  "TSTMG"
];
