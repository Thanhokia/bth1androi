import 'dart:convert';

class SurveyData {
  final double latitude;
  final double longitude;
  final double lightIntensity; // lux
  final double accelerationMagnitude; // sqrt(x² + y² + z²)
  final double magneticFieldMagnitude;
  final DateTime timestamp;

  SurveyData({
    required this.latitude,
    required this.longitude,
    required this.lightIntensity,
    required this.accelerationMagnitude,
    required this.magneticFieldMagnitude,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'lightIntensity': lightIntensity,
      'accelerationMagnitude': accelerationMagnitude,
      'magneticFieldMagnitude': magneticFieldMagnitude,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory SurveyData.fromJson(Map<String, dynamic> json) {
    return SurveyData(
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      lightIntensity: json['lightIntensity'].toDouble(),
      accelerationMagnitude: json['accelerationMagnitude'].toDouble(),
      magneticFieldMagnitude: json['magneticFieldMagnitude'].toDouble(),
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }

  factory SurveyData.fromJsonString(String jsonString) {
    return SurveyData.fromJson(jsonDecode(jsonString));
  }
}


