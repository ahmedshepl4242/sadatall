import 'package:flutter/material.dart';
import 'dart:async';
import '../../models/vendor.dart';
import '../../models/category.dart';
import '../../services/user_vendor_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/skeleton_widget.dart';
import '../../widgets/common/smart_image.dart';
import 'vendor_details_screen.dart';
import '../orders/create_order_screen.dart';

class VendorsListScreen extends StatefulWidget {
  const VendorsListScreen({super.key});

  @override
  State<VendorsListScreen> createState() => _VendorsListScreenState();
}

class _VendorsListScreenState extends State<VendorsListScreen> {
  final UserVendorService _vendorService = UserVendorService();
  final TextEditingController _searchController = TextEditingController();

  List<Vendor> _vendors = [];
  List<Category> _categories = [];
  String? _selectedCategoryId;
  bool _isLoading = true;
  bool _isLoadingCategories = true;
  String? _error;
  bool _isLoadingMore = false;
  int _currentPage = 1;
  bool _hasMoreData = true;
  bool _isSearching = false;
  String _currentSearchQuery = '';
  Timer? _debounceTimer;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadVendors();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _hasMoreData) {
      if (_isSearching) {
        _loadMoreSearchResults();
      } else {
        _loadMoreVendors();
      }
    }
  }

  void _onSearchChanged() {
    // Cancel the previous timer if it exists
    _debounceTimer?.cancel();
    
    // Start a new timer
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      final query = _searchController.text.trim();
      
      if (query.isEmpty) {
        // If search query is empty, load all vendors
        setState(() {
          _isSearching = false;
          _currentSearchQuery = '';
        });
        _loadVendors();
      } else {
        // If there's a search query, perform search
        setState(() {
          _isSearching = true;
          _currentSearchQuery = query;
          _currentPage = 1;
        });
        _performSearch(query);
      }
    });
  }

  Future<void> _loadCategories() async {
    print('🟢 [VendorsListScreen] Loading categories...');
    setState(() {
      _isLoadingCategories = true;
    });

    try {
      final response = await _vendorService.getCategories();

      print('🟢 [VendorsListScreen] Categories response success: ${response.success}');
      print('🟢 [VendorsListScreen] Categories data: ${response.data}');

      if (response.success && response.data != null) {
        print('🟢 [VendorsListScreen] Categories count: ${response.data!.length}');
        for (var category in response.data!) {
          print('🟢 [VendorsListScreen] Category received: id=${category.id}, name=${category.name}');
        }

        setState(() {
          _categories = response.data!;
          _isLoadingCategories = false;
        });

        print('🟢 [VendorsListScreen] State updated with ${_categories.length} categories');
      } else {
        print('🔴 [VendorsListScreen] Categories load failed: ${response.error}');
        setState(() {
          _isLoadingCategories = false;
        });
      }
    } catch (e) {
      print('🔴 [VendorsListScreen] Exception loading categories: $e');
      setState(() {
        _isLoadingCategories = false;
      });
    }
  }

  Future<void> _performSearch(String query) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _vendorService.searchVendors(
        query: query,
        page: 1,
        limit: 10,
        categoryId: _selectedCategoryId,
      );

      if (response.success && response.data != null) {
        setState(() {
          _vendors = response.data!;
          _isLoading = false;
          _hasMoreData = response.data!.length >= 10;
        });
      } else {
        setState(() {
          _error = response.error ?? 'فشل في البحث عن المتاجر';
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

  Future<void> _loadMoreSearchResults() async {
    if (_isLoadingMore || !_hasMoreData || !_isSearching) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final response = await _vendorService.searchVendors(
        query: _currentSearchQuery,
        page: _currentPage + 1,
        limit: 10,
        categoryId: _selectedCategoryId,
      );

      if (response.success && response.data != null) {
        setState(() {
          _vendors.addAll(response.data!);
          _currentPage++;
          _hasMoreData = response.data!.length >= 10;
          _isLoadingMore = false;
        });
      } else {
        setState(() {
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _loadVendors() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _vendorService.getVendors(
        page: 1,
        limit: 10,
        categoryId: _selectedCategoryId,
        // Removed isOpen filter to show all vendors (both open and closed)
      );

      if (response.success && response.data != null) {
        setState(() {
          _vendors = response.data!;
          _isLoading = false;
          _currentPage = 1;
          _hasMoreData = response.data!.length >= 10;
        });
      } else {
        setState(() {
          _error = response.error ?? 'فشل في تحميل المتاجر';
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

  Future<void> _loadMoreVendors() async {
    if (_isLoadingMore || !_hasMoreData) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final response = await _vendorService.getVendors(
        page: _currentPage + 1,
        limit: 10,
        categoryId: _selectedCategoryId,
        // Removed isOpen filter to show all vendors (both open and closed)
      );

      if (response.success && response.data != null) {
        setState(() {
          _vendors.addAll(response.data!);
          _currentPage++;
          _hasMoreData = response.data!.length >= 10;
          _isLoadingMore = false;
        });
      } else {
        setState(() {
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _refreshVendors() async {
    if (_isSearching && _currentSearchQuery.isNotEmpty) {
      await _performSearch(_currentSearchQuery);
    } else {
      await _loadVendors();
    }
  }

  void _navigateToVendorDetails(Vendor vendor) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VendorDetailsScreen(vendor: vendor),
      ),
    );
  }

  void _navigateToCustomOrder() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateOrderScreen(
          isCustomOrder: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المتاجر'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'ابحث عن متجر...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.9),
                  ),
                ),
              ),
              // Category dropdown
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: DropdownButtonHideUnderline(
                    child: Builder(
                      builder: (context) {
                        print('🟡 [VendorsListScreen] Building dropdown with ${_categories.length} categories');
                        print('🟡 [VendorsListScreen] Selected category ID: $_selectedCategoryId');

                        return DropdownButton<String>(
                          value: _selectedCategoryId,
                          hint: const Text('جميع الفئات'),
                          isExpanded: true,
                          icon: const Icon(Icons.arrow_drop_down),
                          items: [
                            const DropdownMenuItem<String>(
                              value: null,
                              child: Text('جميع الفئات'),
                            ),
                            ..._categories.map((category) {
                              print('🟡 [VendorsListScreen] Creating dropdown item: id=${category.id}, name=${category.name}');
                              return DropdownMenuItem<String>(
                                value: category.id,
                                child: Text(category.name),
                              );
                            }).toList(),
                          ],
                          onChanged: (String? newValue) {
                            print('🟡 [VendorsListScreen] Category selected: $newValue');
                            setState(() {
                              _selectedCategoryId = newValue;
                              _currentPage = 1;
                            });
                            // Reload vendors with new category filter
                            if (_isSearching && _currentSearchQuery.isNotEmpty) {
                              _performSearch(_currentSearchQuery);
                            } else {
                              _loadVendors();
                            }
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'vendors_custom_order_fab',
        onPressed: _navigateToCustomOrder,
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_business),
        label: const Text('طلب مخصص'),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshVendors,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_error != null) {
      return _buildErrorState();
    }

    if (_vendors.isEmpty) {
      return _buildEmptyState();
    }

    return _buildVendorsList();
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      itemBuilder: (context, index) => _buildVendorCardSkeleton(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppTheme.errorColor,
          ),
          const SizedBox(height: 16),
          Text(
            _error!,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _isSearching && _currentSearchQuery.isNotEmpty
                ? () => _performSearch(_currentSearchQuery)
                : _loadVendors,
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.store_outlined,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'لا توجد متاجر متاحة حالياً',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildVendorsList() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _vendors.length + (_isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= _vendors.length) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final vendor = _vendors[index];
              return _buildVendorCard(vendor);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildVendorCard(Vendor vendor) {
    final isOpen = vendor.isOpen.toLowerCase() == 'true';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      color: const Color(0xFFFFCC80), // Light orange (Orange 100)
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: isOpen ? () => _navigateToVendorDetails(vendor) : null,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Vendor Image
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                color: Colors.grey[200],
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: vendor.imageUrl != null
                    ? SmartImage(
                        imageSource: vendor.imageUrl!,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        color: Colors.grey[300],
                        child: Icon(
                          Icons.store,
                          size: 48,
                          color: Colors.grey[500],
                        ),
                      ),
              ),
            ),

            // Vendor Info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          vendor.vendorName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Status Indicator
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isOpen
                              ? AppTheme.successColor.withOpacity(0.8) // Lighter green background
                              : Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          isOpen ? 'مفتوح' : 'مغلق',
                          style: TextStyle(
                            color: isOpen ? Colors.white : Colors.grey, // White text for better contrast
                            fontSize: 12,
                            fontWeight: FontWeight.normal, // Thinner font
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Categories tags
                  if (vendor.categories.isNotEmpty) ...[
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: vendor.categories.map((category) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.successColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppTheme.successColor.withOpacity(0.5),
                            ),
                          ),
                          child: Text(
                            category.name,
                            style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.successColor.withOpacity(0.9),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (vendor.description.isNotEmpty) ...[
                    Text(
                      vendor.description,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                  ],
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          vendor.address,
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
    );
  }

  Widget _buildVendorCardSkeleton() {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonWidget(
            height: 180,
            width: double.infinity,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(12),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SkeletonWidget(height: 20, width: 150),
                const SizedBox(height: 8),
                const SkeletonWidget(height: 14, width: double.infinity),
                const SizedBox(height: 4),
                const SkeletonWidget(height: 14, width: 200),
                const SizedBox(height: 8),
                const SkeletonWidget(height: 12, width: 120),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
