import 'dart:io';

import 'package:uuid/uuid.dart';

const uuid = Uuid(); //creating uuid object

//model for location

class PlaceLocation {
  const PlaceLocation({
    required this.latitude,
    required this.longitude,
    required this.address,
  });
  final double latitude;
  final double longitude;
  final String address;
}

class Place {
  Place({
    required this.title,
    required this.image,
    required this.location,
    String? id,
  }) : id =id ?? uuid.v4(); //calling the method on object to generate an id.
//overwriting the automatically generated id.

  final String
      id; //we will use an initializer list ,and use an extra package for managing that id.

  final String title;
  final File image;
  final PlaceLocation location;
}
