/// A prediction market. Immutable; updates produce a new instance via copyWith.
class Market {
  const Market({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.yesPriceCents,
    required this.volumeShares,
    required this.closesAt,
    required this.imageAsset,
    required this.priceHistory,
    this.photoPath,
    this.latitude,
    this.longitude,
  });

  final String id;
  final String title;
  final String description;
  final String category;
  final int yesPriceCents; // 0..100
  final int volumeShares;
  final DateTime closesAt;
  final String imageAsset;
  final List<PricePoint> priceHistory;
  /// Local file path for markets created on-device. Bundled markets use SVG assets.
  final String? photoPath;
  final double? latitude;
  final double? longitude;

  /// Convenience accessor: NO price is the complement of YES price.
  int get noPriceCents => 100 - yesPriceCents;

  bool get hasLocation => latitude != null && longitude != null;


  Market copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    int? yesPriceCents,
    int? volumeShares,
    DateTime? closesAt,
    String? imageAsset,
    List<PricePoint>? priceHistory,
    String? photoPath,
    double? latitude,
    double? longitude,
  }) {
    return Market(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      yesPriceCents: yesPriceCents ?? this.yesPriceCents,
      volumeShares: volumeShares ?? this.volumeShares,
      closesAt: closesAt ?? this.closesAt,
      imageAsset: imageAsset ?? this.imageAsset,
      priceHistory: priceHistory ?? this.priceHistory,
      photoPath: photoPath ?? this.photoPath,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  factory Market.fromJson(Map<String, dynamic> json) {
    return Market(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      yesPriceCents: json['yesPriceCents'] as int,
      volumeShares: json['volumeShares'] as int,
      closesAt: DateTime.parse(json['closesAt'] as String),
      imageAsset: json['imageAsset'] as String,
      priceHistory: (json['priceHistory'] as List<dynamic>)
          .map((dynamic e) => PricePoint.fromJson(e as Map<String, dynamic>))
          .toList(),
      photoPath: json['photoPath'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }
}

class PricePoint {
  const PricePoint({required this.timestamp, required this.yesPriceCents});

  final DateTime timestamp;
  final int yesPriceCents;

  factory PricePoint.fromJson(Map<String, dynamic> json) {
    return PricePoint(
      timestamp: DateTime.parse(json['t'] as String),
      yesPriceCents: json['yes'] as int,
    );
  }
}
