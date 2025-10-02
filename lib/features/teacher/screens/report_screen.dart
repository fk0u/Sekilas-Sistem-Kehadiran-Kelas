import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../core/database/database.dart';
import '../providers/report_provider.dart';
import '../utils/report_pdf_generator.dart';

class ReportScreen extends ConsumerWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateRange = ref.watch(reportDateRangeProvider);
    final statsAsync = ref.watch(attendanceStatsProvider(dateRange));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Absensi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () => _selectDateRange(context, ref),
            tooltip: 'Pilih Periode',
          ),
        ],
      ),
      body: statsAsync.when(
        data: (stats) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Date Range Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.date_range, color: AppTheme.primaryBlue),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Periode Laporan', style: TextStyle(fontSize: 12)),
                          Text(
                            '${_formatDate(dateRange.start)} - ${_formatDate(dateRange.end)}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () => _selectDateRange(context, ref),
                      child: const Text('Ubah'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Summary Cards
            _buildSummaryGrid(stats),

            const SizedBox(height: 16),

            // Pie Chart
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Distribusi Kehadiran',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 200,
                      child: _buildPieChart(stats),
                    ),
                    const SizedBox(height: 16),
                    _buildLegend(),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Bar Chart
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Perbandingan Status',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 200,
                      child: _buildBarChart(stats),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Export Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _exportToPdf(context, ref, stats, dateRange),
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text('Export PDF'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showExportExcelComingSoon(context),
                    icon: const Icon(Icons.table_chart),
                    label: const Text('Export Excel'),
                  ),
                ),
              ],
            ),
          ],
        ),
        loading: () => const LoadingWidget(message: 'Memuat laporan...'),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }

  Widget _buildSummaryGrid(AttendanceStats stats) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard('Hadir', stats.totalHadir, AppTheme.statusHadir, Icons.check_circle),
        _buildStatCard('Izin', stats.totalIzin, AppTheme.statusIzin, Icons.assignment),
        _buildStatCard('Sakit', stats.totalSakit, AppTheme.statusSakit, Icons.medical_services),
        _buildStatCard('Alpa', stats.totalAlpa, AppTheme.statusAlpa, Icons.cancel),
      ],
    );
  }

  Widget _buildStatCard(String label, int value, Color color, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value.toString(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart(AttendanceStats stats) {
    final total = stats.totalHadir + stats.totalIzin + stats.totalSakit + stats.totalAlpa;
    
    if (total == 0) {
      return const Center(child: Text('Belum ada data'));
    }

    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 50,
        sections: [
          PieChartSectionData(
            value: stats.totalHadir.toDouble(),
            title: '${stats.percentageHadir.toStringAsFixed(1)}%',
            color: AppTheme.statusHadir,
            radius: 60,
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          PieChartSectionData(
            value: stats.totalIzin.toDouble(),
            title: '${stats.percentageIzin.toStringAsFixed(1)}%',
            color: AppTheme.statusIzin,
            radius: 60,
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          PieChartSectionData(
            value: stats.totalSakit.toDouble(),
            title: '${stats.percentageSakit.toStringAsFixed(1)}%',
            color: AppTheme.statusSakit,
            radius: 60,
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          PieChartSectionData(
            value: stats.totalAlpa.toDouble(),
            title: '${stats.percentageAlpa.toStringAsFixed(1)}%',
            color: AppTheme.statusAlpa,
            radius: 60,
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(AttendanceStats stats) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: [stats.totalHadir, stats.totalIzin, stats.totalSakit, stats.totalAlpa]
            .reduce((a, b) => a > b ? a : b)
            .toDouble() * 1.2,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                switch (value.toInt()) {
                  case 0:
                    return const Text('Hadir', style: TextStyle(fontSize: 10));
                  case 1:
                    return const Text('Izin', style: TextStyle(fontSize: 10));
                  case 2:
                    return const Text('Sakit', style: TextStyle(fontSize: 10));
                  case 3:
                    return const Text('Alpa', style: TextStyle(fontSize: 10));
                  default:
                    return const Text('');
                }
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
        ),
        borderData: FlBorderData(show: false),
        barGroups: [
          BarChartGroupData(x: 0, barRods: [
            BarChartRodData(
              toY: stats.totalHadir.toDouble(),
              color: AppTheme.statusHadir,
              width: 40,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            ),
          ]),
          BarChartGroupData(x: 1, barRods: [
            BarChartRodData(
              toY: stats.totalIzin.toDouble(),
              color: AppTheme.statusIzin,
              width: 40,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            ),
          ]),
          BarChartGroupData(x: 2, barRods: [
            BarChartRodData(
              toY: stats.totalSakit.toDouble(),
              color: AppTheme.statusSakit,
              width: 40,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            ),
          ]),
          BarChartGroupData(x: 3, barRods: [
            BarChartRodData(
              toY: stats.totalAlpa.toDouble(),
              color: AppTheme.statusAlpa,
              width: 40,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildLegendItem('Hadir', AppTheme.statusHadir),
        _buildLegendItem('Izin', AppTheme.statusIzin),
        _buildLegendItem('Sakit', AppTheme.statusSakit),
        _buildLegendItem('Alpa', AppTheme.statusAlpa),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }

  Future<void> _selectDateRange(BuildContext context, WidgetRef ref) async {
    final currentRange = ref.read(reportDateRangeProvider);
    
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: currentRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryBlue,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      ref.read(reportDateRangeProvider.notifier).state = picked;
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }
  
  Future<void> _exportToPdf(
    BuildContext context, 
    WidgetRef ref, 
    AttendanceStats stats,
    DateTimeRange dateRange,
  ) async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Menghasilkan laporan PDF...'),
            ],
          ),
        ),
      );
      
      // Get school name and class name
      final database = ref.read(appDatabaseProvider);
      final schoolName = await database.getSchoolName();
      final teacher = await database.getTeacher();
      final className = teacher?.className;
      
      // Generate PDF document
      final pdfData = await ReportPdfGenerator.generateAttendanceReport(
        stats: stats,
        dateRange: dateRange,
        schoolName: schoolName,
        className: className,
      );
      
      // Close loading dialog
      Navigator.of(context).pop();
      
      // Open PDF preview
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              title: const Text('Preview Laporan PDF'),
            ),
            body: PdfPreview(
              build: (format) => pdfData,
              canChangeOrientation: false,
              canChangePageFormat: false,
              canDebug: false,
            ),
          ),
        ),
      );
    } catch (e) {
      // Close loading dialog if showing
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal membuat PDF: ${e.toString()}')),
      );
    }
  }
  
  void _showExportExcelComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Ekspor ke Excel akan segera tersedia!'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
