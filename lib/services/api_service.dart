import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:3000/api';

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

  static Stream<Map<String, dynamic>> voteStream({String? centerId}) async* {
    while (true) {
      try {
        final url = centerId != null
            ? '$baseUrl/votes/stream?centerId=$centerId'
            : '$baseUrl/votes/stream';

        final client   = http.Client();
        final request  = http.Request('GET', Uri.parse(url));
        final response = await client.send(request);

        String buffer = '';

        await for (final chunk in response.stream.transform(utf8.decoder)) {
          buffer += chunk;
          buffer  = buffer.replaceAll('\r\n', '\n').replaceAll('\r', '\n');

          while (buffer.contains('\n\n')) {
            final eventEnd = buffer.indexOf('\n\n');
            final event    = buffer.substring(0, eventEnd);
            buffer         = buffer.substring(eventEnd + 2);

            for (final line in event.split('\n')) {
              final trimmed = line.trim();
              if (trimmed.startsWith('data: ')) {
                final jsonStr = trimmed.substring(6).trim();
                if (jsonStr.isNotEmpty) {
                  try {
                    final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
                    yield decoded;
                  } catch (_) {}
                }
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