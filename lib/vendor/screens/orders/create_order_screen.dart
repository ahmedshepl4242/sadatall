import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/order_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/neighborhood_dropdown.dart';

class CreateOrderScreen extends StatefulWidget {
  const CreateOrderScreen({super.key});

  @override
  State<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _notesController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _priceController = TextEditingController();
  final OrderService _orderService = OrderService();
  bool _isLoading = false;
  String? _selectedNeighborhoodId;
  int? _selectedWaitingTime;

  static const List<int> _waitingTimeOptions = [5, 10, 15, 20, 25, 30, 60];

  Future<void> _createOrder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final neighborhoodId = int.parse(_selectedNeighborhoodId!);
      final description = _descriptionController.text.trim();
      final notes = _notesController.text.trim();
      final address = _addressController.text.trim();
      final phone = _phoneController.text.trim().isNotEmpty
          ? _phoneController.text.trim()
          : 'غير محدد';
      final priceText = _priceController.text.trim();
      final price = priceText.isNotEmpty ? double.tryParse(priceText) : null;

      final response = await _orderService.createOrderByVendor(
        description: description,
        additionalNotes: notes.isNotEmpty ? notes : null,
        userAddress: address,
        phoneNumber: phone,
        neighborhoodId: neighborhoodId,
        price: price,
        waitingTime: _selectedWaitingTime,
      );

