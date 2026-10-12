
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
    // Start the results stream immediately.
    _subscribeStream();

    // Load voting centers in the background.
    try {
      final centers = await ApiService.fetchCenters()
          .timeout(const Duration(seconds: 6));

      if (!mounted) return;

      setState(() {
        _centers = centers;
      });
    } catch (_) {
      // Keep the overall results available even if
      // the center list cannot be loaded.
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
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          CenterSelector(
            centers: _centers,
            selectedCenterId: _selectedCenterId,
            onChanged: _onCenterChanged,
          ),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF4A90D9),
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

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF0F1525),
      elevation: 0,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: Colors.green.withOpacity(0.4),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  'LIVE',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Election Dashboard',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      actions: [
        if (_lastUpdated != null)
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: Text(
                '${_lastUpdated!.hour.toString().padLeft(2, '0')}:'
                '${_lastUpdated!.minute.toString().padLeft(2, '0')}:'
                '${_lastUpdated!.second.toString().padLeft(2, '0')}',
                style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 11,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBody() {
    if (_candidates.isEmpty) {
      return RefreshIndicator(
        onRefresh: () async {
          _subscribeStream();
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 180),
            Center(
              child: Text(
                'No candidate data available',
                style: TextStyle(color: Colors.white54),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        _subscribeStream();
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const SizedBox(height: 8),

          // Overall or selected-center label.
          _buildScopeLabel(),

          // Total votes.
          _buildTotalVotes(),

          // Current leading candidate.
          WinnerCard(
            leader: _candidates.first,
            totalVotes: _totalVotes,
          ),

          const SizedBox(height: 12),

          // Pie chart is retained.
          _buildPieChart(),

          const SizedBox(height: 20),

          // Candidate list gets the space previously
          // occupied by the bar chart and chart tabs.
          _buildCandidateList(),
        ],
      ),
    );
  }

  Widget _buildScopeLabel() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: _selectedCenterId == null
                ? const Color(0xFF4A90D9).withOpacity(0.15)
                : const Color(0xFF1D9E75).withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            _selectedCenterId == null
                ? '🌐  All Centers Combined'
                : '📍  $_selectedCenterName',
            style: TextStyle(
              color: _selectedCenterId == null
                  ? const Color(0xFF4A90D9)
                  : const Color(0xFF1D9E75),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTotalVotes() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            Text(
              _fmtNum(_totalVotes),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              'Total Votes Cast',
              style: TextStyle(
                color: Colors.white38,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF0F1525),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.06),
          ),
        ),
        child: Column(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Vote Distribution',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 8),
            VotePieChart(candidates: _candidates),
            const SizedBox(height: 8),
            _buildLegend(),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Wrap(
      spacing: 12,
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
            const SizedBox(width: 5),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 220),
              child: Text(
                candidate.party.isEmpty
                    ? candidate.candidateName
                    : candidate.party,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 11,
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
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Candidates',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
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
              'Connection error',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _error ?? 'Unknown error',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white38,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _subscribeStream,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  String _fmtNum(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(2)}M';
    }

    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }

    return number.toString();
  }
}
