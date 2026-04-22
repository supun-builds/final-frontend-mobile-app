import 'package:flutter/material.dart';
import '../models/candidate.dart';
import '../services/api_service.dart';
import '../widgets/winner_card.dart';
import '../widgets/vote_bar_chart.dart';
import '../widgets/vote_pie_chart.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Candidate> _candidates  = [];
  int             _totalVotes  = 0;
  bool            _isLoading   = true;
  String?         _error;
  DateTime?       _lastUpdated;
  int             _selectedTab = 0; // 0=Bar, 1=Pie

  @override
  void initState() {
    super.initState();
    _listenToStream();
  }

  void _listenToStream() {
    ApiService.voteStream().listen((data) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error     = null;
        _totalVotes = data['totalVotes'] ?? 0;
        _candidates = (data['candidates'] as List)
            .map((j) => Candidate.fromJson(j))
            .toList();
        _lastUpdated = DateTime.now();
      });
    }, onError: (e) {
      if (!mounted) return;
      setState(() { _error = e.toString(); _isLoading = false; });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
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
                decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
              const SizedBox(width: 6),
              const Text('LIVE', style: TextStyle(color: Colors.green,
                                                   fontSize: 11, fontWeight: FontWeight.bold,
                                                   letterSpacing: 1)),
            ]),
          ),
          const SizedBox(width: 12),
          const Text('Election Dashboard',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
        ]),
        actions: [
           if (_lastUpdated != null)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(child: Text(
                'Updated ${_formatTime(_lastUpdated!)}',
                style: const TextStyle(color: Colors.white38, fontSize: 11),
              )),
            ),
        ],
      ),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator(color: Color(0xFF4A90D9)))
        : _error != null
          ? _buildError()
          : _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_candidates.isEmpty) {
      return const Center(
      child: Text('No vote data available',
        style: TextStyle(color: Colors.white54)));
    }

    return RefreshIndicator(
      onRefresh: () async => _listenToStream(),
      child: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          const SizedBox(height: 8),

          // Total votes counter
          Center(child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(children: [
              Text('${_formatNumber(_totalVotes)}',
                style: const TextStyle(color: Colors.white, fontSize: 36,
                                       fontWeight: FontWeight.bold)),
              const Text('Total Votes Cast',
                style: TextStyle(color: Colors.white38, fontSize: 13)),
            ]),
          )),

          // Leader / winner card
          if (_candidates.isNotEmpty)
            WinnerCard(leader: _candidates.first, totalVotes: _totalVotes),

          const SizedBox(height: 20),

          // Chart toggle tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(children: [
              _TabButton(label: 'Bar Chart', selected: _selectedTab == 0,
                onTap: () => setState(() => _selectedTab = 0)),
              const SizedBox(width: 8),
              _TabButton(label: 'Pie Chart', selected: _selectedTab == 1,
                onTap: () => setState(() => _selectedTab = 1)),
            ]),
          ),
          const SizedBox(height: 12),

          // Chart
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

          const SizedBox(height: 20),

          // Candidate leaderboard
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: const Text('Candidates',
              style: TextStyle(color: Colors.white70, fontSize: 14,
                               fontWeight: FontWeight.w600, letterSpacing: 0.5)),
          ),
          const SizedBox(height: 8),
          ..._candidates.map((c) => _CandidateTile(
            candidate: c, totalVotes: _totalVotes)),
        ],
      ),
    );
  }

  Widget _buildLegend() => Wrap(
    spacing: 12, runSpacing: 6,
    children: _candidates.map((c) => Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 12, height: 12,
        decoration: BoxDecoration(color: c.color, shape: BoxShape.circle)),
      const SizedBox(width: 5),
      Text(c.party,
        style: const TextStyle(color: Colors.white60, fontSize: 11)),
    ])).toList(),
  );

  Widget _buildError() => Center(child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
      const SizedBox(height: 12),
      const Text('Connection error', style: TextStyle(color: Colors.white70, fontSize: 16)),
      const SizedBox(height: 6),
      Text(_error!, style: const TextStyle(color: Colors.white38, fontSize: 12)),
      const SizedBox(height: 16),
      ElevatedButton(onPressed: _listenToStream, child: const Text('Retry')),
    ],
  ));

  String _formatTime(DateTime dt) =>
    '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';

  String _formatNumber(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(2)}M';
    if (n >= 1000)    return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _TabButton({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFF4A90D9) : Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label,
        style: TextStyle(
          color: selected ? Colors.white : Colors.white38,
          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          fontSize: 13,
        )),
    ),
  );
}

class _CandidateTile extends StatelessWidget {
  final Candidate candidate;
  final int totalVotes;
  const _CandidateTile({required this.candidate, required this.totalVotes});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF0F1525),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: candidate.rank == 1
              ? candidate.color.withOpacity(0.5)
              : Colors.white.withOpacity(0.06),
            width: candidate.rank == 1 ? 1.5 : 1,
          ),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                color: candidate.color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(child: Text('#${candidate.rank}',
                style: TextStyle(color: candidate.color,
                                 fontSize: 12, fontWeight: FontWeight.bold))),
            ),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(candidate.candidateName,
                style: const TextStyle(color: Colors.white,
                                       fontWeight: FontWeight.w600, fontSize: 14)),
              Text(candidate.party,
                style: const TextStyle(color: Colors.white38, fontSize: 12)),
            ])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('${candidate.voteCount} votes',
                style: const TextStyle(color: Colors.white70,
                                       fontWeight: FontWeight.w600, fontSize: 13)),
              Text('${candidate.percentage.toStringAsFixed(1)}%',
                style: TextStyle(color: candidate.color, fontSize: 12)),
            ]),
          ]),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: totalVotes > 0 ? candidate.voteCount / totalVotes : 0,
              backgroundColor: Colors.white.withOpacity(0.06),
              valueColor: AlwaysStoppedAnimation<Color>(candidate.color),
              minHeight: 6,
            ),
          ),
        ]),
      ),
    );
  }
}