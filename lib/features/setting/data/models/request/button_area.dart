class ButtonArea {
  double x; // 0 - 1
  double y; // 0 - 1
  double width; // 0 - 1
  double height; // 0 - 1
  String function;

  ButtonArea({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.function,
  });

  Map<String, dynamic> toJson() => {
    'x': x,
    'y': y,
    'width': width,
    'height': height,
    'function': function,
  };

  factory ButtonArea.fromJson(Map<String, dynamic> json) => ButtonArea(
    x: (json['x'] as num).toDouble(),
    y: (json['y'] as num).toDouble(),
    width: (json['width'] as num).toDouble(),
    height: (json['height'] as num).toDouble(),
    function: json['function'] as String,
  );
}
