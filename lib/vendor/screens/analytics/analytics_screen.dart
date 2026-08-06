// import 'package:flutter/material.dart';
// import 'package:fl_chart/fl_chart.dart';
// import '../../models/order.dart';
// import '../../services/order_service.dart';
// import '../../widgets/common/loading_skeleton.dart';
// import 'package:intl/intl.dart';

// class AnalyticsScreen extends StatefulWidget {
//   const AnalyticsScreen({super.key});

//   @override
//   State<AnalyticsScreen> createState() => _AnalyticsScreenState();
// }

// class _AnalyticsScreenState extends State<AnalyticsScreen>
//     with TickerProviderStateMixin {
//   late TabController _tabController;
//   final OrderService _orderService = OrderService();

//   // Date filters
//   DateTimeRange _selectedDateRange = DateTimeRange(
//     start: DateTime.now().subtract(const Duration(days: 30)),
//     end: DateTime.now(),
//   );

//   // Analytics data
//   List<Order> _orders = [];
//   bool _isLoading = true;
//   String? _error;

//   // Computed analytics
//   Map<String, dynamic> _analytics = {};

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 4, vsync: this);
//     _loadAnalyticsData();
//   }

//   Future<void> _loadAnalyticsData() async {
//     setState(() {
//       _isLoading = true;
//       _error = null;
//     });

//     try {
//       // Load all orders for the selected date range
//       final response = await _orderService.getVendorOrders(
//         page: 1,
//         limit: 1000, // Get all orders for analytics
//       );

//       if (response.success && response.data != null) {
//         final filteredOrders = response.data!.where((order) {
//           return order.createdAt.isAfter(_selectedDateRange.start) &&
//                  order.createdAt.isBefore(_selectedDateRange.end.add(const Duration(days: 1)));
//         }).toList();

