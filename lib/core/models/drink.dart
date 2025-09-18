
/// Abstract base class for all drink types
abstract class Drink {
  final String id;
  final String name;
  final double price;
  final String description;
  final String imageUrl;

  const Drink({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.imageUrl,
  });

  // Factory method to create a drink from JSON
  factory Drink.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    switch (type) {
      case 'coffee':
        return Coffee.fromJson(json);
      case 'tea':
        return Tea.fromJson(json);
      case 'juice':
        return Juice.fromJson(json);
      default:
        throw ArgumentError('Unknown drink type: $type');
    }
  }

  // Convert drink to JSON
  Map<String, dynamic> toJson();

  // Template method for preparing the drink
  String prepare() {
    return 'Preparing $name...';
  }

  // Copy with method for immutability
  Drink copyWith({
    String? id,
    String? name,
    double? price,
    String? description,
    String? imageUrl,
  });
}

/// Concrete implementation for Coffee
class Coffee extends Drink {
  final String roastLevel;
  final bool hasMilk;
  final List<String>? extras;

  const Coffee({
    required String id,
    required String name,
    required double price,
    required String description,
    required String imageUrl,
    this.roastLevel = 'medium',
    this.hasMilk = false,
    this.extras,
  }) : super(
          id: id,
          name: name,
          price: price,
          description: description,
          imageUrl: imageUrl,
        );

  factory Coffee.fromJson(Map<String, dynamic> json) => Coffee(
        id: json['id'] as String,
        name: json['name'] as String,
        price: (json['price'] as num).toDouble(),
        description: json['description'] as String,
        imageUrl: json['imageUrl'] as String,
        roastLevel: json['roastLevel'] as String? ?? 'medium',
        hasMilk: json['hasMilk'] as bool? ?? false,
        extras: json['extras'] != null
            ? List<String>.from(json['extras'] as List)
            : null,
      );

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'type': 'coffee',
        'name': name,
        'price': price,
        'description': description,
        'imageUrl': imageUrl,
        'roastLevel': roastLevel,
        'hasMilk': hasMilk,
        if (extras != null) 'extras': extras,
      };

  @override
  String prepare() {
    var steps = <String>[];
    steps.add('Brewing $name coffee ($roastLevel roast)');
    if (hasMilk) steps.add('Adding steamed milk');
    if (extras != null && extras!.isNotEmpty) {
      steps.add('Adding extras: ${extras!.join(', ')}');
    }
    return steps.join('\n');
  }

  @override
  Coffee copyWith({
    String? id,
    String? name,
    double? price,
    String? description,
    String? imageUrl,
    String? roastLevel,
    bool? hasMilk,
    List<String>? extras,
  }) {
    return Coffee(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      roastLevel: roastLevel ?? this.roastLevel,
      hasMilk: hasMilk ?? this.hasMilk,
      extras: extras ?? this.extras,
    );
  }
}

/// Concrete implementation for Tea
class Tea extends Drink {
  final String teaType;
  final bool hasHoney;
  final bool hasLemon;

  const Tea({
    required String id,
    required String name,
    required double price,
    required String description,
    required String imageUrl,
    required this.teaType,
    this.hasHoney = false,
    this.hasLemon = false,
  }) : super(
          id: id,
          name: name,
          price: price,
          description: description,
          imageUrl: imageUrl,
        );

  factory Tea.fromJson(Map<String, dynamic> json) => Tea(
        id: json['id'] as String,
        name: json['name'] as String,
        price: (json['price'] as num).toDouble(),
        description: json['description'] as String,
        imageUrl: json['imageUrl'] as String,
        teaType: json['teaType'] as String,
        hasHoney: json['hasHoney'] as bool? ?? false,
        hasLemon: json['hasLemon'] as bool? ?? false,
      );

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'type': 'tea',
        'name': name,
        'price': price,
        'description': description,
        'imageUrl': imageUrl,
        'teaType': teaType,
        'hasHoney': hasHoney,
        'hasLemon': hasLemon,
      };

  @override
  String prepare() {
    var steps = <String>[];
    steps.add('Brewing $name tea ($teaType)');
    if (hasHoney) steps.add('Adding honey');
    if (hasLemon) steps.add('Adding lemon');
    return steps.join('\n');
  }

  @override
  Tea copyWith({
    String? id,
    String? name,
    double? price,
    String? description,
    String? imageUrl,
    String? teaType,
    bool? hasHoney,
    bool? hasLemon,
  }) {
    return Tea(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      teaType: teaType ?? this.teaType,
      hasHoney: hasHoney ?? this.hasHoney,
      hasLemon: hasLemon ?? this.hasLemon,
    );
  }
}

/// Concrete implementation for Juice
class Juice extends Drink {
  final List<String> fruits;
  final bool hasIce;
  final bool hasMint;

  const Juice({
    required String id,
    required String name,
    required double price,
    required String description,
    required String imageUrl,
    required this.fruits,
    this.hasIce = true,
    this.hasMint = false,
  }) : super(
          id: id,
          name: name,
          price: price,
          description: description,
          imageUrl: imageUrl,
        );

  factory Juice.fromJson(Map<String, dynamic> json) => Juice(
        id: json['id'] as String,
        name: json['name'] as String,
        price: (json['price'] as num).toDouble(),
        description: json['description'] as String,
        imageUrl: json['imageUrl'] as String,
        fruits: List<String>.from(json['fruits'] as List),
        hasIce: json['hasIce'] as bool? ?? true,
        hasMint: json['hasMint'] as bool? ?? false,
      );

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'type': 'juice',
        'name': name,
        'price': price,
        'description': description,
        'imageUrl': imageUrl,
        'fruits': fruits,
        'hasIce': hasIce,
        'hasMint': hasMint,
      };

  @override
  String prepare() {
    var steps = <String>[];
    steps.add('Preparing $name juice with ${fruits.join(' and ')}');
    if (hasIce) steps.add('Adding ice');
    if (hasMint) steps.add('Garnishing with mint');
    return steps.join('\n');
  }

  @override
  Juice copyWith({
    String? id,
    String? name,
    double? price,
    String? description,
    String? imageUrl,
    List<String>? fruits,
    bool? hasIce,
    bool? hasMint,
  }) {
    return Juice(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      fruits: fruits ?? this.fruits,
      hasIce: hasIce ?? this.hasIce,
      hasMint: hasMint ?? this.hasMint,
    );
  }
}
