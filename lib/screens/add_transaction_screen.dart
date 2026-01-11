import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../database_helper.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _customerNameController = TextEditingController();
  final _customerPhoneController = TextEditingController();
  final _serviceNameController = TextEditingController();

  // Dynamic Cost Items
  final List<Map<String, dynamic>> _costControllers = [
    {
      'name': TextEditingController(),
      'amount': TextEditingController(),
    }
  ];

  DateTime _selectedDate = DateTime.now();
  int _paymentStatus = 0; // 0: Pending, 1: Paid

  // No longer using fixed list for dropdown
  // final List<String> _categories = ...

  String _selectedCategory = 'Loading and Unloading';
  bool _isCustomCategory = false;
  final _customCategoryController = TextEditingController();

  bool _isSaving = false;

  @override
  void dispose() {
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    _serviceNameController.dispose();
    for (var map in _costControllers) {
      (map['name'] as TextEditingController).dispose();
      (map['amount'] as TextEditingController).dispose();
    }
    _customCategoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('New Order'),
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --- Customer Section ---
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).primaryColor.withOpacity(0.1),
                        Theme.of(context).primaryColor.withOpacity(0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.person_outline,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Customer Details',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _customerNameController,
                  decoration: const InputDecoration(
                    labelText: 'Customer Name',
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (val) => val!.isEmpty ? 'Enter Name' : null,
                  textCapitalization: TextCapitalization.words,
                  enabled: !_isSaving,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _customerPhoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    prefixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (val) => val!.isEmpty ? 'Enter Phone' : null,
                  enabled: !_isSaving,
                ),
                const SizedBox(height: 28),

                // --- Service Section ---
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).primaryColor.withOpacity(0.1),
                        Theme.of(context).primaryColor.withOpacity(0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.work_outline,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Service Details',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // --- Service Category Selection ---
                const Text(
                  'Work Type / Category',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF475569),
                  ),
                ),
                const SizedBox(height: 12),

                // Default Option 1
                _buildCategoryOption('Loading and Unloading'),
                const SizedBox(height: 10),

                // Default Option 2
                _buildCategoryOption('Accident Recovery'),
                const SizedBox(height: 10),

                // Add More Button or Custom Input
                if (!_isCustomCategory)
                  InkWell(
                    onTap: () => setState(() {
                      _isCustomCategory = true;
                      _selectedCategory = '';
                    }),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).primaryColor,
                          width: 1,
                          style: BorderStyle.solid,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        color: Theme.of(context).primaryColor.withOpacity(0.05),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_circle_outline_rounded,
                            size: 20,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Add More / Other Service',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Custom Category',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          TextButton(
                            onPressed: () => setState(() {
                              _isCustomCategory = false;
                              _selectedCategory = 'Loading and Unloading';
                              _customCategoryController.clear();
                            }),
                            child: const Text('Cancel'),
                          ),
                        ],
                      ),
                      TextFormField(
                        controller: _customCategoryController,
                        decoration: InputDecoration(
                          hintText: 'Enter service type...',
                          prefixIcon: const Icon(Icons.edit_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (val) {
                          if (_isCustomCategory &&
                              (val == null || val.isEmpty)) {
                            return 'Please enter a category';
                          }
                          return null;
                        },
                        textCapitalization: TextCapitalization.words,
                      ),
                    ],
                  ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _serviceNameController,
                  decoration: const InputDecoration(
                    labelText: 'Service Name / Description',
                    prefixIcon: Icon(Icons.work),
                  ),
                  validator: (val) =>
                      val!.isEmpty ? 'Enter Service Details' : null,
                  textCapitalization: TextCapitalization.sentences,
                  enabled: !_isSaving,
                ),
                const SizedBox(height: 24),

                // --- Cost Breakdown Section ---
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).primaryColor.withOpacity(0.1),
                        Theme.of(context).primaryColor.withOpacity(0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.receipt_long_outlined,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Cost Breakdown',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextButton.icon(
                          onPressed: _isSaving
                              ? null
                              : () {
                                  setState(() {
                                    _costControllers.add({
                                      'name': TextEditingController(),
                                      'amount': TextEditingController(),
                                    });
                                  });
                                },
                          icon: const Icon(Icons.add_rounded,
                              color: Colors.white, size: 20),
                          label: const Text(
                            'Add Item',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _costControllers.length,
                  itemBuilder: (context, index) {
                    return Container(
                      key: ObjectKey(_costControllers[index]),
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: TextFormField(
                              controller: _costControllers[index]['name']
                                  as TextEditingController,
                              decoration: InputDecoration(
                                hintText: 'Item Name (e.g. Crane)',
                                hintStyle:
                                    TextStyle(color: Colors.grey.shade400),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                              validator: (val) =>
                                  val!.isEmpty ? 'Required' : null,
                              onChanged: (_) => setState(() {}),
                              enabled: !_isSaving,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: _costControllers[index]['amount']
                                  as TextEditingController,
                              decoration: InputDecoration(
                                hintText: 'Amount',
                                hintStyle:
                                    TextStyle(color: Colors.grey.shade400),
                                prefixText: '₹ ',
                                prefixStyle: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF6366F1),
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              validator: (val) =>
                                  val!.isEmpty ? 'Required' : null,
                              onChanged: (_) => setState(() {}),
                              enabled: !_isSaving,
                            ),
                          ),
                          if (_costControllers.length > 1)
                            IconButton(
                              icon: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                  size: 20,
                                ),
                              ),
                              onPressed: _isSaving
                                  ? null
                                  : () {
                                      (_costControllers[index]['name']
                                              as TextEditingController)
                                          .dispose();
                                      (_costControllers[index]['amount']
                                              as TextEditingController)
                                          .dispose();
                                      setState(() {
                                        _costControllers.removeAt(index);
                                      });
                                    },
                            ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                // Total Display
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6366F1).withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Amount:',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '₹${_calculateTotal().toInt()}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 28,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // --- Date Section ---
                const Text(
                  'Date',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: _isSaving ? null : _pickDate,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 18),
                    decoration: BoxDecoration(
                      border:
                          Border.all(color: Colors.grey.shade200, width: 1.5),
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.calendar_today_rounded,
                            size: 20,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          DateFormat('MMMM dd, yyyy').format(_selectedDate),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.grey.shade400,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // --- Payment Status ---
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: (_paymentStatus == 1
                                      ? Colors.green
                                      : Colors.orange)
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              _paymentStatus == 1
                                  ? Icons.check_circle_outline
                                  : Icons.pending_outlined,
                              color: _paymentStatus == 1
                                  ? Colors.green
                                  : Colors.orange,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Text(
                            'Payment Received',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      Switch(
                        value: _paymentStatus == 1,
                        onChanged: _isSaving
                            ? null
                            : (val) =>
                                setState(() => _paymentStatus = val ? 1 : 0),
                        activeColor: Colors.green,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Save Button
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6366F1).withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveOrder,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle_outline, size: 24),
                              SizedBox(width: 8),
                              Text(
                                'Save Order',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  double _calculateTotal() {
    double total = 0;
    for (var map in _costControllers) {
      final text = (map['amount'] as TextEditingController).text;
      total += double.tryParse(text) ?? 0;
    }
    return total;
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _saveOrder() async {
    if (_formKey.currentState!.validate()) {
      final totalCost = _calculateTotal();
      if (totalCost <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Total cost must be greater than 0')));
        return;
      }

      setState(() => _isSaving = true);

      try {
        final provider = Provider.of<DataProvider>(context, listen: false);

        // Build cost items list from controllers
        List<CostItem> costItems = [];
        for (var map in _costControllers) {
          costItems.add(CostItem(
            name: (map['name'] as TextEditingController).text,
            amount: double.tryParse(
                    (map['amount'] as TextEditingController).text) ??
                0,
          ));
        }

        // 1. Create Customer
        final customerId = await provider.addCustomer(CustomerModel(
          name: _customerNameController.text,
          phone: _customerPhoneController.text,
        ));

        // Determine final category
        final finalCategory = _isCustomCategory
            ? _customCategoryController.text
            : _selectedCategory;

        // 2. Create Service
        final serviceId = await provider.addService(ServiceModel(
          serviceName: _serviceNameController.text,
          category: finalCategory,
          cost: totalCost,
          costItems: costItems,
        ));

        // 3. Create Order
        final order = OrderModel(
          customerId: customerId,
          serviceId: serviceId,
          date: DateFormat('yyyy-MM-dd').format(_selectedDate),
          paymentStatus: _paymentStatus,
          customerName: _customerNameController.text,
          serviceName: _serviceNameController.text,
          category: finalCategory,
          cost: totalCost,
          costItems: costItems,
        );

        await provider.addOrder(order,
            customerPhone: _customerPhoneController.text);
        if (mounted) Navigator.pop(context);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Error: $e')));
          setState(() => _isSaving = false);
        }
      }
    }
  }

  Widget _buildCategoryOption(String title) {
    final isSelected = !_isCustomCategory && _selectedCategory == title;

    return InkWell(
      onTap: _isSaving
          ? null
          : () {
              setState(() {
                _isCustomCategory = false;
                _selectedCategory = title;
              });
            },
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6366F1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF6366F1) : Colors.grey.shade300,
            width: isSelected ? 0 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isSelected ? Colors.white : Colors.grey.shade400,
              size: 22,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF1E293B),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
