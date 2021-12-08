import 'dart:io';

import 'package:objectdb/objectdb.dart';
import 'package:objectdb/src/objectdb_storage_filesystem.dart';

final path = Directory.current.path + '/my.db';
final db = ObjectDB(FileSystemStorage(path));


