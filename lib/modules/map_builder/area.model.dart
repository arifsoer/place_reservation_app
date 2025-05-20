import 'dart:ui';

class Area {
  final String id;
  double x;
  double y;
  double width;
  double height;
  List<Seat> seats;
  bool isSelected;

  Area({
    required this.id,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    this.isSelected = false,
    this.seats = const [],
  });

  Area.newWithDefault(String id)
    : this(
        id: id,
        x: 100,
        y: 100,
        width: 200,
        height: 200,
        isSelected: false,
        seats: [],
      );

  @override
  String toString() {
    return 'Area{id: $id, x: $x, y: $y, width: $width, height: $height}';
  }

  toJson() {
    return {
      'id': id,
      'x': x,
      'y': y,
      'width': width,
      'height': height,
      'seats': seats.map((e) => e.toJson()).toList(),
    };
  }

  static fromJson(Map<String, dynamic> json) {
    return Area(
      id: json['id'] as String,
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      width: (json['width'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
      seats:
          (json['seats'] as List)
              .map((e) => Seat.fromJson(e as Map<String, dynamic>))
              .toList(),
    );
  }

  void changeRect(Rect newRect) {
    x = newRect.left;
    y = newRect.top;
    width = newRect.width;
    height = newRect.height;
  }
}

class Seat {
  final String id;
  double x;
  double y;
  bool isSelected;

  Seat({
    required this.id,
    required this.x,
    required this.y,
    this.isSelected = false,
  });

  Seat.newWithDefault(String id)
    : this(id: id, x: 10, y: 10, isSelected: false);

  @override
  String toString() {
    return 'Seat{id: $id, x: $x, y: $y}';
  }

  toJson() {
    return {'id': id, 'x': x, 'y': y};
  }

  void changePosition(Offset newPosition) {
    x = newPosition.dx;
    y = newPosition.dy;
  }

  static Seat fromJson(Map<String, dynamic> json) {
    return Seat(
      id: json['id'] as String,
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
    );
  }
}
