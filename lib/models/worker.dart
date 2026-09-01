class WorkerModel {
  const WorkerModel({
    required this.id,
    required this.name,
    required this.category,
    required this.rating,
    required this.completedJobs,
    required this.verified,
    required this.area,
    this.phone,
    this.distanceKm,
    this.skills = const [],
    this.bio,
    this.hourlyRateTzs,
  });

  factory WorkerModel.fromJson(Map<String, dynamic> json) {
    return WorkerModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? 'Worker',
      category: json['category'] ?? 'General',
      rating: (json['rating'] as num?)?.toDouble() ?? 4.8,
      completedJobs: json['completedJobs'] is int
          ? json['completedJobs']
          : int.tryParse(json['completedJobs']?.toString() ?? '0') ?? 0,
      verified: json['verified'] == true,
      area: json['area'] ?? 'Dar es Salaam',
      phone: json['phone'],
      distanceKm: (json['distanceKm'] as num?)?.toDouble() ?? 1.5,
      skills: (json['skills'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      bio: json['bio'],
      hourlyRateTzs: json['hourlyRateTzs'] is int
          ? json['hourlyRateTzs']
          : int.tryParse(json['hourlyRateTzs']?.toString() ?? '0'),
    );
  }

  final String id;
  final String name;
  final String category;
  final double rating;
  final int completedJobs;
  final bool verified;
  final String area;
  final String? phone;
  final double? distanceKm;
  final List<String> skills;
  final String? bio;
  final int? hourlyRateTzs;
}