//         setState(() {
//           _orders = filteredOrders;
//           _analytics = _calculateAnalytics(filteredOrders);
//         });
//       } else {
//         setState(() {
//           _error = response.error ?? 'فشل في تحميل البيانات';
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _error = 'حدث خطأ: ${e.toString()}';
//       });
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   Map<String, dynamic> _calculateAnalytics(List<Order> orders) {
//     if (orders.isEmpty) {
//       return {
//         'totalRevenue': 0.0,
//         'totalOrders': 0,
//         'averageOrderValue': 0.0,
//         'statusBreakdown': <String, int>{},
//         'dailyRevenue': <DateTime, double>{},
//         'dailyOrders': <DateTime, int>{},
//         'topDays': <String>[],
//         'conversionRate': 0.0,
//       };
//     }

//     // Calculate basic metrics
//     final totalOrders = orders.length;
//     final totalRevenue = orders.fold(0.0, (sum, order) => sum + order.price);
//     final averageOrderValue = totalRevenue / totalOrders;

//     // Status breakdown
//     final statusBreakdown = <String, int>{};
//     for (final order in orders) {
//       statusBreakdown[order.status] = (statusBreakdown[order.status] ?? 0) + 1;
//     }

//     // Daily metrics
//     final dailyRevenue = <DateTime, double>{};
//     final dailyOrders = <DateTime, int>{};
    
//     for (final order in orders) {
//       final date = DateTime(order.createdAt.year, order.createdAt.month, order.createdAt.day);
//       dailyRevenue[date] = (dailyRevenue[date] ?? 0.0) + order.price;
//       dailyOrders[date] = (dailyOrders[date] ?? 0) + 1;
//     }

//     // Top performing days
//     final sortedDays = dailyRevenue.entries.toList()
//       ..sort((a, b) => b.value.compareTo(a.value));
//     final topDays = sortedDays.take(3).map((e) => DateFormat('EEEE', 'ar').format(e.key)).toList();

//     // Conversion rate (accepted orders / total orders)
//     final acceptedOrders = orders.where((o) => 
//         o.status == OrderStatus.accepted || 
//         o.status == OrderStatus.preparing || 
//         o.status == OrderStatus.ready || 
//         o.status == OrderStatus.delivered
//     ).length;
//     final conversionRate = totalOrders > 0 ? (acceptedOrders / totalOrders) * 100 : 0.0;

//     return {
//       'totalRevenue': totalRevenue,
//       'totalOrders': totalOrders,
//       'averageOrderValue': averageOrderValue,
//       'statusBreakdown': statusBreakdown,
//       'dailyRevenue': dailyRevenue,
//       'dailyOrders': dailyOrders,
//       'topDays': topDays,
//       'conversionRate': conversionRate,
//     };
//   }

//   Future<void> _selectDateRange() async {
//     final DateTimeRange? picked = await showDateRangePicker(
//       context: context,
//       firstDate: DateTime.now().subtract(const Duration(days: 365)),
//       lastDate: DateTime.now(),
//       initialDateRange: _selectedDateRange,
//       locale: const Locale('ar'),
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: Theme.of(context).colorScheme.copyWith(
//               primary: Colors.blue[700],
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );

//     if (picked != null && picked != _selectedDateRange) {
//       setState(() {
//         _selectedDateRange = picked;
//       });
//       _loadAnalyticsData();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       appBar: AppBar(
//         title: const Text(
//           'التحليلات والتقارير',
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//           ),
//         ),
//         backgroundColor: Colors.blue[700],
//         elevation: 0,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.date_range, color: Colors.white),
//             onPressed: _selectDateRange,
//           ),
//           IconButton(
//             icon: const Icon(Icons.refresh, color: Colors.white),
//             onPressed: _loadAnalyticsData,
//           ),
//         ],
//         bottom: PreferredSize(
//           preferredSize: const Size.fromHeight(100),
//           child: Column(
//             children: [
//               // Date range display
//               Container(
//                 margin: const EdgeInsets.symmetric(horizontal: 16),
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(Icons.calendar_today, color: Colors.white, size: 16),
//                     const SizedBox(width: 8),
//                     Text(
//                       '${DateFormat('dd/MM/yyyy').format(_selectedDateRange.start)} - ${DateFormat('dd/MM/yyyy').format(_selectedDateRange.end)}',
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 16),
//               // Tabs
//               TabBar(
//                 controller: _tabController,
//                 isScrollable: true,
//                 labelColor: Colors.white,
//                 unselectedLabelColor: Colors.white70,
//                 indicatorColor: Colors.white,
//                 labelStyle: const TextStyle(fontWeight: FontWeight.bold),
//                 tabs: const [
//                   Tab(text: 'نظرة عامة'),
//                   Tab(text: 'المبيعات'),
//                   Tab(text: 'الطلبات'),
//                   Tab(text: 'التقارير'),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//       body: _isLoading
//           ? const LoadingSkeleton()
//           : _error != null
//               ? _buildErrorWidget()
//               : TabBarView(
//                   controller: _tabController,
//                   children: [
//                     _buildOverviewTab(),
//                     _buildRevenueTab(),
//                     _buildOrdersTab(),
//                     _buildReportsTab(),
//                   ],
//                 ),
//     );
//   }

//   Widget _buildErrorWidget() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
//           const SizedBox(height: 16),
//           Text(
//             _error!,
//             textAlign: TextAlign.center,
            
//             style: TextStyle(fontSize: 16, color: Colors.grey[600]),
//           ),
//           const SizedBox(height: 16),
//           ElevatedButton(
//             onPressed: _loadAnalyticsData,
//             child: const Text('إعادة المحاولة'),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildOverviewTab() {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         children: [
//           _buildMetricsGrid(),
//           const SizedBox(height: 16),
//           _buildStatusChart(),
//           const SizedBox(height: 16),
//           _buildQuickInsights(),
//         ],
//       ),
//     );
//   }

