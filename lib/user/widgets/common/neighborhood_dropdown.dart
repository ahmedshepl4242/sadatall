import 'package:flutter/material.dart';
import '../../services/neighborhood_service.dart';
import '../../models/auth_models.dart';

class NeighborhoodDropdown extends StatefulWidget {
  final String? selectedNeighborhoodId;
  final Function(String?) onChanged;
  final String? Function(String?)? validator;
  final String labelText;
  final Widget? prefixIcon;

  const NeighborhoodDropdown({
    super.key,
    this.selectedNeighborhoodId,
    required this.onChanged,
    this.validator,
    this.labelText = 'المنطقة',
    this.prefixIcon,
  });

  @override
  State<NeighborhoodDropdown> createState() => _NeighborhoodDropdownState();
}

class _NeighborhoodDropdownState extends State<NeighborhoodDropdown> {
  final NeighborhoodService _neighborhoodService = NeighborhoodService();
  List<Neighborhood> _neighborhoods = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadNeighborhoods();
  }

  Future<void> _loadNeighborhoods() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _neighborhoodService.getNeighborhoods();
      if (response.success && response.data != null) {
        setState(() {
          _neighborhoods = response.data!;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response.error ?? 'فشل في تحميل الأحياء';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'حدث خطأ: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: widget.labelText,
          labelStyle: const TextStyle(color: Colors.grey),
          prefixIcon: widget.prefixIcon ??
              Icon(Icons.location_city, color: Colors.purple[700]),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.purple[700]!, width: 2),
          ),
        ),
        items: const [],
        onChanged: null,
        hint: const Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 8),
            Text('جاري التحميل...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: widget.labelText,
              labelStyle: const TextStyle(color: Colors.grey),
              prefixIcon: widget.prefixIcon ??
                  Icon(Icons.location_city, color: Colors.purple[700]),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.purple[700]!, width: 2),
              ),
            ),
            items: const [],
            onChanged: null,
            hint: Text(
              'خطأ في التحميل',
              style: TextStyle(color: Colors.red[600]),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.error, color: Colors.red[600], size: 16),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  _error!,
                  style: TextStyle(
                    color: Colors.red[600],
                    fontSize: 12,
                  ),
                ),
              ),
              TextButton(
                onPressed: _loadNeighborhoods,
                child: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ],
      );
    }

    return DropdownButtonFormField<String>(
      value: widget.selectedNeighborhoodId,
      decoration: InputDecoration(
        labelText: widget.labelText,
        labelStyle: const TextStyle(color: Colors.grey),
        prefixIcon: widget.prefixIcon ??
            Icon(Icons.location_city, color: Colors.purple[700]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.purple[700]!, width: 2),
        ),
      ),
      hint: const Text('اختر المنطقة'),
      items: _neighborhoods.map((neighborhood) {
        return DropdownMenuItem<String>(
          value: neighborhood.id.toString(),
          child: Text(
            neighborhood.name,
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: widget.onChanged,
      validator: widget.validator,
      isExpanded: true,
    );
  }
}