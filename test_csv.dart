import 'dart:io';
import 'dart:convert';
import 'package:csv/csv.dart';

void main() async {
  final file = File('test_100.csv');
  final csvString = await file.readAsString(encoding: utf8);
  final rows = const CsvToListConverter().convert(csvString);
  print('Total rows: ');
  if (rows.isNotEmpty) {
    print('Row 0 length: ');
    print('Row 1 length: ');
    if (rows.length > 1) {
      print('Row 1: ');
    }
  }
}