//   Widget _buildMetricsGrid() {
//     return GridView.count(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       crossAxisCount: 2,
//       childAspectRatio: 1.5,
//       crossAxisSpacing: 12,
//       mainAxisSpacing: 12,
//       children: [
//         _buildMetricCard(
//           'إجمالي الإيرادات',
//           '${_analytics['totalRevenue']?.toStringAsFixed(2) ?? '0.00'} ج.م',
//           Icons.attach_money,
//           Colors.green,
//         ),
//         _buildMetricCard(
//           'إجمالي الطلبات',
//           '${_analytics['totalOrders'] ?? 0}',
//           Icons.shopping_cart,
//           Colors.blue,
//         ),
//         _buildMetricCard(
//           'متوسط قيمة الطلب',
//           '${_analytics['averageOrderValue']?.toStringAsFixed(2) ?? '0.00'} ج.م',
//           Icons.trending_up,
//           Colors.orange,
//         ),
//         _buildMetricCard(
//           'معدل القبول',
//           '${_analytics['conversionRate']?.toStringAsFixed(1) ?? '0.0'}%',
//           Icons.check_circle,
//           Colors.purple,
//         ),
//       ],
//     );
//   }

//   Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Container(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(12),
//           gradient: LinearGradient(
//             colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
//             begin: Alignment.topRight,
//             end: Alignment.bottomLeft,
//           ),
//         ),
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(icon, size: 32, color: color),
//             const SizedBox(height: 8),
//             Text(
//               value,
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: color,
//               ),
              
