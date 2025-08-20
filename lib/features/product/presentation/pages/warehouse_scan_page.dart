import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:innerspace_booking_app/features/notification/domain/entities/notification.dart';
import 'package:innerspace_booking_app/features/notification/presentation/bloc/notification_bloc.dart';
import 'package:innerspace_booking_app/features/notification/presentation/bloc/notification_event.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:innerspace_booking_app/core/constants.dart';
import '../../data/datasources/firestore_service.dart';

class WarehouseScanPage extends StatefulWidget {
  const WarehouseScanPage({super.key});
  @override
  State<WarehouseScanPage> createState() => _WarehouseScanPageState();
}

class _WarehouseScanPageState extends State<WarehouseScanPage> {
  String selected = statusSteps[1];
  final service = FirestoreService();
  MobileScannerController cameraController = MobileScannerController();
  bool isScanning = false;

  void _startScanning() {
    setState(() {
      isScanning = true;
    });
  }

  void _stopScanning() {
    setState(() {
      isScanning = false;
    });
    cameraController.stop();
  }

  Future<void> _handleBarcodeDetected(BarcodeCapture barcodes) async {
    if (barcodes.barcodes.isEmpty) return;
    
    final Barcode barcode = barcodes.barcodes.first;
    if (barcode.rawValue == null) return;

    final String code = barcode.rawValue!;
    
    // Stop scanning after detection
    _stopScanning();
    
    final ok = await service.updateOrderStatusByBarcode(code, selected);
    if (!mounted) return;

    if (selected != "pending") {
        final notification = NotificationEntity(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: 'Order Update',
          body: 'Your product ${selected=="delivered"?"":" "}${selected.replaceAll('_', ' ').toUpperCase()}',
          timestamp: DateTime.now(),
        );
        context.read<NotificationBloc>().add(AddNotification(notification, dummyUserId));
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? 'Updated $code → $selected' : 'Invalid barcode'))
    );
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Warehouse Scanner',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      backgroundColor: Colors.grey[50],
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status selection card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'UPDATE STATUS TO',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButton<String>(
                        value: selected,
                        isExpanded: true,
                        underline: const SizedBox(),
                        icon: const Icon(Icons.arrow_drop_down_rounded),
                        items: statusSteps.map((e) => DropdownMenuItem(
                          value: e, 
                          child: Text(
                            e.replaceAll('_', ' ').toUpperCase(),
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )).toList(),
                        onChanged: (v) => setState(() => selected = v!),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Scanner section
            if (isScanning)
              Expanded(
                child: Column(
                  children: [
                    Text(
                      'SCANNING...',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Point camera at barcode',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Stack(
                          children: [
                            MobileScanner(
                              controller: cameraController,
                              onDetect: _handleBarcodeDetected,
                            ),
                            // Scanner overlay
                            Center(
                              child: Container(
                                width: 200,
                                height: 200,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.2),
                            blurRadius: 12,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.qr_code_scanner_rounded,
                        size: 64,
                        color: Colors.blue[700],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Ready to Scan',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Scan barcodes to update order status',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            
            const SizedBox(height: 24),
            
            // Action buttons
            if (isScanning)
              ElevatedButton.icon(
                onPressed: _stopScanning,
                icon: const Icon(Icons.stop_circle_rounded, size: 20),
                label: const Text('STOP SCANNING'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            else
              ElevatedButton.icon(
                onPressed: _startScanning,
                icon: const Icon(Icons.qr_code_scanner_rounded, size: 20),
                label: const Text('START SCANNING'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}