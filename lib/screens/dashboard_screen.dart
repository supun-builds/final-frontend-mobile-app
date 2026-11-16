import 'dart:async';
import 'package:flutter/material.dart';

import '../models/candidate.dart';
import '../services/api_service.dart';
import '../widgets/winner_card.dart';
import '../widgets/vote_pie_chart.dart';
import '../widgets/center_selector.dart';
import '../widgets/candidate_tile.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Map<String, dynamic>> _centers = [];
  String? _selectedCenterId;
  String _selectedCenterName = 'Overall';

  List<Candidate> _candidates = [];
  int _totalVotes = 0;

  bool _isLoading = true;
  String? _error;
  DateTime? _lastUpdated;

  StreamSubscription? _streamSub;

  @override
  void initState() {
    super.initState();
    _loadCenters();
  }

  @override
  void dispose() {
    _streamSub?.cancel();
    super.dispose();
  }

  Future<void> _loadCenters() async {
    _subscribeStream();

    try {
      final centers = await ApiService.fetchCenters()
          .timeout(const Duration(seconds: 6));

      if (!mounted) return;

      setState(() {
        _centers = centers;
      });
    } catch (_) {
      // Continue even if centers list fails
    }
  }

  void _subscribeStream() {
    _streamSub?.cancel();

    if (mounted) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    _streamSub = ApiService
        .voteStream(centerId: _selectedCenterId)
        .listen(
      (data) {
        if (!mounted) return;

        final rawList = data['candidates'];
        final totalVotes = data['totalVotes'];

        if (rawList == null || totalVotes == null) return;

        setState(() {
          _isLoading = false;

          _totalVotes = totalVotes is int
              ? totalVotes
              : int.tryParse(totalVotes.toString()) ?? 0;

          _candidates = (rawList as List)
              .map(
                (item) => Candidate.fromJson(
                  Map<String, dynamic>.from(item as Map),
                ),
              )
              .toList();

          _lastUpdated = DateTime.now();
        });
      },
      onError: (error) {
        if (!mounted) return;

        setState(() {
          _error = error.toString();
          _isLoading = false;
        });
      },
      cancelOnError: false,
    );
  }

  void _onCenterChanged(String? centerId) {
    final name = centerId == null
        ? 'Overall'
        : _centers.firstWhere(
            (center) => center['centerId'] == centerId,
            orElse: () => {'centerName': centerId},
          )['centerName'] as String;

    setState(() {
      _selectedCenterId = centerId;
      _selectedCenterName = name;
    });

    _subscribeStream();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F9),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Iconic Sri Lankan tricolor accent strip from official website
          _buildNationalStripe(),

          // Deep maroon center selector banner
          CenterSelector(
            centers: _centers,
            selectedCenterId: _selectedCenterId,
            onChanged: _onCenterChanged,
          ),

          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF6B1124),
                    ),
                  )
                : _error != null
                    ? _buildError()
                    : _buildBody(),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(68),
      child: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 12,
        title: Row(
          children: [
            // Emblem crest icon (Sri Lankan gold crest style without requiring image asset)
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFFF39C12), Color(0xFFD35400)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: const Color(0xFFF1C40F), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFF39C12).withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.account_balance,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            // Trilingual Official Header Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    'මැතිවරණ කොමිෂන් සභාව',
                    style: TextStyle(
                      color: Color(0xFF6B1124),
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                  ),
                  Text(
                    'தேர்தல் ஆணைக்குழு • ELECTION COMMISSION',
                    style: TextStyle(
                      color: Color(0xFF4A5568),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // Live indicator pill
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF00A859).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF00A859).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF00A859),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'LIVE',
                      style: TextStyle(
                        color: Color(0xFF00A859),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    if (_lastUpdated != null) ...[
                      const SizedBox(width: 6),
                      Text(
                        '${_lastUpdated!.hour.toString().padLeft(2, '0')}:'
                        '${_lastUpdated!.minute.toString().padLeft(2, '0')}:'
                        '${_lastUpdated!.second.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          color: Color(0xFF718096),
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNationalStripe() {
    return SizedBox(
      height: 3.5,
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Container(color: const Color(0xFFF5A623)), // Saffron / Orange
          ),
          Expanded(
            flex: 2,
            child: Container(color: const Color(0xFF00A859)), // Emerald Green
          ),
          Expanded(
            flex: 6,
            child: Container(color: const Color(0xFF6B1124)), // Deep Maroon
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_candidates.isEmpty) {
      return RefreshIndicator(
        color: const Color(0xFF6B1124),
        onRefresh: () async {
          _subscribeStream();
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 180),
            Center(
              child: Text(
                'දත්ත නොමැත (No candidate data available)',
                style: TextStyle(color: Color(0xFF718096)),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: const Color(0xFF6B1124),
      onRefresh: () async {
        _subscribeStream();
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 30),
        children: [
          const SizedBox(height: 10),

          // Total votes card
          _buildTotalVotes(),

          // Current leading candidate card
          WinnerCard(
            leader: _candidates.first,
            totalVotes: _totalVotes,
          ),

          const SizedBox(height: 10),

          // Pie chart card
          _buildPieChart(),

          const SizedBox(height: 16),

          // Candidate list
          _buildCandidateList(),
        ],
      ),
    );
  }

  Widget _buildTotalVotes() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF6B1124).withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.how_to_vote,
                color: Color(0xFF6B1124),
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'මුළු ඡන්ද සංඛ්‍යාව • TOTAL VOTES CAST',
                    style: TextStyle(
                      color: Color(0xFF718096),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _fmtNum(_totalVotes),
                    style: const TextStyle(
                      color: Color(0xFF1A202C),
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF1C40F).withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFFF1C40F).withOpacity(0.4),
                ),
              ),
              child: Text(
                _selectedCenterId == null ? 'All Centers' : 'Local Center',
                style: const TextStyle(
                  color: Color(0xFFB7791F),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart() {
    if (_candidates.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFE2E8F0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 16,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6B1124),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'ඡන්ද ප්‍රතිශතය • Vote Distribution',
                  style: TextStyle(
                    color: Color(0xFF1A202C),
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            VotePieChart(candidates: _candidates),
            const SizedBox(height: 12),
            _buildLegend(),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Wrap(
      spacing: 14,
      runSpacing: 8,
      children: _candidates.map((candidate) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: candidate.color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 220),
              child: Text(
                candidate.party.isEmpty
                    ? candidate.candidateName
                    : candidate.party,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF4A5568),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildCandidateList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 16,
                decoration: BoxDecoration(
                  color: const Color(0xFF6B1124),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'අපේක්ෂකයින් • Candidate Standings',
                style: TextStyle(
                  color: Color(0xFF1A202C),
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                ),
              ),
              const Spacer(),
              Text(
                '${_candidates.length} Candidates',
                style: const TextStyle(
                  color: Color(0xFF718096),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        ..._candidates.map(
          (candidate) => CandidateTile(
            candidate: candidate,
            totalVotes: _totalVotes,
          ),
        ),
      ],
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.redAccent,
              size: 48,
            ),
            const SizedBox(height: 12),
            const Text(
              'සම්බන්ධතා දෝෂයකි (Connection Error)',
              style: TextStyle(
                color: Color(0xFF1A202C),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _error ?? 'Unknown error',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF718096),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6B1124),
                foregroundColor: Colors.white,
              ),
              onPressed: _subscribeStream,
              child: const Text('නැවත උත්සාහ කරන්න (Retry)'),
            ),
          ],
        ),
      ),
    );
  }

  String _fmtNum(int number) {
    return number.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }
}