//             ),
//             const SizedBox(height: 4),
//             Text(
//               title,
//               style: const TextStyle(
//                 fontSize: 12,
//                 color: Colors.grey,
//               ),
              
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildStatusChart() {
//     final statusBreakdown = _analytics['statusBreakdown'] as Map<String, int>? ?? {};
    
//     if (statusBreakdown.isEmpty) {
//       return Card(
//         child: Container(
//           height: 200,
//           padding: const EdgeInsets.all(16),
//           child: const Center(
//             child: Text(
//               'لا توجد بيانات لعرض المخطط',
//               style: TextStyle(color: Colors.grey),
              
//             ),
//           ),
//         ),
//       );
//     }

//     final colors = [
//       Colors.orange,
//       Colors.blue,
//       Colors.green,
//       Colors.purple,
//       Colors.teal,
//       Colors.red,
//       Colors.indigo,
//     ];

//     final sections = statusBreakdown.entries.map((entry) {
//       final index = statusBreakdown.keys.toList().indexOf(entry.key);
//       return PieChartSectionData(
//         color: colors[index % colors.length],
//         value: entry.value.toDouble(),
//         title: '${entry.value}',
//         radius: 60,
//         titleStyle: const TextStyle(
//           fontSize: 12,
//           fontWeight: FontWeight.bold,
//           color: Colors.white,
//         ),
//       );
//     }).toList();

//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'توزيع الطلبات حسب الحالة',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//               ),
              
//             ),
//             const SizedBox(height: 16),
//             SizedBox(
//               height: 200,
//               child: Row(
//                 children: [
//                   Expanded(
//                     flex: 2,
//                     child: PieChart(
//                       PieChartData(
//                         sections: sections,
//                         sectionsSpace: 2,
//                         centerSpaceRadius: 40,
//                         startDegreeOffset: -90,
//                       ),
//                     ),
//                   ),
//                   Expanded(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: statusBreakdown.entries.map((entry) {
//                         final index = statusBreakdown.keys.toList().indexOf(entry.key);
//                         return Padding(
//                           padding: const EdgeInsets.symmetric(vertical: 4),
//                           child: Row(
//                             children: [
//                               Container(
//                                 width: 12,
//                                 height: 12,
//                                 decoration: BoxDecoration(
//                                   color: colors[index % colors.length],
//                                   shape: BoxShape.circle,
//                                 ),
//                               ),
//                               const SizedBox(width: 8),
//                               Expanded(
//                                 child: Text(
//                                   OrderStatus.getStatusDisplayName(entry.key),
//                                   style: const TextStyle(fontSize: 12),
                                  
//                                 ),
//                               ),
//                             ],
//                           ),
//                         );
//                       }).toList(),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildQuickInsights() {
//     final topDays = _analytics['topDays'] as List<String>? ?? [];
    
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'رؤى سريعة',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//               ),
              
//             ),
//             const SizedBox(height: 16),
            
//             if (topDays.isNotEmpty) ...[
//               _buildInsightRow(
//                 Icons.star,
//                 'أفضل الأيام',
//                 topDays.join(', '),
//                 Colors.amber,
//               ),
//               const SizedBox(height: 12),
//             ],
            
//             _buildInsightRow(
//               Icons.schedule,
//               'فترة التحليل',
//               '${(_selectedDateRange.end.difference(_selectedDateRange.start).inDays + 1)} يوم',
//               Colors.blue,
//             ),
//             const SizedBox(height: 12),
            
//             _buildInsightRow(
//               Icons.trending_up,
//               'متوسط الطلبات اليومية',
//               '${(_analytics['totalOrders'] / (_selectedDateRange.end.difference(_selectedDateRange.start).inDays + 1)).toStringAsFixed(1)}',
//               Colors.green,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildInsightRow(IconData icon, String label, String value, Color color) {
//     return Row(
//       children: [
//         Icon(icon, color: color, size: 20),
//         const SizedBox(width: 12),
//         Text(
//           '$label: ',
//           style: const TextStyle(
//             fontSize: 14,
//             fontWeight: FontWeight.w500,
//           ),
          
//         ),
//         Expanded(
//           child: Text(
//             value,
//             style: TextStyle(
//               fontSize: 14,
//               color: color,
//               fontWeight: FontWeight.w500,
//             ),
            
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildRevenueTab() {
//     final dailyRevenue = _analytics['dailyRevenue'] as Map<DateTime, double>? ?? {};
    
//     if (dailyRevenue.isEmpty) {
//       return const Center(
//         child: Text(
//           'لا توجد بيانات إيرادات',
//           style: TextStyle(color: Colors.grey),
          
//         ),
//       );
//     }

//     final sortedEntries = dailyRevenue.entries.toList()
//       ..sort((a, b) => a.key.compareTo(b.key));

//     final spots = sortedEntries.asMap().entries.map((entry) {
//       return FlSpot(entry.key.toDouble(), entry.value.value);
//     }).toList();

//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         children: [
//           Card(
//             elevation: 2,
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//             child: Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     'الإيرادات اليومية',
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
                    
//                   ),
//                   const SizedBox(height: 16),
//                   SizedBox(
//                     height: 300,
//                     child: LineChart(
//                       LineChartData(
//                         gridData: FlGridData(show: true),
//                         titlesData: FlTitlesData(
//                           bottomTitles: AxisTitles(
//                             sideTitles: SideTitles(
//                               showTitles: true,
//                               getTitlesWidget: (value, meta) {
//                                 if (value.toInt() < sortedEntries.length) {
//                                   final date = sortedEntries[value.toInt()].key;
//                                   return Text(
//                                     DateFormat('dd/MM').format(date),
//                                     style: const TextStyle(fontSize: 10),
//                                   );
//                                 }
//                                 return const Text('');
//                               },
//                             ),
//                           ),
//                           leftTitles: AxisTitles(
//                             sideTitles: SideTitles(
//                               showTitles: true,
//                               getTitlesWidget: (value, meta) {
//                                 return Text(
//                                   '${value.toInt()}',
//                                   style: const TextStyle(fontSize: 10),
//                                 );
//                               },
//                             ),
//                           ),
//                           topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
//                           rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
//                         ),
//                         borderData: FlBorderData(show: true),
//                         lineBarsData: [
//                           LineChartBarData(
//                             spots: spots,
//                             isCurved: true,
//                             color: Colors.green,
//                             barWidth: 3,
//                             belowBarData: BarAreaData(
//                               show: true,
//                               color: Colors.green.withOpacity(0.1),
//                             ),
//                             dotData: FlDotData(show: true),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildOrdersTab() {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         children: [
//           // Recent orders list
//           Card(
//             elevation: 2,
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//             child: Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     'الطلبات الأخيرة',
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
                    
//                   ),
//                   const SizedBox(height: 16),
                  
//                   if (_orders.isEmpty)
//                     const Center(
//                       child: Text(
//                         'لا توجد طلبات في هذه الفترة',
//                         style: TextStyle(color: Colors.grey),
                        
//                       ),
//                     )
//                   else
//                     ..._orders.take(10).map((order) => _buildOrderTile(order)),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildOrderTile(Order order) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 8),
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.grey[50],
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: Colors.grey[200]!),
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 40,
//             height: 40,
//             decoration: BoxDecoration(
//               color: _getStatusColor(order.status),
//               borderRadius: BorderRadius.circular(20),
//             ),
//             child: Center(
//               child: Text(
//                 '#${order.id}',
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.bold,
//                   fontSize: 12,
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(width: 12),
          
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   order.description.length > 50 
//                       ? '${order.description.substring(0, 50)}...'
//                       : order.description,
//                   style: const TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w500,
//                   ),
                  
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   DateFormat('dd/MM/yyyy - hh:mm a', 'ar').format(order.createdAt),
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: Colors.grey[600],
//                   ),
                  
//                 ),
//               ],
//             ),
//           ),
          
//           Text(
//             '${order.price.toStringAsFixed(2)} ج.م',
//             style: const TextStyle(
//               fontSize: 14,
//               fontWeight: FontWeight.bold,
//               color: Colors.green,
//             ),
            
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildReportsTab() {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         children: [
//           Card(
//             elevation: 2,
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//             child: Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     'تصدير التقارير',
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
                    
//                   ),
//                   const SizedBox(height: 16),
                  
//                   _buildExportButton(
//                     'تقرير المبيعات',
//                     'تصدير بيانات المبيعات والإيرادات',
//                     Icons.monetization_on,
//                     Colors.green,
//                     () => _exportSalesReport(),
//                   ),
//                   const SizedBox(height: 12),
                  
//                   _buildExportButton(
//                     'تقرير الطلبات',
//                     'تصدير قائمة الطلبات وتفاصيلها',
//                     Icons.list_alt,
//                     Colors.blue,
//                     () => _exportOrdersReport(),
//                   ),
//                   const SizedBox(height: 12),
                  
//                   _buildExportButton(
//                     'تقرير الأداء',
//                     'تصدير إحصائيات الأداء والتحليلات',
//                     Icons.analytics,
//                     Colors.purple,
//                     () => _exportPerformanceReport(),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildExportButton(
//     String title,
//     String subtitle,
//     IconData icon,
//     Color color,
//     VoidCallback onPressed,
//   ) {
//     return Container(
//       width: double.infinity,
//       decoration: BoxDecoration(
//         border: Border.all(color: Colors.grey[300]!),
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           onTap: onPressed,
//           borderRadius: BorderRadius.circular(8),
//           child: Padding(
//             padding: const EdgeInsets.all(16),
//             child: Row(
//               children: [
//                 Icon(icon, color: color, size: 24),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         title,
//                         style: const TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w500,
//                         ),
                        
//                       ),
//                       Text(
//                         subtitle,
//                         style: TextStyle(
//                           fontSize: 14,
//                           color: Colors.grey[600],
//                         ),
                        
//                       ),
//                     ],
//                   ),
//                 ),
//                 Icon(Icons.file_download, color: Colors.grey[600]),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Color _getStatusColor(String status) {
//     switch (status) {
//       case OrderStatus.pending:
//         return Colors.orange;
//       case OrderStatus.accepted:
//         return Colors.green;
//       case OrderStatus.cancelled:
//         return Colors.red;
//       default:
//         return Colors.blue;
//     }
//   }

//   void _exportSalesReport() {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text('سيتم تطوير وظيفة التصدير قريباً'),
//         backgroundColor: Colors.blue,
//       ),
//     );
//   }

//   void _exportOrdersReport() {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text('سيتم تطوير وظيفة التصدير قريباً'),
//         backgroundColor: Colors.blue,
//       ),
//     );
//   }

//   void _exportPerformanceReport() {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text('سيتم تطوير وظيفة التصدير قريباً'),
//         backgroundColor: Colors.blue,
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }
// }
