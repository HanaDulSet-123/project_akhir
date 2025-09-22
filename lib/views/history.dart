import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // <-- Diperlukan untuk memuat font
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:tugas_ujk/api/absen_service.dart';
import 'package:tugas_ujk/models/absen_history_model.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  State<AttendanceHistoryScreen> createState() =>
      _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  late Future<AbsenHistoryModel> _historyFuture;
  bool _isLoading = true;

  String _selectedFilter = 'This Month';
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();

  final List<String> _filters = [
    'Today',
    'This Week',
    'This Month',
    'Custom Range',
  ];

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    _calculateDateRange();
    try {
      _historyFuture = AbsenService.getAbsenHistory(
        startDate: _startDate,
        endDate: _endDate,
      );
      await _historyFuture;
    } catch (e) {
      debugPrint("Error fetching history: $e");
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
    switch (_selectedFilter) {
      case 'Today':
        _startDate = now;
        _endDate = now;
        break;
      case 'This Week':
        _startDate = now.subtract(Duration(days: now.weekday - 1));
        _endDate = now;
        break;
      case 'This Month':
        _startDate = DateTime(now.year, now.month, 1);
        _endDate = now;
        break;
    }
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
        _selectedFilter = 'Custom Range';
      });
      _fetchHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Absensi'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'Filter Riwayat',
          ),
          FutureBuilder<AbsenHistoryModel>(
            future: _historyFuture,
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data!.data!.isNotEmpty) {
                return IconButton(
                  icon: const Icon(Icons.picture_as_pdf_outlined),
                  onPressed: () => _generatePdf(snapshot.data!.data!),
                  tooltip: 'Ekspor ke PDF',
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Text(
                  'Filter: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                ActionChip(
                  avatar: const Icon(Icons.calendar_today, size: 16),
                  label: Text(
                    _selectedFilter == 'Custom Range'
                        ? '${DateFormat.yMd().format(_startDate)} - ${DateFormat.yMd().format(_endDate)}'
                        : _selectedFilter,
                  ),
                  backgroundColor: Colors.blue[50],
                  onPressed: _showFilterDialog,
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<AbsenHistoryModel>(
              future: _historyFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Gagal memuat data: ${snapshot.error}'),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.data!.isEmpty) {
                  return const Center(
                    child: Text('Tidak ada riwayat absensi pada periode ini.'),
                  );
                }

                final historyList = snapshot.data!.data!;
                return ListView.separated(
                  itemCount: historyList.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final attendance = historyList[index];
                    return _buildAttendanceItem(attendance);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceItem(Datum attendance) {
    final date = attendance.attendanceDate ?? DateTime.now();
    final dayName = DateFormat('E').format(date);
    final dayOfMonth = DateFormat('d').format(date);

    Color statusColor;
    String statusText = attendance.status ?? 'Tidak Diketahui';
    switch (statusText.toLowerCase()) {
      case 'masuk':
        statusColor = Colors.green;
        break;
      case 'izin':
        statusColor = Colors.orange;
        break;
      default:
        statusColor = Colors.grey;
    }

    return ListTile(
      leading: Container(
        width: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border(right: BorderSide(color: Colors.grey.shade300)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(dayName, style: const TextStyle(fontSize: 14)),
            Text(
              dayOfMonth,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      title: Row(
        children: [
          _buildTimeInfo('Check-in', attendance.checkInTime),
          _buildTimeInfo('Check-out', attendance.checkOutTime),
        ],
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: statusColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          statusText,
          style: TextStyle(
            color: statusColor,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildTimeInfo(String label, String? time) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          Text(
            time ?? '-',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pilih Filter'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _filters.length,
              itemBuilder: (BuildContext context, int index) {
                final filter = _filters[index];
                return ListTile(
                  title: Text(filter),
                  onTap: () {
                    Navigator.of(context).pop();
                    if (filter == 'Custom Range') {
                      _selectCustomRange();
                    } else {
                      if (_selectedFilter != filter) {
                        setState(() => _selectedFilter = filter);
                        _fetchHistory();
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

  Future<void> _generatePdf(List<Datum> data) async {
    final fontData = await rootBundle.load("assets/fonts/Roboto-Regular.ttf");
    final boldFontData = await rootBundle.load("assets/fonts/Roboto-Bold.ttf");
    final ttf = pw.Font.ttf(fontData);
    final boldTtf = pw.Font.ttf(boldFontData);

    final myTheme = pw.ThemeData.withFont(base: ttf, bold: boldTtf);

    final doc = pw.Document(theme: myTheme);
    final dateFormat = DateFormat('d MMM yyyy');

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Laporan Riwayat Absensi',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  pw.Text(
                    'Tanggal Cetak: ${dateFormat.format(DateTime.now())}',
                  ),
                ],
              ),
            ),
            pw.Paragraph(
              text:
                  'Laporan untuk periode: ${dateFormat.format(_startDate)} - ${dateFormat.format(_endDate)}',
            ),
            pw.SizedBox(height: 20),
            pw.Table.fromTextArray(
              headers: ['No', 'Tanggal', 'Check-in', 'Check-out', 'Status'],
              data: List<List<String>>.generate(data.length, (index) {
                final item = data[index];
                return [
                  (index + 1).toString(),
                  dateFormat.format(item.attendanceDate ?? DateTime.now()),
                  item.checkInTime ?? '-',
                  item.checkOutTime ?? '-',
                  item.status ?? 'N/A',
                ];
              }),
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.blue),
              cellAlignment: pw.Alignment.center,
              cellStyle: const pw.TextStyle(fontSize: 10),
              border: pw.TableBorder.all(),
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
    );
  }
}
