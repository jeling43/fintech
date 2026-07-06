import 'package:drift/drift.dart';
import 'package:drift/web.dart';

QueryExecutor openDatabaseConnection() {
  return WebDatabase('fintech_investigator');
}
