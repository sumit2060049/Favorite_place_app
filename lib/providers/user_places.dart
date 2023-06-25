import 'dart:io';

import 'package:path_provider/path_provider.dart' as syspaths;
import 'package:favorite_places/models/place.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sqlite_api.dart';

Future<Database> _getDatabase() async {
  final dbpath = await sql.getDatabasesPath();
  final db = await sql.openDatabase(
    path.join(dbpath, 'places.db'),
    onCreate: (db, version) {
      return db.execute(
          'CREATE TABLE user_places(id TEXT PRIMARY KEY, title TEXT,image TEXT, lat REAL,lng REAL,address TEXT )');
    },
    version:
        1, //theoretically, you should increase this whenever you change the query so that a new database file would be created if you would change the structure of the database.
  );
  return db;
}

class UserPlacesNotifier extends StateNotifier<List<Place>> {
  UserPlacesNotifier()
      : super(
            const []); //initializer list //super for passing our initial state to the parent class

  //loading data from the database,

  Future<void> loadplaces() async {
    final db = await _getDatabase();

    final data = await db.query('user_places');

    final places = data
        .map(
          (row) => Place(
            id: row['id'] as String,
            title: row['title'] as String,
            image: File(row['image'] as String),
            location: PlaceLocation(
              latitude: row['lat'] as double,
              longitude: row['lng'] as double,
              address: row['address'] as String,
            ),
          ),
        )
        .toList();

    state = places;
  }

  void addPlace(String title, File image, PlaceLocation location) async {
    final appDir = await syspaths.getApplicationDocumentsDirectory();
    final filename = path.basename(image.path);
    final copiedImage = await image.copy('${appDir.path}/$filename');

    final newPlace =
        Place(title: title, image: copiedImage, location: location);

    // final dbpath = await sql.getDatabasesPath();
    // final db = await sql.openDatabase(
    //   path.join(dbpath, 'places.db'),
    //   onCreate: (db, version) {
    //     return db.execute(
    //         'CREATE TABLE user_places(id TEXT PRIMARY KEY, title TEXT,image TEXT, lat REAL,lng REAL,address TEXT )');
    //   },
    //   version:
    //       1, //theoretically, you should increase this whenever you change the query so that a new database file would be created if you would change the structure of the database.
    // );

    //Now we can work with the database.

    final db = await _getDatabase();

    db.insert(
      'user_places',
      {
        'id': newPlace.id,
        'title': newPlace.title,
        'image': newPlace.image.path,
        'lat': newPlace.location.latitude,
        'lng': newPlace.location.longitude,
        'address': newPlace.location.address,
      },
    );

    state = [newPlace, ...state];
  } //with this we have a method that will update the state And that's all we need for now.
}

//Now we also need to add a provider.

final userPlacesProvider =
    StateNotifierProvider<UserPlacesNotifier, List<Place>>(
  (ref) => UserPlacesNotifier(),
);
