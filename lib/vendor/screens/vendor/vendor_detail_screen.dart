import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../providers/auth_provider.dart';
import '../../models/menu_item.dart';
import '../../models/product_item.dart';
import '../../services/menu_service.dart';
import '../../services/item_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/smart_image.dart';
import '../menu/add_edit_menu_screen.dart';
import '../items/product_item_details_screen.dart';

class VendorDetailScreen extends StatefulWidget {
  const VendorDetailScreen({super.key});

  @override
  State<VendorDetailScreen> createState() => _VendorDetailScreenState();
}

class _VendorDetailScreenState extends State<VendorDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final MenuService _menuService = MenuService();
  final ItemService _itemService = ItemService();

  final List<MenuItem> _allMenuItems = [];
  final List<ProductItem> _allProductItems = [];

  bool _isLoadingMenus = true;
  bool _isLoadingItems = true;
  bool _isLoadingMoreMenus = false;
  bool _isLoadingMoreItems = false;

  int _currentMenuPage = 1;
  int _currentItemPage = 1;
  final int _itemsPerPage = 10;
  bool _hasMoreMenus = true;
  bool _hasMoreItems = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _checkVendorLockAndLoadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _checkVendorLockAndLoadData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.isVendorLocked) {
        _showVendorLockedDialog();
      } else {
        _loadMenuItems();
        _loadProductItems();
      }
    });
  }

  Future<void> _loadMenuItems({bool isRefresh = false}) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.isVendorLocked) {
      _showVendorLockedDialog();
      return;
    }

    if (isRefresh) {
      setState(() {
        _currentMenuPage = 1;
        _allMenuItems.clear();
        _hasMoreMenus = true;
        _isLoadingMenus = true;
      });
    }

    if (!_hasMoreMenus) return;

    setState(() {
      if (isRefresh || _currentMenuPage == 1) {
        _isLoadingMenus = true;
      } else {
        _isLoadingMoreMenus = true;
      }
    });

    try {
      final response = await _menuService.getMenus(
        page: _currentMenuPage,
        limit: _itemsPerPage,
      );

      if (response.success && response.data != null) {
        final newItems = response.data!;

        if (newItems.isEmpty) {
          _hasMoreMenus = false;
        } else {
          setState(() {
            _allMenuItems.addAll(newItems);
            _currentMenuPage++;
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
          _isLoadingMenus = false;
          _isLoadingMoreMenus = false;
        });
      }
    }
  }

  Future<void> _loadProductItems({bool isRefresh = false}) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.isVendorLocked) {
      _showVendorLockedDialog();
      return;
    }

    if (isRefresh) {
      setState(() {
        _currentItemPage = 1;
        _allProductItems.clear();
        _hasMoreItems = true;
        _isLoadingItems = true;
      });
    }

    if (!_hasMoreItems) return;

    setState(() {
      if (isRefresh || _currentItemPage == 1) {
        _isLoadingItems = true;
      } else {
        _isLoadingMoreItems = true;
      }
    });

    try {
      final response = await _itemService.getItems(
        page: _currentItemPage,
        limit: _itemsPerPage,
      );

      if (response.success && response.data != null) {
        final newItems = response.data!;

        if (newItems.isEmpty) {
          _hasMoreItems = false;
        } else {
          setState(() {
            _allProductItems.addAll(newItems);
            _currentItemPage++;
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
          _isLoadingItems = false;
          _isLoadingMoreItems = false;
        });
      }
    }
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
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('موافق'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _addMenu() async {
    final result = await Navigator.push<MenuItem>(
      context,
      MaterialPageRoute(
        builder: (context) => const AddEditMenuScreen(),
      ),
    );

    if (result != null) {
      _loadMenuItems(isRefresh: true);
    }
  }

  Future<void> _addItem() async {
    final result = await Navigator.push<ProductItem>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const ProductItemDetailsScreen(isEditable: true),
      ),
    );

    if (result != null) {
      _loadProductItems(isRefresh: true);
    }
  }

  Future<void> _editMenu(MenuItem menu) async {
    final result = await Navigator.push<MenuItem>(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditMenuScreen(menuItem: menu),
      ),
    );

    if (result != null) {
      _loadMenuItems(isRefresh: true);
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
      _loadProductItems(isRefresh: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final vendor = authProvider.vendor;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'إدارة المطعم',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'القوائم', icon: Icon(Icons.restaurant_menu)),
            Tab(text: 'المنتجات', icon: Icon(Icons.shopping_bag)),
          ],
        ),
      ),
      body: Column(
        children: [
          // Vendor info header
          Container(
            color: AppTheme.primaryColor,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  backgroundImage: vendor?.imageUrl != null
                      ? NetworkImage(vendor!.imageUrl!)
                      : null,
                  child: vendor?.imageUrl == null
                      ? const Icon(Icons.store, size: 30, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vendor?.vendorName ?? 'اسم المطعم',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        vendor?.address ?? 'العنوان',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMenusTab(),
                _buildItemsTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (_tabController.index == 0) {
            _addMenu();
          } else {
            _addItem();
          }
        },
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          _tabController.index == 0 ? 'إضافة قائمة' : 'إضافة منتج',
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildMenusTab() {
    if (_isLoadingMenus && _allMenuItems.isEmpty) {
      return Center(
        child: LoadingAnimationWidget.staggeredDotsWave(
          color: AppTheme.primaryColor,
          size: 50,
        ),
      );
    }

    if (_allMenuItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant_menu,
              size: 100,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد قوائم',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'اضغط على زر "+" لإضافة قائمة جديدة',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadMenuItems(isRefresh: true),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _allMenuItems.length + (_hasMoreMenus ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _allMenuItems.length) {
            if (_isLoadingMoreMenus) {
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
                  onPressed: _loadMenuItems,
                  child: const Text('تحميل المزيد'),
                ),
              );
            }
          }

          final menu = _allMenuItems[index];
          return _buildMenuCard(menu);
        },
      ),
    );
  }

  Widget _buildItemsTab() {
    if (_isLoadingItems && _allProductItems.isEmpty) {
      return Center(
        child: LoadingAnimationWidget.staggeredDotsWave(
          color: AppTheme.primaryColor,
          size: 50,
        ),
      );
    }

    if (_allProductItems.isEmpty) {
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

    return RefreshIndicator(
      onRefresh: () => _loadProductItems(isRefresh: true),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _allProductItems.length + (_hasMoreItems ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _allProductItems.length) {
            if (_isLoadingMoreItems) {
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
                  onPressed: _loadProductItems,
                  child: const Text('تحميل المزيد'),
                ),
              );
            }
          }

          final item = _allProductItems[index];
          return _buildItemCard(item);
        },
      ),
    );
  }

  Widget _buildMenuCard(MenuItem menu) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _editMenu(menu),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Menu image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: menu.photoUrl != null
                    ? SmartImage(
                        imageSource: menu.photoUrl!,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[300],
                        child: Icon(
                          Icons.restaurant_menu,
                          size: 40,
                          color: Colors.grey[500],
                        ),
                      ),
              ),
              const SizedBox(width: 12),

              // Menu details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'قائمة #${menu.id}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'رقم البائع: ${menu.vendorId}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
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
}
