import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../providers/auth_provider.dart';
import '../../models/product_item.dart';
import '../../services/item_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/smart_image.dart';
import 'product_item_details_screen.dart';

class ItemsManagementScreen extends StatefulWidget {
  const ItemsManagementScreen({super.key});

  @override
  State<ItemsManagementScreen> createState() => _ItemsManagementScreenState();
}

class _ItemsManagementScreenState extends State<ItemsManagementScreen> {
  final ItemService _itemService = ItemService();
  final TextEditingController _searchController = TextEditingController();

  final List<ProductItem> _allItems = [];
  List<ProductItem> _filteredItems = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  int _currentPage = 1;
  final int _itemsPerPage = 10;
  bool _hasMoreItems = true;

  @override
  void initState() {
    super.initState();
    _checkVendorLockAndLoadItems();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _checkVendorLockAndLoadItems() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.isVendorLocked) {
        _showVendorLockedDialog();
      } else {
        _loadItems();
      }
    });
  }

  Future<void> _loadItems({bool isRefresh = false}) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.isVendorLocked) {
      _showVendorLockedDialog();
      return;
    }

    if (isRefresh) {
      setState(() {
        _currentPage = 1;
        _allItems.clear();
        _filteredItems.clear();
        _hasMoreItems = true;
        _isLoading = true;
      });
    }

    if (!_hasMoreItems) return;

    setState(() {
      if (isRefresh || _currentPage == 1) {
        _isLoading = true;
      } else {
        _isLoadingMore = true;
      }
    });

    try {
      final response = await _itemService.getItems(
        page: _currentPage,
        limit: _itemsPerPage,
      );

      if (response.success && response.data != null) {
        final newItems = response.data!;

        if (newItems.isEmpty) {
          _hasMoreItems = false;
        } else {
          setState(() {
            _allItems.addAll(newItems);
            _filterItems();
            _currentPage++;
          });
        }
      } else if (response.error != null &&
          response.error!.contains('يرجى الانتظار حتى يتم فتح الحساب')) {
        authProvider.setVendorLockStatus(true);
        _showVendorLockedDialog();
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
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    }
  }

  void _filterItems() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredItems = List.from(_allItems);
      } else {
        _filteredItems = _allItems.where((item) {
          return item.name.toLowerCase().contains(query) ||
              item.description.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  void _showVendorLockedDialog() {
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('الحساب مغلق'),
            content: const Text(
                'حسابك مغلق مؤقتًا، يرجى إغلاق التطبيق وإعادة فتحه بعد فتح الحساب من قبل الإدارة'),
          );
        },
      );
    }
  }

  Future<void> _addItem() async {
    final result = await Navigator.push<ProductItem>(
      context,
      MaterialPageRoute(
        builder: (context) => const ProductItemDetailsScreen(isEditable: true),
      ),
    );

    if (result != null) {
      _loadItems(isRefresh: true);
    }
  }

  Future<void> _editItem(ProductItem item) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductItemDetailsScreen(
          productItem: item,
          isEditable: true,
        ),
      ),
    );

    if (result != null) {
      _loadItems(isRefresh: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _isLoading && _allItems.isEmpty
                ? Center(
                    child: LoadingAnimationWidget.staggeredDotsWave(
                      color: AppTheme.primaryColor,
                      size: 50,
                    ),
                  )
                : _buildItemsList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addItem,
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 16,
        right: 16,
        bottom: 16,
      ),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'إدارة المنتجات',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _searchController,
            onChanged: (_) => _filterItems(),
            decoration: InputDecoration(
              hintText: 'البحث في المنتجات...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsList() {
    if (_filteredItems.isEmpty && !_isLoading) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () => _loadItems(isRefresh: true),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredItems.length + (_hasMoreItems ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _filteredItems.length) {
            if (_isLoadingMore) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: LoadingAnimationWidget.staggeredDotsWave(
                    color: AppTheme.primaryColor,
                    size: 30,
                  ),
                ),
              );
            } else {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: _loadItems,
                  child: const Text('تحميل المزيد'),
                ),
              );
            }
          }

          final item = _filteredItems[index];

          // Load more items when reaching the end
          if (index == _filteredItems.length - 1 &&
              _hasMoreItems &&
              !_isLoadingMore) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _loadItems();
            });
          }

          return _buildItemCard(item);
        },
      ),
    );
  }

  Widget _buildItemCard(ProductItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _editItem(item),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Item image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: item.imageUrl != null
                    ? SmartImage(
                        imageSource: item.imageUrl!,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[300],
                        child: Icon(
                          Icons.shopping_bag,
                          size: 40,
                          color: Colors.grey[500],
                        ),
                      ),
              ),
              const SizedBox(width: 12),

              // Item details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '${item.price.toStringAsFixed(0)} جنيه',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: item.isAvailable
                                ? Colors.green[100]
                                : Colors.red[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            item.isAvailable ? 'متاح' : 'غير متاح',
                            style: TextStyle(
                              fontSize: 12,
                              color: item.isAvailable
                                  ? Colors.green[800]
                                  : Colors.red[800],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_bag,
            size: 100,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد منتجات',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'اضغط على زر "+" لإضافة منتج جديد',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}
