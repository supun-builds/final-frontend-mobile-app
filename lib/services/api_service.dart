import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/candidate.dart';

class ApiService {
  // 🔧 Change this to your server's IP when testing on a real device
  static const String baseUrl = 'http://10.0.2.2:3000/api'; // Android emulator
  // static const String baseUrl = 'http://localhost:3000/api'; // iOS simulator

  // One-shot fetch
  static Future<Map<String, dynamic>> fetchVotes() async {
    final response = await http
        .get(Uri.parse('$baseUrl/votes'))
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to load votes: ${response.statusCode}');
  }

  // Server-Sent Events stream — auto-reconnects on error
  static Stream<Map<String, dynamic>> voteStream() async* {
    while (true) {
      try {
        final client   = http.Client();
        final request  = http.Request('GET', Uri.parse('$baseUrl/votes/stream'));
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
        await Future.delayed(const Duration(seconds: 5)); // retry delay
      }
    }
  }
}