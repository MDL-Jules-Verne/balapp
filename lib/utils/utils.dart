import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

// const csvToList = CsvToListConverter();

Future<List<List<String>>> readAndParseDb() async {
  String path = (await getApplicationDocumentsDirectory()).path;
  bool fileExists = await File('$path/db.csv').exists();

  // If file exists retrieve contents from it, else read from assets and create the file
  if (fileExists) {
    String actualDb = await File('$path/db.csv').readAsString();
    return readCsv(actualDb);
  } else {
    String db = await rootBundle.loadString('db/db.csv');
    await File('$path/db.csv').writeAsString(db);
    return readCsv(db);
  }
}

Future<List<List<String>>> readCsv(String file) async {
  // Assume EOL is CRLF
  List<String> rows = file.split("\r\n");

  // Adapt if EOL is LF
  if (rows.length <= 1) {
    rows = file.split("\n");
  }

  List<List<String>> output = [];
  for (String row in rows) {
    output.add(row.split(","));
  }
  if(output.last.length <= 1){
    output.removeLast();
  }
  return output;
}
