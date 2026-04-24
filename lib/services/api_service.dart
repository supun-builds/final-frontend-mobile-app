import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:3000/api'; // Android emulator
  // static const String baseUrl = 'http://localhost:3000/api'; // iOS simulator

  // ── fetch all centers for dropdown ──────────────────────────────
  static Future<List<Map<String, dynamic>>> fetchCenters() async {
    final response = await http
        .get(Uri.parse('$baseUrl/votes/centers'))
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['centers']);
    }
    throw Exception('Failed to load centers: ${response.statusCode}');
  }

  // ── SSE stream — null centerId = overall, or pass 'CTR001' etc ──
  static Stream<Map<String, dynamic>> voteStream({String? centerId}) async* {
    while (true) {
      try {
        final url = centerId != null
            ? '$baseUrl/votes/stream?centerId=$centerId'
            : '$baseUrl/votes/stream';

        final client  = http.Client();
        final request = http.Request('GET', Uri.parse(url));
        final response = await client.send(request);

        await for (final chunk in response.stream.transform(utf8.decoder)) {
          for (final line in chunk.split('\n')) {
            if (line.startsWith('data: ')) {
              final jsonStr = line.substring(6).trim();
              if (jsonStr.isNotEmpty) {
                yield jsonDecode(jsonStr) as Map<String, dynamic>;
              }
            }
          }
        }
        client.close();
      } catch (_) {
        await Future.delayed(const Duration(seconds: 5));
      }
    }
  }
}