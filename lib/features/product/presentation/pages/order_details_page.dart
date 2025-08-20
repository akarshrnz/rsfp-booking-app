import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:innerspace_booking_app/core/color_constant.dart';
import 'package:innerspace_booking_app/core/constants.dart';
import 'package:innerspace_booking_app/features/product/data/models/order.dart';
import '../../data/datasources/firestore_service.dart';

class OrderDetailsPage extends StatelessWidget {
  final String orderId;
  const OrderDetailsPage({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    final service = FirestoreService();
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Order Details',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: StreamBuilder<OrderModel>(
        stream: service.orderStream(orderId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return  Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
              ),
            );
          }
          
          if (!snapshot.hasData || snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    snapshot.hasError ? 'Error loading order' : 'Order not found',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: const Text('Go Back', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            );
          }
          
          final order = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order ID Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ORDER ID',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        order.id,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: _getStatusColor(order.status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.local_shipping_rounded,
                              size: 16,
                              color: _getStatusColor(order.status),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              order.status.replaceAll("_", " ").toUpperCase(),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: _getStatusColor(order.status),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 28),
                
                // Order Progress
                Text(
                  "ORDER PROGRESS",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                    letterSpacing: 0.5,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: List.generate(statusSteps.length, (index) {
                      final done = index <= statusIndex(order.status);
                      final isCurrent = index == statusIndex(order.status);
                      
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: done ? Colors.green : Colors.grey[300],
                                  shape: BoxShape.circle,
                                  boxShadow: done ? [
                                    BoxShadow(
                                      color: primaryColor.withOpacity(0.3),
                                      blurRadius: 6,
                                      offset: const Offset(0, 3),
                                    )
                                  ] : null,
                                ),
                                child: Icon(
                                  done ? Icons.check_rounded : Icons.circle,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                              if (index != statusSteps.length - 1)
                                Container(
                                  width: 2,
                                  height: 48,
                                  color: done ? Colors.green  : Colors.grey[300],
                                ),
                            ],
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Padding(
                              padding:  EdgeInsets.only(top: 4, bottom: index != statusSteps.length - 1 ? 24 : 0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    statusSteps[index].replaceAll("_", " ").toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: isCurrent ? FontWeight.w700 : (done ? FontWeight.w600 : FontWeight.normal),
                                      color: isCurrent ? primaryColor : (done ? Colors.black87 : Colors.grey.shade600),
                                    ),
                                  ),
                                  if (isCurrent && index != statusSteps.length - 1)
                                    const SizedBox(height: 4),
                                  // if (isCurrent && index != statusSteps.length - 1)
                                  //   Text(
                                  //     'Next: ${statusSteps[index + 1].replaceAll("_", " ").toUpperCase()}',
                                  //     style: TextStyle(
                                  //       fontSize: 12,
                                  //       color: Colors.grey.shade500,
                                  //     ),
                                  //   ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Barcode Section
                Text(
                  "SCAN TO UPDATE",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                    letterSpacing: 0.5,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: BarcodeWidget(
                          barcode: Barcode.code128(),
                          data: order.barcode,
                          width: 280,
                          height: 100,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Scan at warehouse to update status',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'processing':
        return Colors.orange;
      case 'shipped':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.black;
    }
  }
}


// Future<void> _handleBarcodeDetected(BarcodeCapture barcodes) async {
//     if (barcodes.barcodes.isEmpty) return;
    
//     final Barcode barcode = barcodes.barcodes.first;
//     if (barcode.rawValue == null) return;

//     final String code = barcode.rawValue!;
    
//     // Stop scanning after detection
//     _stopScanning();
    
//     final ok = await service.updateOrderStatusByBarcode(code, selected);
//     if (!mounted) return;

//    // if (user != null) {
//         final notification = NotificationEntity(
//           id: DateTime.now().millisecondsSinceEpoch.toString(),
//           title: 'Product update',
//           body: 'Your product reached $selected',
//           timestamp: DateTime.now(),
//         );
//         context.read<NotificationBloc>().add(AddNotification(notification, dummyUserId));
//     //  }
    
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(ok ? 'Updated $code → $selected' : 'Invalid barcode'))
//     );
//   }