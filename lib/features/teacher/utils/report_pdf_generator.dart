import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../core/database/database.dart';
import '../providers/report_provider.dart';

class ReportPdfGenerator {
  static Future<Uint8List> generateAttendanceReport({
    required AttendanceStats stats,
    required DateTimeRange dateRange,
    required String? schoolName,
    required String? className,
  }) async {
    final pdf = pw.Document();
    
    // Load font
    final font = await PdfGoogleFonts.poppinsRegular();
    final fontBold = await PdfGoogleFonts.poppinsBold();
    final fontSemiBold = await PdfGoogleFonts.poppinsSemiBold();
    
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Header
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Laporan Absensi Siswa',
                        style: pw.TextStyle(font: fontBold, fontSize: 20),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        schoolName ?? 'Sekolah',
                        style: pw.TextStyle(font: fontSemiBold, fontSize: 14),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        'Kelas: ${className ?? "-"}',
                        style: pw.TextStyle(font: font, fontSize: 12),
                      ),
                    ],
                  ),
                  pw.Container(
                    width: 60,
                    height: 60,
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.black, width: 1),
                    ),
                    child: pw.Center(
                      child: pw.Text(
                        'Logo',
                        style: pw.TextStyle(font: font, fontSize: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            pw.SizedBox(height: 20),
            
            // Date Range Info
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.circular(4),
              ),
              child: pw.Row(
                children: [
                  pw.Icon(pw.IconData(0xE916)), // Calendar icon
                  pw.SizedBox(width: 10),
                  pw.Text(
                    'Periode: ${_formatDate(dateRange.start)} - ${_formatDate(dateRange.end)}',
                    style: pw.TextStyle(font: fontSemiBold, fontSize: 12),
                  ),
                ],
              ),
            ),
            
            pw.SizedBox(height: 20),
            
            // Summary
            pw.Container(
              padding: const pw.EdgeInsets.all(15),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Ringkasan',
                    style: pw.TextStyle(font: fontSemiBold, fontSize: 14),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Row(
                    children: [
                      _buildSummaryItem(
                        label: 'Total Siswa',
                        value: stats.totalSiswa.toString(),
                        color: PdfColors.blueGrey,
                        font: font,
                        fontSemiBold: fontSemiBold,
                      ),
                      pw.SizedBox(width: 10),
                      _buildSummaryItem(
                        label: 'Hadir',
                        value: stats.totalHadir.toString(),
                        color: PdfColors.green,
                        font: font,
                        fontSemiBold: fontSemiBold,
                      ),
                      pw.SizedBox(width: 10),
                      _buildSummaryItem(
                        label: 'Izin',
                        value: stats.totalIzin.toString(),
                        color: PdfColors.blue,
                        font: font,
                        fontSemiBold: fontSemiBold,
                      ),
                      pw.SizedBox(width: 10),
                      _buildSummaryItem(
                        label: 'Sakit',
                        value: stats.totalSakit.toString(),
                        color: PdfColors.orange,
                        font: font,
                        fontSemiBold: fontSemiBold,
                      ),
                      pw.SizedBox(width: 10),
                      _buildSummaryItem(
                        label: 'Alpa',
                        value: stats.totalAlpa.toString(),
                        color: PdfColors.red,
                        font: font,
                        fontSemiBold: fontSemiBold,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            pw.SizedBox(height: 20),
            
            // Percentage Info
            pw.Container(
              padding: const pw.EdgeInsets.all(15),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Persentase Kehadiran',
                    style: pw.TextStyle(font: fontSemiBold, fontSize: 14),
                  ),
                  pw.SizedBox(height: 10),
                  _buildProgressBar(
                    label: 'Hadir',
                    percentage: stats.percentageHadir,
                    color: PdfColors.green,
                    font: font,
                  ),
                  pw.SizedBox(height: 8),
                  _buildProgressBar(
                    label: 'Izin',
                    percentage: stats.percentageIzin,
                    color: PdfColors.blue,
                    font: font,
                  ),
                  pw.SizedBox(height: 8),
                  _buildProgressBar(
                    label: 'Sakit',
                    percentage: stats.percentageSakit,
                    color: PdfColors.orange,
                    font: font,
                  ),
                  pw.SizedBox(height: 8),
                  _buildProgressBar(
                    label: 'Alpa',
                    percentage: stats.percentageAlpa,
                    color: PdfColors.red,
                    font: font,
                  ),
                ],
              ),
            ),
            
            pw.SizedBox(height: 40),
            
            // Footer
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text(
                      'Dicetak pada ${_formatFullDate(DateTime.now())}',
                      style: pw.TextStyle(font: font, fontSize: 10),
                    ),
                    pw.SizedBox(height: 20),
                    pw.Text(
                      'Guru Kelas',
                      style: pw.TextStyle(font: font, fontSize: 10),
                    ),
                    pw.SizedBox(height: 40),
                    pw.Container(
                      width: 120,
                      child: pw.Divider(thickness: 1),
                    ),
                    pw.Text(
                      '(Nama Guru)',
                      style: pw.TextStyle(font: font, fontSize: 10),
                    ),
                  ],
                ),
              ],
            ),
          ];
        },
      ),
    );
    
    return pdf.save();
  }
  
  static pw.Expanded _buildSummaryItem({
    required String label,
    required String value,
    required PdfColor color,
    required pw.Font font,
    required pw.Font fontSemiBold,
  }) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(10),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.grey300),
          borderRadius: pw.BorderRadius.circular(4),
        ),
        child: pw.Column(
          children: [
            pw.Text(
              value,
              style: pw.TextStyle(font: fontSemiBold, fontSize: 18, color: color),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              label,
              style: pw.TextStyle(font: font, fontSize: 10),
              textAlign: pw.TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  static pw.Row _buildProgressBar({
    required String label,
    required double percentage,
    required PdfColor color,
    required pw.Font font,
  }) {
    return pw.Row(
      children: [
        pw.SizedBox(width: 60, child: pw.Text(label, style: pw.TextStyle(font: font, fontSize: 10))),
        pw.SizedBox(width: 10),
        pw.Expanded(
          child: pw.LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints?.maxWidth ?? 200;
              final percentWidth = (percentage / 100) * width;
              
              return pw.Stack(
                children: [
                  pw.Container(
                    height: 16,
                    decoration: pw.BoxDecoration(
                      color: PdfColors.grey200,
                      borderRadius: pw.BorderRadius.circular(8),
                    ),
                  ),
                  pw.Container(
                    width: percentWidth,
                    height: 16,
                    decoration: pw.BoxDecoration(
                      color: color,
                      borderRadius: pw.BorderRadius.circular(8),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        pw.SizedBox(width: 10),
        pw.SizedBox(
          width: 40,
          child: pw.Text(
            '${percentage.toStringAsFixed(1)}%',
            style: pw.TextStyle(font: font, fontSize: 10),
            textAlign: pw.TextAlign.right,
          ),
        ),
      ],
    );
  }

  static String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }
  
  static String _formatFullDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }
}