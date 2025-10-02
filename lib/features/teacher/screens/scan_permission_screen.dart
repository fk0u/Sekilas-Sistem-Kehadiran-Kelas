import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/database/database.dart';

class ScanPermissionScreen extends ConsumerStatefulWidget {
  const ScanPermissionScreen({super.key});

  @override
  ConsumerState<ScanPermissionScreen> createState() => _ScanPermissionScreenState();
}

class _ScanPermissionScreenState extends ConsumerState<ScanPermissionScreen> {
  MobileScannerController cameraController = MobileScannerController();
  bool _isProcessing = false;

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  Future<void> _processQRCode(String qrCode) async {
    if (_isProcessing) return;
    
    setState(() {
      _isProcessing = true;
    });

    final database = ref.read(appDatabaseProvider);
    
    try {
      final permission = await database.getPermissionByQrCode(qrCode);
      
      if (!mounted) return;

      if (permission == null) {
        _showErrorDialog('QR tidak valid', 'QR code ini tidak terdaftar dalam sistem.');
        setState(() {
          _isProcessing = false;
        });
        return;
      }

      if (permission['isUsed'] == true) {
        _showErrorDialog('QR sudah digunakan', 'QR code ini sudah pernah digunakan sebelumnya.');
        setState(() {
          _isProcessing = false;
        });
        return;
      }

      // Get student info
      final student = await database.getStudentById(permission['studentId']);
      
      if (!mounted) return;

      _showPermissionDialog(permission, student);
      
    } catch (e) {
      if (!mounted) return;
      _showErrorDialog('Error', 'Terjadi kesalahan: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showPermissionDialog(Map<String, dynamic> permission, Map<String, dynamic>? student) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Izin Valid'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Siswa: ${student?['name'] ?? 'Unknown'}'),
            const SizedBox(height: 8),
            Text('Jenis: ${permission['permissionType'] == 'izin' ? 'Izin' : 'Sakit'}'),
            const SizedBox(height: 8),
            Text('Alasan: ${permission['reason'] ?? '-'}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Mark permission as used and update attendance
              final database = ref.read(appDatabaseProvider);
              final updatedPermission = Map<String, dynamic>.from(permission);
              updatedPermission['isUsed'] = true;
              await database.updatePermission(updatedPermission);
              
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Izin berhasil divalidasi'),
                    backgroundColor: AppTheme.statusHadir,
                  ),
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Terima'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Izin'),
        actions: [
          IconButton(
            icon: Icon(
              cameraController.torchEnabled ? Icons.flash_on : Icons.flash_off,
            ),
            onPressed: () => cameraController.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.flip_camera_ios),
            onPressed: () => cameraController.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  _processQRCode(barcode.rawValue!);
                  break;
                }
              }
            },
          ),
          
          // Overlay
          ColorFiltered(
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.5),
              BlendMode.srcOut,
            ),
            child: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    backgroundBlendMode: BlendMode.dstOut,
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    height: 300,
                    width: 300,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Instructions
          Positioned(
            top: 50,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.qr_code_scanner,
                        size: 48,
                        color: AppTheme.primaryBlue,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Arahkan kamera ke QR Code',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'QR Code akan terdeteksi secara otomatis',
                        style: TextStyle(color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Processing indicator
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Memproses QR Code...'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
