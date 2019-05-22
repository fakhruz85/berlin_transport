/// Data types/models
import 'package:meta/meta.dart';

/// Data type for latitude/longitude
class LatLng {
  const LatLng({this.lat, this.lng});
  final double lat;
  final double lng;
}

/// Data type for locations
class Place {
  const Place({@required this.id, this.name, this.coordinates});
  final String id;
  final String name;
  final LatLng coordinates;

  factory Place.fromJson(Map<String, dynamic> json) {
    assert(json.containsKey('type') &&
        ['location', 'stop'].contains(json['type']));
    if (json['type'] == 'location')
      return Place(
        id: json['id'] as String,
        name: json['name'] as String,
        coordinates: LatLng(
          lat: (json['latitude'] as num).toDouble(),
          lng: (json['longitude'] as num).toDouble(),
        ),
      );
    return Stop.fromJson(json);
  }
}

/// A transport line or route
class Line {
  const Line({
    this.id,
    this.name,
    @required this.type,
  });
  final String id;
  final String name;
  final StopType type;

  factory Line.fromJson(Map<String, dynamic> json) {
    assert(json.containsKey('type') && json['type'] == 'line');
    return Line(
      id: json['id'] as String,
      name: json['name'] as String,
      type: _stopTypeFromString(json['product']),
    );
  }
}

/// Data type for a transportation stop
class Stop extends Place {
  const Stop({
    @required String id,
    @required String name,
    @required LatLng coordinates,
    @required this.types,
    @required this.lines,
  }) : super(id: id, name: name, coordinates: coordinates);
  final List<StopType> types;
  final List<Line> lines;

  /// Converts enums to strings
  Iterable<String> get typesAsStrings =>
      types.map<String>((t) => t.toString().replaceAll(r'StopType.', ''));

  factory Stop.fromJson(Map<String, dynamic> json) {
    assert(json.containsKey('type') && json['type'] == 'stop');
    return Stop(
      id: json['id'] as String,
      name: json['name'] as String,
      coordinates: LatLng(
        lat: (json['location']['latitude'] as num).toDouble(),
        lng: (json['location']['longitude'] as num).toDouble(),
      ),
      types: [
        for (var productKey in json['products'].keys)
          if (json['products'][productKey]) _stopTypeFromString(productKey)
      ],
      lines: [
        for (var line in json['lines']) Line.fromJson(line),
      ],
    );
  }
}

/// Types of transportation stops
enum StopType {
  suburban,
  subway,
  tram,
  bus,
  ferry,
  express,
  regional,
}

/// Converts string to enums
StopType _stopTypeFromString(String str) =>
    StopType.values.firstWhere((e) => e.toString() == 'StopType.$str');