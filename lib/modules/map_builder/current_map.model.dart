import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:place_reservation/modules/map_builder/area.model.dart';

class CurrentMap {
  final List<CurrentLevel> levels;
  final DateTime createdAt;

  CurrentMap({required this.levels, required this.createdAt});

  toJson() {
    return {
      'levels': levels.map((level) => level.toJson()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  static CurrentMap fromJson(Map<String, dynamic> json) {
    return CurrentMap(
      levels:
          (json['levels'] as List)
              .map((level) => CurrentLevel.fromJson(level))
              .toList(),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }
}

class Seats {
  final List<String> seats;
  final DateTime createdAt;

  Seats({required this.seats, required this.createdAt});

  toJson() {
    return {'seats': seats, 'createdAt': Timestamp.fromDate(createdAt)};
  }

  static Seats fromJson(Map<String, dynamic> json) {
    return Seats(
      seats: List<String>.from(json['seats']),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }
}

class CurrentLevel {
  final String name;
  final List<CurrentArea> areas;

  CurrentLevel({required this.name, required this.areas});

  toJson() {
    return {'name': name, 'areas': areas.map((area) => area.toJson()).toList()};
  }

  static CurrentLevel fromJson(Map<String, dynamic> json) {
    return CurrentLevel(
      name: json['name'] as String,
      areas:
          (json['areas'] as List)
              .map((area) => CurrentArea.fromJson(area))
              .toList(),
    );
  }
}

class CurrentArea {
  final String name;
  final List<CurrentSeat> seats;
  final double width;
  final double height;
  final double x;
  final double y;

  CurrentArea({
    required this.name,
    required this.seats,
    required this.width,
    required this.height,
    required this.x,
    required this.y,
  });

  toJson() {
    return {
      'name': name,
      'seats': seats.map((seat) => seat.toJson()).toList(),
      'width': width,
      'height': height,
      'x': x,
      'y': y,
    };
  }

  static CurrentArea fromJson(Map<String, dynamic> json) {
    return CurrentArea(
      name: json['name'] as String,
      seats:
          (json['seats'] as List)
              .map((seat) => CurrentSeat.fromJson(seat))
              .toList(),
      width: (json['width'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
    );
  }

  static CurrentArea fromArea(Area area) {
    return CurrentArea(
      name: area.id,
      seats: area.seats.map((seat) => CurrentSeat.fromSeat(seat)).toList(),
      width: area.width,
      height: area.height,
      x: area.x,
      y: area.y,
    );
  }
}

class CurrentSeat {
  final String name;
  final double x;
  final double y;

  CurrentSeat({required this.name, required this.x, required this.y});

  toJson() {
    return {'name': name, 'x': x, 'y': y};
  }

  static CurrentSeat fromJson(Map<String, dynamic> json) {
    return CurrentSeat(
      name: json['name'] as String,
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
    );
  }

  static CurrentSeat fromSeat(Seat seat) {
    return CurrentSeat(name: seat.id, x: seat.x, y: seat.y);
  }
}
