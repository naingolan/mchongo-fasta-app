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
    this.description,
    this.employerName = 'Verified Employer',
    this.landmark = 'Easy to access, landmark provided upon match',
    this.duration = 'Approx. 2 - 4 hours',
    this.requirements = const [
      'Punctual and attentive to task instructions',
      'National ID / NIDA verified profile',
      'Respectful and professional communication',
    ],
  });

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
  final String landmark;
  final String duration;
  final List<String> requirements;

  String get fullDescription =>
      description ??
      'Reliable worker needed for this $category task around $distance away. '
      'Payment is held in secure MchongoFasta escrow and released upon your confirmed completion.';

  LatLng get position => LatLng(latitude, longitude);
}

