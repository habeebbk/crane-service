import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../database_helper.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String _selectedPeriod = 'This Month'; // This Month, This Year, All Time

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Analytics & Reports'),
      ),
      body: Consumer<DataProvider>(
        builder: (context, provider, child) {
          final filteredData = _getFilteredData(provider.orders);
          final paidOrders =
              filteredData.where((o) => o.paymentStatus == 1).toList();
          final pendingOrders =
              filteredData.where((o) => o.paymentStatus == 0).toList();
          final totalRevenue = filteredData.fold(0.0, (sum, o) => sum + o.cost);
          final paidRevenue = paidOrders.fold(0.0, (sum, o) => sum + o.cost);
          final pendingRevenue =
              pendingOrders.fold(0.0, (sum, o) => sum + o.cost);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Period Selector
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildPeriodChip(
                          'This Month', _selectedPeriod == 'This Month'),
                      _buildPeriodChip(
                          'This Year', _selectedPeriod == 'This Year'),
                      _buildPeriodChip(
                          'All Time', _selectedPeriod == 'All Time'),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Summary Cards
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Total Revenue',
                        totalRevenue,
                        Icons.currency_rupee,
                        Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Total Orders',
                        filteredData.length.toDouble(),
                        Icons.receipt_long,
                        Colors.blue,
                        isCurrency: false,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Paid',
                        paidRevenue,
                        Icons.check_circle,
                        Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Pending',
                        pendingRevenue,
                        Icons.pending,
                        Colors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Payment Status Chart (Simple Visual)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Payment Status',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildPaymentStatusBar(
                          paidOrders.length, pendingOrders.length),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _buildLegendItem(
                              'Paid', Colors.green, paidOrders.length),
                          const SizedBox(width: 24),
                          _buildLegendItem(
                              'Pending', Colors.orange, pendingOrders.length),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Service Category Breakdown
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Service Categories',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ..._buildCategoryBreakdown(filteredData),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Top Customers
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Top Customers',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ..._buildTopCustomers(filteredData),
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

  Widget _buildPeriodChip(String label, bool isSelected) {
    return InkWell(
      onTap: () => setState(() => _selectedPeriod = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color:
              isSelected ? Theme.of(context).primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade700,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, double value, IconData icon, Color color,
      {bool isCurrency = true}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.8), color],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isCurrency
                ? NumberFormat.compactCurrency(symbol: '₹').format(value)
                : value.toInt().toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentStatusBar(int paid, int pending) {
    final total = paid + pending;
    if (total == 0) {
      return const Center(
        child: Text('No data available', style: TextStyle(color: Colors.grey)),
      );
    }

    final paidPercent = (paid / total) * 100;
    final pendingPercent = (pending / total) * 100;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: paid,
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: pending,
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Paid: ${paidPercent.toStringAsFixed(1)}%',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            Text(
              'Pending: ${pendingPercent.toStringAsFixed(1)}%',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color, int count) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$label ($count)',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildCategoryBreakdown(List<OrderWithDetails> orders) {
    final categoryMap = <String, double>{};
    for (var order in orders) {
      categoryMap[order.serviceCategory] =
          (categoryMap[order.serviceCategory] ?? 0) + order.cost;
    }

    final sortedCategories = categoryMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (sortedCategories.isEmpty) {
      return [
        const Center(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Text('No category data available',
                style: TextStyle(color: Colors.grey)),
          ),
        ),
      ];
    }

    return sortedCategories.take(5).map((entry) {
      final total = categoryMap.values.fold(0.0, (a, b) => a + b);
      final percentage = (entry.value / total) * 100;

      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    entry.key,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
                Text(
                  '₹${entry.value.toInt()} (${percentage.toStringAsFixed(1)}%)',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: percentage / 100,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                ),
                minHeight: 8,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  List<Widget> _buildTopCustomers(List<OrderWithDetails> orders) {
    final customerMap = <String, Map<String, dynamic>>{};
    for (var order in orders) {
      if (customerMap.containsKey(order.customerName)) {
        customerMap[order.customerName]!['count'] =
            (customerMap[order.customerName]!['count'] as int) + 1;
        customerMap[order.customerName]!['total'] =
            (customerMap[order.customerName]!['total'] as double) + order.cost;
      } else {
        customerMap[order.customerName] = {
          'count': 1,
          'total': order.cost,
          'phone': order.customerPhone,
        };
      }
    }

    final sortedCustomers = customerMap.entries.toList()
      ..sort((a, b) => b.value['total'].compareTo(a.value['total']));

    if (sortedCustomers.isEmpty) {
      return [
        const Center(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Text('No customer data available',
                style: TextStyle(color: Colors.grey)),
          ),
        ),
      ];
    }

    return sortedCustomers.take(5).map((entry) {
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.key,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${entry.value['count']} orders',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '₹${(entry.value['total'] as double).toInt()}',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 18,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  List<OrderWithDetails> _getFilteredData(List<OrderWithDetails> allOrders) {
    final now = DateTime.now();
    switch (_selectedPeriod) {
      case 'This Month':
        return allOrders.where((order) {
          final orderDate = DateTime.tryParse(order.date);
          if (orderDate == null) return false;
          return orderDate.year == now.year && orderDate.month == now.month;
        }).toList();
      case 'This Year':
        return allOrders.where((order) {
          final orderDate = DateTime.tryParse(order.date);
          if (orderDate == null) return false;
          return orderDate.year == now.year;
        }).toList();
      case 'All Time':
      default:
        return allOrders;
    }
  }
}
