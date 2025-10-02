import 'dart:io';
import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../../../core/database/database.dart';
import '../providers/report_provider.dart';

class ReportExcelGenerator {
  static Future<Uint8List> generateAttendanceReport({
    required AttendanceStats stats,
    required DateTimeRange dateRange,
    required String? schoolName,
    required String? className,
    required List<Student>? students,
    required List<Attendance>? attendances,
  }) async {
    final excel = Excel.createExcel();
    
    // Delete the default Sheet1
    if (excel.sheets.containsKey('Sheet1')) {
      excel.delete('Sheet1');
    }
    
    // Create summary sheet
    final summarySheet = excel['Ringkasan'];
    
    // Style definitions
    final headerStyle = CellStyle(
      fontFamily: getFontFamily(FontFamily.Calibri),
      bold: true,
      fontSize: 14,
      horizontalAlign: HorizontalAlign.Center,
      backgroundColor: getColorFromHex('4472C4'),
      fontColor: getColorFromHex('FFFFFF'),
    );
    
    final subHeaderStyle = CellStyle(
      fontFamily: getFontFamily(FontFamily.Calibri),
      bold: true,
      fontSize: 12,
      horizontalAlign: HorizontalAlign.Left,
      backgroundColor: getColorFromHex('D9E1F2'),
    );
    
    final normalStyle = CellStyle(
      fontFamily: getFontFamily(FontFamily.Calibri),
      fontSize: 11,
    );
    
    final centerStyle = CellStyle(
      fontFamily: getFontFamily(FontFamily.Calibri),
      fontSize: 11,
      horizontalAlign: HorizontalAlign.Center,
    );
    
    final boldStyle = CellStyle(
      fontFamily: getFontFamily(FontFamily.Calibri),
      fontSize: 11,
      bold: true,
    );
    
    // Header row
    final headerCell = summarySheet.cell(CellIndex.indexByString('A1'));
    headerCell.value = TextCellValue('LAPORAN ABSENSI SISWA');
    headerCell.cellStyle = headerStyle;
    summarySheet.merge(CellIndex.indexByString('A1'), CellIndex.indexByString('F1'));
    
    // Info rows
    summarySheet.cell(CellIndex.indexByString('A2')).value = TextCellValue('Sekolah');
    summarySheet.cell(CellIndex.indexByString('B2')).value = TextCellValue(schoolName ?? 'Sekolah');
    
    summarySheet.cell(CellIndex.indexByString('A3')).value = TextCellValue('Kelas');
    summarySheet.cell(CellIndex.indexByString('B3')).value = TextCellValue(className ?? '-');
    
    summarySheet.cell(CellIndex.indexByString('A4')).value = TextCellValue('Periode');
    summarySheet.cell(CellIndex.indexByString('B4')).value = 
        TextCellValue('${_formatDate(dateRange.start)} - ${_formatDate(dateRange.end)}');
    
    // Set column widths
    summarySheet.setColumnWidth(0, 20);
    summarySheet.setColumnWidth(1, 20);
    summarySheet.setColumnWidth(2, 15);
    summarySheet.setColumnWidth(3, 15);
    summarySheet.setColumnWidth(4, 15);
    summarySheet.setColumnWidth(5, 15);
    
    // Add empty row
    summarySheet.cell(CellIndex.indexByString('A5')).value = TextCellValue('');
    
    // Summary section header
    final summaryHeaderCell = summarySheet.cell(CellIndex.indexByString('A6'));
    summaryHeaderCell.value = TextCellValue('RINGKASAN KEHADIRAN');
    summaryHeaderCell.cellStyle = subHeaderStyle;
    summarySheet.merge(CellIndex.indexByString('A6'), CellIndex.indexByString('F6'));
    
    // Summary data rows
    summarySheet.cell(CellIndex.indexByString('A7')).value = TextCellValue('Total Siswa');
    summarySheet.cell(CellIndex.indexByString('B7')).value = NumberCellValue(stats.totalSiswa);
    summarySheet.cell(CellIndex.indexByString('A7')).cellStyle = boldStyle;
    
    summarySheet.cell(CellIndex.indexByString('A8')).value = TextCellValue('Total Hadir');
    summarySheet.cell(CellIndex.indexByString('B8')).value = NumberCellValue(stats.totalHadir);
    summarySheet.cell(CellIndex.indexByString('C8')).value = 
        TextCellValue('${stats.percentageHadir.toStringAsFixed(1)}%');
    summarySheet.cell(CellIndex.indexByString('A8')).cellStyle = boldStyle;
    
    summarySheet.cell(CellIndex.indexByString('A9')).value = TextCellValue('Total Izin');
    summarySheet.cell(CellIndex.indexByString('B9')).value = NumberCellValue(stats.totalIzin);
    summarySheet.cell(CellIndex.indexByString('C9')).value = 
        TextCellValue('${stats.percentageIzin.toStringAsFixed(1)}%');
    summarySheet.cell(CellIndex.indexByString('A9')).cellStyle = boldStyle;
    
    summarySheet.cell(CellIndex.indexByString('A10')).value = TextCellValue('Total Sakit');
    summarySheet.cell(CellIndex.indexByString('B10')).value = NumberCellValue(stats.totalSakit);
    summarySheet.cell(CellIndex.indexByString('C10')).value = 
        TextCellValue('${stats.percentageSakit.toStringAsFixed(1)}%');
    summarySheet.cell(CellIndex.indexByString('A10')).cellStyle = boldStyle;
    
    summarySheet.cell(CellIndex.indexByString('A11')).value = TextCellValue('Total Alpa');
    summarySheet.cell(CellIndex.indexByString('B11')).value = NumberCellValue(stats.totalAlpa);
    summarySheet.cell(CellIndex.indexByString('C11')).value = 
        TextCellValue('${stats.percentageAlpa.toStringAsFixed(1)}%');
    summarySheet.cell(CellIndex.indexByString('A11')).cellStyle = boldStyle;
    
    // Add empty row
    summarySheet.cell(CellIndex.indexByString('A12')).value = TextCellValue('');
    
    // If we have detailed student data, add another sheet
    if (students != null && students.isNotEmpty && attendances != null && attendances.isNotEmpty) {
      final detailSheet = excel['Detail Kehadiran'];
      
      // Header
      final detailHeaderCell = detailSheet.cell(CellIndex.indexByString('A1'));
      detailHeaderCell.value = TextCellValue('DETAIL KEHADIRAN SISWA');
      detailHeaderCell.cellStyle = headerStyle;
      detailSheet.merge(CellIndex.indexByString('A1'), CellIndex.indexByString('E1'));
      
      // Column headers
      detailSheet.cell(CellIndex.indexByString('A2')).value = TextCellValue('No');
      detailSheet.cell(CellIndex.indexByString('B2')).value = TextCellValue('NIS');
      detailSheet.cell(CellIndex.indexByString('C2')).value = TextCellValue('Nama Siswa');
      detailSheet.cell(CellIndex.indexByString('D2')).value = TextCellValue('Tanggal');
      detailSheet.cell(CellIndex.indexByString('E2')).value = TextCellValue('Status');
      detailSheet.cell(CellIndex.indexByString('F2')).value = TextCellValue('Keterangan');
      
      // Apply style to headers
      for (var col = 0; col < 6; col++) {
        detailSheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 1)).cellStyle = subHeaderStyle;
      }
      
