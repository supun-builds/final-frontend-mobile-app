import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:math';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

class ApiService {
  /// Set to true to use realistic sample data for screenshots/demos.
  /// Set to false to connect to your live backend API.
  static const bool useMockData = true;

  // Use 10.0.2.2 for Android emulator, localhost for Web/Desktop
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:3000/api';
    try {
      if (Platform.isAndroid) return 'http://10.0.2.2:3000/api';
    } catch (_) {}
    return 'http://localhost:3000/api';
  }

  // ──────────────── Sample Data for Screenshots & Demos ────────────────

  static final List<Map<String, dynamic>> _mockCenters = [
    {'centerId': 'CTR-001', 'centerName': 'Anuradhapura / Anuradhapura East (C)'},
    {'centerId': 'CTR-002', 'centerName': 'Colombo / Central Colombo (A)'},
    {'centerId': 'CTR-003', 'centerName': 'Gampaha / Negombo (B)'},
    {'centerId': 'CTR-004', 'centerName': 'Kandy / Senkadagala (D)'},
    {'centerId': 'CTR-005', 'centerName': 'Galle / Bope-Poddala (E)'},
    {'centerId': 'CTR-006', 'centerName': 'Kurunegala / Mawathagama (F)'},
    {'centerId': 'CTR-007', 'centerName': 'Jaffna / Nallur (G)'},
  ];

  static Map<String, int> _mockVoteCounts = {
    'C001': 5716971, // Anura Kumara Dissanayake
    'C002': 4530902, // Sajith Premadasa
    'C003': 2299767, // Ranil Wickremesinghe
    'C004': 342781,  // Namal Rajapaksa
    'C005': 122396,  // Dilith Jayaweera
    'C006': 86450,   // Wijeyadasa Rajapakshe
  };

  static final List<Map<String, dynamic>> _candidateDefinitions = [
    {
      'candidateId': 'C001',
      'candidateName': 'අනුර කුමාර දිසානායක (Anura Dissanayake)',
      'party': "National People's Power (ජාතික ජන බලවේගය)",
      'partyColor': '#9E1B32',
    },
    {
      'candidateId': 'C002',
      'candidateName': 'සජිත් ප්‍රේමදාස (Sajith Premadasa)',
      'party': 'Samagi Jana Balawegaya (සමගි ජන බලවේගය)',
      'partyColor': '#00A859',
    },
    {
      'candidateId': 'C003',
      'candidateName': 'රනිල් වික්‍රමසිංහ (Ranil Wickremesinghe)',
      'party': 'New Democratic Front (නව ප්‍රජාතන්ත්‍රවාදී පෙරමුණ)',
      'partyColor': '#2E86AB',
    },
    {
      'candidateId': 'C004',
      'candidateName': 'නාමල් රාජපක්ෂ (Namal Rajapaksa)',
      'party': 'Sri Lanka Podujana Peramuna (ශ්‍රී ලංකා පොදුජන පෙරමුණ)',
      'partyColor': '#800020',
    },
    {
      'candidateId': 'C005',
      'candidateName': 'දිලිත් ජයවීර (Dilith Jayaweera)',
      'party': 'Mawbima Janatha Pakshaya (මව්බිම ජනතා පක්ෂය)',
      'partyColor': '#0066CC',
    },
    {
      'candidateId': 'C006',
      'candidateName': 'විජයදාස රාජපක්ෂ (Wijeyadasa Rajapakshe)',
      'party': 'National Democratic Front (ජාතික ප්‍රජාතන්ත්‍රවාදී පෙරමුණ)',
      'partyColor': '#D35400',
    },
  ];

  static Map<String, dynamic> _generateMockData({String? centerId}) {
    final double scale = centerId == null
        ? 1.0
        : (0.08 + ((centerId.hashCode.abs() % 5) * 0.02));

    int totalVotes = 0;
    final List<Map<String, dynamic>> candidates = [];

    for (final def in _candidateDefinitions) {
      final base = (_mockVoteCounts[def['candidateId']]! * scale).round();
      totalVotes += base;
      candidates.add({
        ...def,
        'voteCount': base,
      });
    }

    candidates.sort((a, b) => (b['voteCount'] as int).compareTo(a['voteCount'] as int));

    for (int i = 0; i < candidates.length; i++) {
      final count = candidates[i]['voteCount'] as int;
      final pct = totalVotes > 0 ? (count / totalVotes) * 100 : 0.0;
      candidates[i]['percentage'] = pct.toStringAsFixed(2);
      candidates[i]['rank'] = i + 1;
    }

    return {
      'scope': centerId != null ? 'center' : 'overall',
      'centerId': centerId,
      'totalVotes': totalVotes,
      'candidates': candidates,
      'leader': candidates.first,
    };
  }

  // ──────────────── Public Methods ────────────────

  static Future<List<Map<String, dynamic>>> fetchCenters() async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 150));
      return _mockCenters;
    }

    try {
      final response = await http
          .get(Uri.parse('$baseUrl/votes/centers'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['centers']);
      }
    } catch (_) {
      return _mockCenters;
    }
    throw Exception('Failed to load centers');
  }

  static Stream<Map<String, dynamic>> voteStream({String? centerId}) async* {
    if (useMockData) {
      final random = Random();
      yield _generateMockData(centerId: centerId);

      while (true) {
        await Future.delayed(const Duration(seconds: 2));
        _mockVoteCounts['C001'] = (_mockVoteCounts['C001'] ?? 0) + random.nextInt(25) + 5;
        _mockVoteCounts['C002'] = (_mockVoteCounts['C002'] ?? 0) + random.nextInt(20) + 4;
        _mockVoteCounts['C003'] = (_mockVoteCounts['C003'] ?? 0) + random.nextInt(12) + 2;
        _mockVoteCounts['C004'] = (_mockVoteCounts['C004'] ?? 0) + random.nextInt(5);
        _mockVoteCounts['C005'] = (_mockVoteCounts['C005'] ?? 0) + random.nextInt(3);
        _mockVoteCounts['C006'] = (_mockVoteCounts['C006'] ?? 0) + random.nextInt(2);

        yield _generateMockData(centerId: centerId);
      }
    }

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
        yield _generateMockData(centerId: centerId);
        await Future.delayed(const Duration(seconds: 5));
      }
    }
  }
}
