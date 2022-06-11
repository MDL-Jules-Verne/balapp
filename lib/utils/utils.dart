import 'package:balapp/utils/db.dart';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart';
const csvToList =  CsvToListConverter();

Future<List<List>> readAndParseDb() async {
  String db = await rootBundle.loadString('db/db.csv');
  return csvToList.convert(db);
}