      // Set column widths
      detailSheet.setColumnWidth(0, 5); // No
      detailSheet.setColumnWidth(1, 15); // NIS
      detailSheet.setColumnWidth(2, 30); // Nama Siswa
      detailSheet.setColumnWidth(3, 15); // Tanggal
      detailSheet.setColumnWidth(4, 15); // Status
      detailSheet.setColumnWidth(5, 25); // Keterangan
      
      // Map to store student data
      final Map<int, Student> studentMap = {};
      for (final student in students) {
        studentMap[student.id] = student;
      }
      
      // Fill in student attendance data
      int row = 3;
      int counter = 1;
      for (final attendance in attendances) {
        final student = studentMap[attendance.studentId];
        if (student != null) {
          detailSheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row-1)).value = 
              NumberCellValue(counter);
          detailSheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row-1)).value = 
              TextCellValue(student.nis);
          detailSheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row-1)).value = 
              TextCellValue(student.name);
          detailSheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row-1)).value = 
              TextCellValue(_formatDate(attendance.date));
          detailSheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: row-1)).value = 
              TextCellValue(_capitalizeFirst(attendance.status));
          detailSheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: row-1)).value = 
              TextCellValue(attendance.note ?? '-');
          
          // Apply style
          for (var col = 0; col < 6; col++) {
            var cellStyle = normalStyle;
            if (col == 0 || col == 3 || col == 4) {
              cellStyle = centerStyle;
            }
            detailSheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row-1)).cellStyle = cellStyle;
          }
          
          row++;
          counter++;
        }
      }
    }
    
    // Convert to bytes
    final bytes = excel.save();
    return bytes!;
  }
  
  // Helper function to convert hex color string to ExcelColor
  static ExcelColor getColorFromHex(String hexString) {
    final hexColor = int.parse("0xFF$hexString");
    return ExcelColor.fromArgb(
      (hexColor >> 24) & 0xFF,  // A
      (hexColor >> 16) & 0xFF,  // R
      (hexColor >> 8) & 0xFF,   // G
      hexColor & 0xFF,          // B
    );
  }
  
  static String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }
  
  static String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}