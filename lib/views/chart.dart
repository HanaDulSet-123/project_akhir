// lib/views/chart_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:tugas_ujk/api/absen_service.dart';
import 'package:tugas_ujk/models/absen_stats_model.dart';

class ChartScreen extends StatefulWidget {
  const ChartScreen({super.key});

  @override
  State<ChartScreen> createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  late Future<AbsenStatsModel?> _statsFuture;
  bool _isLoading = true;

  String _selectedPeriod = 'This Month';
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();

  final List<String> _periods = [
    'This Week',
    'This Month',
    'Last Month',
    'Custom Range',
  ];

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    _calculateDateRange();
    try {
      _statsFuture = AbsenService.getAbsenStats(
        startDate: _startDate,
        endDate: _endDate,
      );
      await _statsFuture;
    } catch (e) {
      debugPrint("Error fetching stats: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _calculateDateRange() {
    final now = DateTime.now();
    if (_selectedPeriod == 'This Month') {
      _startDate = DateTime(now.year, now.month, 1);
      _endDate = now;
    } else if (_selectedPeriod == 'This Week') {
      _startDate = now.subtract(Duration(days: now.weekday - 1));
      _endDate = now;
    } else if (_selectedPeriod == 'Last Month') {
      _startDate = DateTime(now.year, now.month - 1, 1);
      final lastDayOfLastMonth = DateTime(now.year, now.month, 0);
      _endDate = lastDayOfLastMonth;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistik Absensi'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          FutureBuilder<AbsenStatsModel?>(
            future: _statsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting &&
                  _isLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              } else if (!snapshot.hasData || snapshot.data?.data == null) {
                return const Center(
                  child: Text("Tidak ada data untuk periode ini."),
                );
              }

              final stats = snapshot.data!.data!;
              final totalMasuk = stats.totalMasuk ?? 0;
              final totalIzin = stats.totalIzin ?? 0;

              // Data untuk Pie Chart (tanpa Alpa)
              final List<PieChartData> pieData = [
                PieChartData('Masuk', totalMasuk, Colors.green),
                PieChartData('Izin', totalIzin, Colors.orange),
              ];

              return _buildContent(
                stats: stats,
                pieData: pieData,
                totalMasuk: totalMasuk,
                totalIzin: totalIzin,
              );
            },
          ),
          if (_isLoading)
            Container(
              color: Colors.white.withOpacity(0.7),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildContent({
    required Data stats,
    required List<PieChartData> pieData,
    required int totalMasuk,
    required int totalIzin,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Periode: ',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(width: 8),
              ActionChip(
                label: Text(
                  _selectedPeriod == 'Custom Range'
                      ? '${DateFormat.yMd().format(_startDate)} - ${DateFormat.yMd().format(_endDate)}'
                      : _selectedPeriod,
                  style: const TextStyle(color: Colors.blue),
                ),
                avatar: const Icon(
                  Icons.calendar_today,
                  color: Colors.blue,
                  size: 16,
                ),
                backgroundColor: Colors.blue[50],
                onPressed: _showPeriodDialog,
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Ringkasan',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          // Menggunakan Column dan Row untuk tata letak 3 kartu
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      'Masuk Kerja',
                      '$totalMasuk',
                      Colors.green,
                      Icons.check_circle_outline,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSummaryCard(
                      'Izin',
                      '$totalIzin',
                      Colors.orange,
                      Icons.document_scanner_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildSummaryCard(
                'Total Hari Kerja',
                '${stats.totalAbsen ?? 0}',
                Colors.blue,
                Icons.work_outline,
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Tingkat Kehadiran',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          if (totalMasuk == 0 && totalIzin == 0)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Text("Data kehadiran kosong untuk digambarkan."),
              ),
            )
          else
            Center(
              child: SizedBox(
                height: 250,
                width: 250,
                child: SfCircularChart(
                  series: <CircularSeries>[
                    DoughnutSeries<PieChartData, String>(
                      dataSource: pieData,
                      xValueMapper: (PieChartData data, _) => data.label,
                      yValueMapper: (PieChartData data, _) => data.value,
                      pointColorMapper: (PieChartData data, _) => data.color,
                      innerRadius: '70%',
                      dataLabelSettings: const DataLabelSettings(
                        isVisible: true,
                        labelPosition: ChartDataLabelPosition.outside,
                        connectorLineSettings: ConnectorLineSettings(
                          type: ConnectorType.curve,
                          length: '10%',
                        ),
                      ),
                    ),
                  ],
                  legend: Legend(
                    isVisible: true,
                    position: LegendPosition.bottom,
                    overflowMode: LegendItemOverflowMode.wrap,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  overflow: TextOverflow.ellipsis,
                ),
                Icon(icon, color: color, size: 20),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPeriodDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pilih Periode'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _periods.length,
              itemBuilder: (BuildContext context, int index) {
                final period = _periods[index];
                return ListTile(
                  title: Text(period),
                  onTap: () {
                    Navigator.of(context).pop();
                    if (period == 'Custom Range') {
                      _selectCustomRange();
                    } else {
                      if (_selectedPeriod != period) {
                        setState(() => _selectedPeriod = period);
                        _fetchStats();
                      }
                    }
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> _selectCustomRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
        _selectedPeriod = 'Custom Range';
      });
      _fetchStats();
    }
  }
}

class PieChartData {
  final String label;
  final int value;
  final Color color;

  PieChartData(this.label, this.value, this.color);
}
