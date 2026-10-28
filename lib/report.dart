class Report {
  final int? id;
  final int? userId;
  final String? userName;
  final String title;
  final String description;
  final String category;
  final String? photoPath;
  final double? latitude;
  final double? longitude;
  final String locationNote;
  final String status;
  final DateTime createdAt;

  Report({
    this.id,
    this.userId,
    this.userName,
    required this.title,
    required this.description,
    required this.category,
    this.photoPath,
    this.latitude,
    this.longitude,
    required this.locationNote,
    this.status = 'Menunggu',
    required this.createdAt,
  });

  static const statuses = ['Menunggu', 'Diproses', 'Selesai'];
  static const categories = [
    'Ruang Kelas', 'Toilet', 'Laboratorium', 'Perpustakaan',
    'Parkiran', 'Listrik/Air', 'Lainnya',
  ];

  Map<String, dynamic> toMap() => {
        'id': id,
        'user_id': userId,
        'title': title,
        'description': description,
        'category': category,
        'photo_path': photoPath,
        'latitude': latitude,
        'longitude': longitude,
        'location_note': locationNote,
        'status': status,
        'created_at': createdAt.toIso8601String(),
      };

  factory Report.fromMap(Map<String, dynamic> m) => Report(
        id: m['id'] as int?,
        userId: m['user_id'] as int?,
        userName: m['user_name'] as String?,
        title: m['title'] as String,
        description: (m['description'] ?? '') as String,
        category: m['category'] as String,
        photoPath: m['photo_path'] as String?,
        latitude: (m['latitude'] as num?)?.toDouble(),
        longitude: (m['longitude'] as num?)?.toDouble(),
        locationNote: (m['location_note'] ?? '') as String,
        status: m['status'] as String,
        createdAt: DateTime.parse(m['created_at'] as String),
      );
}
