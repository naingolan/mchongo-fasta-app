import 'package:google_maps_flutter/google_maps_flutter.dart';

class Job {
  const Job({
    required this.title,
    required this.category,
    required this.pay,
    required this.distance,
    required this.time,
    required this.rating,
    required this.verified,
    required this.latitude,
    required this.longitude,
    this.id,
    this.description,
    this.employerName = 'Verified Employer',
    this.employerPhone,
    this.landmark = 'Easy to access, landmark provided upon match',
    this.duration = 'Approx. 2 - 4 hours',
    this.requirements = const [
      'Punctual and attentive to task instructions',
      'National ID / NIDA verified profile',
      'Respectful and professional communication',
    ],
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    final budgetNum = json['budgetTzs'] ?? json['budget'];
    final budgetStr = budgetNum != null
        ? 'TZS ${budgetNum is num ? budgetNum.toInt() : budgetNum}'
        : (json['pay'] ?? 'TZS 25,000');

    final area = json['area'] ?? json['location'] ?? 'Dar es Salaam';

    return Job(
      id: json['id']?.toString(),
      title: json['title'] ?? 'Task in $area',
      category: json['category'] ?? 'Domestic',
      pay: budgetStr,
      distance: json['distance'] ?? area.toString().split(',').first,
      time: json['scheduledFor'] ?? json['time'] ?? 'Today',
      rating: json['rating']?.toString() ?? '4.9',
      verified: json['verified'] == true || json['verified'] == null,
      latitude: (json['latitude'] as num?)?.toDouble() ?? -6.7750,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 39.2450,
      description: json['description'],
      employerName: json['employerName'] ?? 'Verified Employer',
      employerPhone: json['employerPhone'],
      duration: json['duration'] ?? 'Approx. 2 - 4 hours',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'category': category,
      'pay': pay,
      'area': distance,
      'scheduledFor': time,
      'latitude': latitude,
      'longitude': longitude,
      'description': description,
      'employerName': employerName,
      'employerPhone': employerPhone,
      'duration': duration,
    };
  }

  final String? id;
  final String title;
  final String category;
  final String pay;
  final String distance;
  final String time;
  final String rating;
  final bool verified;
  final double latitude;
  final double longitude;
  final String? description;
  final String employerName;
  final String? employerPhone;
  final String landmark;
  final String duration;
  final List<String> requirements;

  String get fullDescription =>
      description ??
      'Reliable worker needed for this $category task around $distance away. '
      'Payment is held in secure MchongoFasta escrow and released upon your confirmed completion.';

  LatLng get position => LatLng(latitude, longitude);
}
