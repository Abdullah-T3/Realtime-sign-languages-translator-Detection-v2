import 'dart:convert';
import 'package:http/http.dart' as http;

class TranslationResponse {
  final String formedText;
  final String mostCommonGesture;
  final List<GesturePrediction> predictions;
  final List<RawPrediction> rawPredictions;
  final double videoDuration;

  TranslationResponse({
    required this.formedText,
    required this.mostCommonGesture,
    required this.predictions,
    required this.rawPredictions,
    required this.videoDuration,
  });

  factory TranslationResponse.fromJson(Map<String, dynamic> json) {
    return TranslationResponse(
      formedText: json['formed_text'] as String,
      mostCommonGesture: json['most_common_gesture'] as String,
      predictions:
          (json['predictions'] as List)
              .map((p) => GesturePrediction.fromJson(p))
              .toList(),
      rawPredictions:
          (json['raw_predictions'] as List)
              .map((p) => RawPrediction.fromJson(p))
              .toList(),
      videoDuration: json['video_duration'] as double,
    );
  }
}

class GesturePrediction {
  final double duration;
  final double endTime;
  final String gesture;
  final double startTime;

  GesturePrediction({
    required this.duration,
    required this.endTime,
    required this.gesture,
    required this.startTime,
  });

  factory GesturePrediction.fromJson(Map<String, dynamic> json) {
    return GesturePrediction(
      duration: json['duration'] as double,
      endTime: json['end_time'] as double,
      gesture: json['gesture'] as String,
      startTime: json['start_time'] as double,
    );
  }
}

class RawPrediction {
  final double confidence;
  final String gesture;
  final double time;

  RawPrediction({
    required this.confidence,
    required this.gesture,
    required this.time,
  });

  factory RawPrediction.fromJson(Map<String, dynamic> json) {
    return RawPrediction(
      confidence: json['confidence'] as double,
      gesture: json['gesture'] as String,
      time: json['time'] as double,
    );
  }
}

class TranslatorService {
  static const String _baseUrl = 'http://13.60.68.166:5000';

  Future<TranslationResponse> predictGestures(String videoData) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/predict'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'video_data': videoData}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return TranslationResponse.fromJson(data);
      } else {
        throw Exception('Failed to predict gestures: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error predicting gestures: $e');
    }
  }
}
