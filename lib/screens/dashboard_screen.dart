import 'dart:async';
import 'package:flutter/material.dart';
import '../models/candidate.dart';
import '../services/api_service.dart';
import '../widgets/winner_card.dart';
import '../widgets/vote_bar_chart.dart';
import '../widgets/vote_pie_chart.dart';
import '../widgets/center_selector.dart';
import '../widgets/candidate_tile.dart';  
import '../widgets/tab_button.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Map<String, dynamic>> _centers          = [];
  String?                    _selectedCenterId;
  String                     _selectedCenterName = 'Overall';
  List<Candidate>            _candidates        = [];
  int                        _totalVotes        = 0;
  bool                       _isLoading         = true;
  String?                    _error;
  DateTime?                  _lastUpdated;
  int                        _selectedTab       = 0;
  StreamSubscription?        _streamSub;

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
    try {
      final centers = await ApiService.fetchCenters();
      setState(() => _centers = centers);
    } catch (_) {}
    _subscribeStream();
  }

  void _subscribeStream() {
    _streamSub?.cancel();
    setState(() { _isLoading = true; _error = null; });

    _streamSub = ApiService
        .voteStream(centerId: _selectedCenterId)
        .listen((data) {
      if (!mounted) return;
      setState(() {
        _isLoading   = false;
        _totalVotes  = data['totalVotes'] ?? 0;
        _candidates  = (data['candidates'] as List)
            .map((j) => Candidate.fromJson(j))
            .toList();
        _lastUpdated = DateTime.now();
      });
    }, onError: (e) {
      if (!mounted) return;
      setState(() { _error = e.toString(); _isLoading = false; });
    });
  }

  void _onCenterChanged(String? centerId) {
    final name = centerId == null
        ? 'Overall'
        : _centers.firstWhere(
            (c) => c['centerId'] == centerId,
            orElse: () => {'centerName': centerId},
          )['centerName'] as String;

    setState(() {
      _selectedCenterId   = centerId;
      _selectedCenterName = name;
    });
    _subscribeStream();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: _buildAppBar(),
      body: Column(children: [
        CenterSelector(
          centers:          _centers,
          selectedCenterId: _selectedCenterId,
          onChanged:        _onCenterChanged,
        ),
        Expanded(child: _isLoading
          ? const Center(child: CircularProgressIndicator(
              color: Color(0xFF4A90D9)))
          : _error != null
            ? _buildError()
            : _buildBody()),
      ]),
    );
  }

  AppBar _buildAppBar() => AppBar(
    backgroundColor: const Color(0xFF0F1525),
    elevation: 0,
    title: Row(children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.15),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.green.withOpacity(0.4)),
        ),
        child: Row(children: [
          Container(width: 7, height: 7,
            decoration: const BoxDecoration(
              color: Colors.green, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          const Text('LIVE',
            style: TextStyle(color: Colors.green, fontSize: 11,
                             fontWeight: FontWeight.bold, letterSpacing: 1)),
        ]),
      ),
      const SizedBox(width: 12),
      const Text('Election Dashboard',
        style: TextStyle(color: Colors.white, fontSize: 18,
                         fontWeight: FontWeight.w600)),
    ]),
    actions: [
      if (_lastUpdated != null)
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Center(child: Text(
            '${_lastUpdated!.hour.toString().padLeft(2,'0')}:'
            '${_lastUpdated!.minute.toString().padLeft(2,'0')}:'
            '${_lastUpdated!.second.toString().padLeft(2,'0')}',
            style: const TextStyle(color: Colors.white38, fontSize: 11),
          )),
        ),
    ],
  );

  Widget _buildBody() {
    if (_candidates.isEmpty) return const Center(
      child: Text('No vote data',
        style: TextStyle(color: Colors.white54)));

    return RefreshIndicator(
      onRefresh: () async => _subscribeStream(),
      child: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          const SizedBox(height: 8),
          _buildScopeLabel(),
          _buildTotalVotes(),
          if (_candidates.isNotEmpty)
            WinnerCard(leader: _candidates.first, totalVotes: _totalVotes),
          const SizedBox(height: 20),
          _buildChartSection(),
          const SizedBox(height: 20),
          _buildCandidateList(),
        ],
      ),
    );
  }

  Widget _buildScopeLabel() => Center(child: Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
  ));

  Widget _buildTotalVotes() => Center(child: Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Column(children: [
      Text(_fmtNum(_totalVotes),
        style: const TextStyle(color: Colors.white, fontSize: 36,
                               fontWeight: FontWeight.bold)),
      const Text('Total Votes Cast',
        style: TextStyle(color: Colors.white38, fontSize: 13)),
    ]),
  ));

  Widget _buildChartSection() => Column(children: [
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(children: [
        TabButton(label: 'Bar Chart', selected: _selectedTab == 0,
          onTap: () => setState(() => _selectedTab = 0)),
        const SizedBox(width: 8),
        TabButton(label: 'Pie Chart', selected: _selectedTab == 1,
          onTap: () => setState(() => _selectedTab = 1)),
      ]),
    ),
    const SizedBox(height: 12),
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0F1525),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: _selectedTab == 0
            ? VoteBarChart(candidates: _candidates)
            : Column(children: [
                VotePieChart(candidates: _candidates),
                const SizedBox(height: 12),
                _buildLegend(),
              ]),
      ),
    ),
  ]);

  Widget _buildLegend() => Wrap(
    spacing: 12, runSpacing: 6,
    children: _candidates.map((c) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 12, height: 12,
          decoration: BoxDecoration(
            color: c.color, shape: BoxShape.circle)),
        const SizedBox(width: 5),
        Text(c.party,
          style: const TextStyle(color: Colors.white60, fontSize: 11)),
      ],
    )).toList(),
  );

  Widget _buildCandidateList() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Text('Candidates',
          style: TextStyle(color: Colors.white70, fontSize: 14,
                           fontWeight: FontWeight.w600, letterSpacing: 0.5)),
      ),
      const SizedBox(height: 8),
      ..._candidates.map((c) => CandidateTile(
        candidate: c, totalVotes: _totalVotes)),
    ],
  );

  Widget _buildError() => Center(child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
      const SizedBox(height: 12),
      const Text('Connection error',
        style: TextStyle(color: Colors.white70, fontSize: 16)),
      const SizedBox(height: 6),
      Text(_error!,
        style: const TextStyle(color: Colors.white38, fontSize: 12)),
      const SizedBox(height: 16),
      ElevatedButton(onPressed: _subscribeStream,
        child: const Text('Retry')),
    ],
  ));

  String _fmtNum(int n) {
    if (n >= 1000000) return '${(n/1000000).toStringAsFixed(2)}M';
    if (n >= 1000)    return '${(n/1000).toStringAsFixed(1)}K';
    return n.toString();
  }
}