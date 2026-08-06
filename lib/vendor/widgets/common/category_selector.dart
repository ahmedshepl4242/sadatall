import 'package:flutter/material.dart';
import '../../models/category.dart';
import '../../services/category_service.dart';

class CategorySelector extends StatefulWidget {
  final List<String> selectedCategoryIds;
  final Function(List<String>) onChanged;
  final String? Function(List<String>?)? validator;

  const CategorySelector({
    super.key,
    required this.selectedCategoryIds,
    required this.onChanged,
    this.validator,
  });

  @override
  State<CategorySelector> createState() => _CategorySelectorState();
}

class _CategorySelectorState extends State<CategorySelector> {
  final CategoryService _categoryService = CategoryService();
  List<Category> _allCategories = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final response = await _categoryService.getCategories();

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (response.success && response.data != null) {
          _allCategories = response.data!;
        } else {
          _error = response.error ?? 'Failed to load categories';
        }
      });
    }
  }

  void _addCategory(Category category) {
    if (!widget.selectedCategoryIds.contains(category.id)) {
      final updatedList = [...widget.selectedCategoryIds, category.id];
      widget.onChanged(updatedList);
    }
  }

  void _removeCategory(String categoryId) {
    final updatedList = widget.selectedCategoryIds
        .where((id) => id != categoryId)
        .toList();
    widget.onChanged(updatedList);
  }

  List<Category> _getSelectedCategories() {
    return _allCategories
        .where((cat) => widget.selectedCategoryIds.contains(cat.id))
        .toList();
  }

  List<Category> _getAvailableCategories() {
    return _allCategories
        .where((cat) => !widget.selectedCategoryIds.contains(cat.id))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Dropdown
        FormField<List<String>>(
          initialValue: widget.selectedCategoryIds,
          validator: widget.validator,
          builder: (FormFieldState<List<String>> field) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: field.hasError ? Colors.red : Colors.grey[300]!,
                      width: field.hasError ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _isLoading
                      ? const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(
                            child: SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        )
                      : _error != null
                          ? Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  Icon(Icons.error, color: Colors.red[700]),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _error!,
                                      style: TextStyle(color: Colors.red[700]),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.refresh),
                                    onPressed: _loadCategories,
                                  ),
                                ],
                              ),
                            )
                          : DropdownButtonFormField<Category>(
                              key: ValueKey(widget.selectedCategoryIds.join(',')),
                              value: null,
                              decoration: InputDecoration(
                                labelText: 'اختر التصنيفات',
                                labelStyle: const TextStyle(color: Colors.grey),
                                hintText: 'أضف تصنيف...',
                                prefixIcon: Icon(Icons.category,
                                    color: Colors.blue[700]),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                              ),
                              items: _getAvailableCategories()
                                  .map((category) => DropdownMenuItem<Category>(
                                        value: category,
                                        child: Text(category.name),
                                      ))
                                  .toList(),
                              onChanged: _getAvailableCategories().isEmpty
                                  ? null
                                  : (Category? category) {
                                      if (category != null) {
                                        _addCategory(category);
                                      }
                                    },
                              validator: null, // Validation on parent FormField
                            ),
                ),
                if (field.hasError)
                  Padding(
                    padding: const EdgeInsets.only(top: 8, right: 12, left: 12),
                    child: Text(
                      field.errorText!,
                      style: TextStyle(
                        color: Colors.red[700],
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),

        const SizedBox(height: 12),

        // Selected categories chips
        if (widget.selectedCategoryIds.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _getSelectedCategories().map((category) {
              return Chip(
                label: Text(category.name),
                deleteIcon: const Icon(Icons.close, size: 18),
                onDeleted: () => _removeCategory(category.id),
                backgroundColor: Colors.blue[50],
                deleteIconColor: Colors.blue[700],
                labelStyle: TextStyle(
                  color: Colors.blue[700],
                  fontWeight: FontWeight.w500,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: Colors.blue[200]!),
                ),
              );
            }).toList(),
          ),
        ] else ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.grey[600], size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'لم يتم اختيار أي تصنيف بعد',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