      if (response.success && response.data != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم إنشاء الطلب بنجاح'),
              backgroundColor: Colors.green,
            ),
          );

          Navigator.pop(context, response.data);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.error ?? 'فشل في إنشاء الطلب'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'إنشاء طلب جديد',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildInfoCard(context),
              const SizedBox(height: 16),
              _buildCustomerInfoCard(context),
              const SizedBox(height: 16),
              _buildOrderDetailsCard(context),
              const SizedBox(height: 24),
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isDark ? Colors.blue.withOpacity(0.15) : Colors.blue[50],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              Icons.add_business,
              size: 48,
              color: isDark ? Colors.blue[200] : Colors.blue[700],
            ),
            const SizedBox(height: 12),
            Text(
              'إنشاء طلب للعميل',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.blue[200] : Colors.blue[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'قم بإنشاء طلب نيابة عن العميل وإرساله إليه',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.blue[100] : Colors.blue[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerInfoCard(BuildContext context) {
    final labelColor = Theme.of(context).textTheme.bodySmall?.color;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person, color: Colors.blue[700], size: 24),
                const SizedBox(width: 12),
                const Text(
                  'معلومات العميل',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Phone field
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              textDirection: TextDirection.ltr,
              decoration: InputDecoration(
                labelText: 'رقم الهاتف (اختياري)',
                labelStyle: TextStyle(color: labelColor),
                hintText: '+201234567890',
                hintTextDirection: TextDirection.ltr,
                prefixIcon: Icon(Icons.phone, color: Colors.green[700]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.green[700]!, width: 2),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Address field
            TextFormField(
              controller: _addressController,
              maxLines: 2,
              textDirection: TextDirection.rtl,
              decoration: InputDecoration(
                labelText: 'عنوان التوصيل (اختياري)',
                labelStyle: TextStyle(color: labelColor),
                hintText: 'اكتب العنوان الكامل للتوصيل...',
                hintTextDirection: TextDirection.rtl,
                prefixIcon: Icon(Icons.location_on, color: Colors.red[700]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.red[700]!, width: 2),
                ),
                alignLabelWithHint: true,
              ),
            ),

            const SizedBox(height: 16),

            // Neighborhood dropdown
            NeighborhoodDropdown(
              selectedNeighborhoodId: _selectedNeighborhoodId,
              onChanged: (value) {
                setState(() {
                  _selectedNeighborhoodId = value;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'يرجى اختيار المنطقة';
                }
                return null;
              },
              labelText: 'المنطقة',
              prefixIcon: Icon(Icons.location_city, color: Colors.purple[700]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderDetailsCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final labelColor = Theme.of(context).textTheme.bodySmall?.color;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.receipt_long, color: Colors.orange[700], size: 24),
                const SizedBox(width: 12),
                const Text(
                  'تفاصيل الطلب',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Price field
            TextFormField(
              controller: _priceController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              decoration: InputDecoration(
                labelText: 'السعر (ج.م) - اختياري',
                labelStyle: TextStyle(color: labelColor),
                hintText: 'أدخل السعر الإجمالي للطلب...',
                hintTextDirection: TextDirection.rtl,
                prefixIcon: Icon(Icons.attach_money, color: Colors.green[700]),
                suffixText: 'ج.م',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.green[700]!, width: 2),
                ),
              ),
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final price = double.tryParse(value);
                  if (price == null || price < 0) {
                    return 'يرجى إدخال سعر صحيح';
                  }
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Waiting time field
            DropdownButtonFormField<int>(
              initialValue: _selectedWaitingTime,
              decoration: InputDecoration(
                labelText: 'الوقت التقديري للتوصيل (اختياري)',
                labelStyle: TextStyle(color: labelColor),
                hintText: 'اختر الوقت التقديري',
                prefixIcon: Icon(Icons.timer_outlined, color: Colors.blue[700]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.blue[700]!, width: 2),
                ),
              ),
              items: _waitingTimeOptions
                  .map(
                    (minutes) => DropdownMenuItem(
                      value: minutes,
                      child: Text('$minutes دقيقة'),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _selectedWaitingTime = v),
            ),

            const SizedBox(height: 16),

            // Description field
            // TextFormField(
            //   controller: _descriptionController,
            //   maxLines: 4,
            //   decoration: InputDecoration(
            //     labelText: 'وصف الطلب',
            //     labelStyle: const TextStyle(color: Colors.grey),
            //     hintText: 'اكتب تفاصيل الطلب المطلوب...',
            //     hintTextDirection: TextDirection.rtl,
            //     prefixIcon: Icon(Icons.description, color: Colors.orange[700]),
            //     border: OutlineInputBorder(
            //       borderRadius: BorderRadius.circular(12),
            //     ),
            //     focusedBorder: OutlineInputBorder(
            //       borderRadius: BorderRadius.circular(12),
            //       borderSide: BorderSide(color: Colors.orange[700]!, width: 2),
            //     ),
            //     alignLabelWithHint: true,
            //   ),
            //   validator: (value) {
            //     if (value == null || value.trim().isEmpty) {
            //       return 'يرجى إدخال وصف الطلب';
            //     }
            //     return null;
            //   },
            // ),

            // const SizedBox(height: 16),

            // Notes field
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'ملاحظات إضافية (اختياري)',
                labelStyle: TextStyle(color: labelColor),
                hintText: 'أي ملاحظات أو تفاصيل إضافية...',
                hintTextDirection: TextDirection.rtl,
                prefixIcon: Icon(Icons.note, color: Colors.teal[700]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.teal[700]!, width: 2),
                ),
                alignLabelWithHint: true,
              ),
            ),

            const SizedBox(height: 16),

            // Info boxes
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? Colors.blue.withOpacity(0.15) : Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDark
                      ? Colors.blue.withOpacity(0.4)
                      : Colors.blue[200]!,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info,
                    color: isDark ? Colors.blue[200] : Colors.blue[700],
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'سيتم إرسال الطلب للعميل المحدد بحالة "في الانتظار".',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.blue[200] : Colors.blue[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.orange.withOpacity(0.15)
                    : Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDark
                      ? Colors.orange.withOpacity(0.4)
                      : Colors.orange[200]!,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning,
                    color: isDark ? Colors.orange[200] : Colors.orange[700],
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'تأكد من صحة المعلومات قبل الإرسال.',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.orange[200] : Colors.orange[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final outlineColor = Theme.of(context).dividerColor;
    final outlineTextColor = Theme.of(context).textTheme.bodyMedium?.color;
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _createOrder,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[700],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.send, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'إرسال الطلب',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton(
            onPressed: _isLoading ? null : () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: outlineTextColor,
              side: BorderSide(color: outlineColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'إلغاء',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _notesController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _priceController.dispose();
    super.dispose();
  }
}
