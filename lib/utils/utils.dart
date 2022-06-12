import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

const csvToList = CsvToListConverter();

Future<List<List>> readAndParseDb() async {
  String path = (await getApplicationDocumentsDirectory()).path;
  bool fileExists = await File('$path/db.csv').exists();

  // If file exists retrieve contents from it, else read from assets and create the file
  if (fileExists) {
    String actualDb = await File('$path/db.csv').readAsString();
    return csvToList.convert(actualDb);
  } else {
    String db = await rootBundle.loadString('db/db.csv');
    await File('$path/db.csv').writeAsString(db);
    return csvToList.convert(db);
  }
}
