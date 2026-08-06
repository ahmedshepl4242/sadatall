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

  Neighborhood? get _selected {
    if (widget.selectedNeighborhoodId == null) return null;
    for (final n in _neighborhoods) {
      if (n.id == widget.selectedNeighborhoodId) return n;
    }
    return null;
  }

  Future<void> _openPicker() async {
    final result = await showModalBottomSheet<Neighborhood>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _NeighborhoodSearchSheet(neighborhoods: _neighborhoods),
    );
    if (result != null) {
      widget.onChanged(result.id);
    }
  }

  InputDecoration _decoration({String? hintText}) {
    return InputDecoration(
      labelText: widget.labelText,
      labelStyle: const TextStyle(color: Colors.grey),
      prefixIcon:
          widget.prefixIcon ?? Icon(Icons.location_city, color: Colors.purple[700]),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.purple[700]!, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red[600]!),
      ),
      hintText: hintText,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return InputDecorator(
        decoration: _decoration(),
        child: const Row(
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
          InputDecorator(
            decoration: _decoration(),
            child: Text(
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
                  style: TextStyle(color: Colors.red[600], fontSize: 12),
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

    return FormField<String>(
      initialValue: widget.selectedNeighborhoodId,
      validator: widget.validator,
      builder: (field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () async {
                await _openPicker();
                field.didChange(widget.selectedNeighborhoodId);
              },
              borderRadius: BorderRadius.circular(12),
              child: InputDecorator(
                decoration: _decoration().copyWith(
                  errorText: field.errorText,
                  suffixIcon: const Icon(Icons.arrow_drop_down),
                ),
                child: Text(
                  _selected?.name ?? 'اختر المنطقة',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _selected != null ? null : Colors.grey[600],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _NeighborhoodSearchSheet extends StatefulWidget {
  final List<Neighborhood> neighborhoods;

  const _NeighborhoodSearchSheet({required this.neighborhoods});

  @override
  State<_NeighborhoodSearchSheet> createState() =>
      _NeighborhoodSearchSheetState();
}

class _NeighborhoodSearchSheetState extends State<_NeighborhoodSearchSheet> {
  final _searchController = TextEditingController();
  late List<Neighborhood> _filtered;

  @override
  void initState() {
    super.initState();
    _filtered = widget.neighborhoods;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    setState(() {
      _filtered = widget.neighborhoods
          .where((n) => n.name.toLowerCase().contains(query.trim().toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'اختر المنطقة',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'ابحث عن حي...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _onSearch('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: _onSearch,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _filtered.isEmpty
                  ? const Center(child: Text('لا توجد نتائج'))
                  : ListView.separated(
                      itemCount: _filtered.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (_, i) {
                        final neighborhood = _filtered[i];
                        return ListTile(
                          leading: const Icon(Icons.location_city),
                          title: Text(neighborhood.name),
                          onTap: () => Navigator.of(context).pop(neighborhood),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
