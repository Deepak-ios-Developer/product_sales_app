import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:product_sale_app/core/common_widgets/app_loader.dart';
import 'package:product_sale_app/core/common_widgets/flitter_widget.dart';
import 'package:product_sale_app/core/storage/storage.dart';
import 'package:product_sale_app/core/themes/app_fonts.dart';
import 'package:product_sale_app/core/themes/app_theme.dart';
import 'package:product_sale_app/core/view/profile_screen.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../common_widgets/product_card_widget.dart';
import '../constants/common_strings.dart';
import '../model/product_model.dart';
import '../service/product_service.dart';
import '../themes/theme_provider.dart';

class ProductListingScreen extends StatefulWidget {
  const ProductListingScreen({super.key});

  @override
  State<ProductListingScreen> createState() => _ProductListingScreenState();
}

class _ProductListingScreenState extends State<ProductListingScreen>
    with SingleTickerProviderStateMixin {
  List<Product> products = [];
  List<Product> filteredProducts = [];
  List<Brand> brands = [];
  List<Brand> filteredBrands = [];
  List<AttributeFilter> attributes = [];
  Timer? _debounce;
  final int _debounceDuration = 800;

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _brandSearchController = TextEditingController();

  bool _showTopButton = false;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;

  int _currentPage = 1;
  final int _pageSize = 20;
  int _totalProducts = 0;
  int _totalPages = 0;

  String _sortBy = 'relevance';
  String _sortOrder = 'desc';
  double _minRating = 0;
  Set<String> _selectedBrandIds = {};
  Set<String> _selectedBrandNames = {};

  late TabController _tabController;

  Set<String> _selectedSkinTypes = {};
  Set<String> _selectedSkinConcerns = {};
  Set<String> _selectedProductTypes = {};
  bool _inStock = false;
  int? _minPrice;
  int? _maxPrice;
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
    _scrollController.addListener(_scrollListener);
    _tabController = TabController(length: 2, vsync: this);
  }

  Future<void> _fetchProducts({bool loadMore = false}) async {
    if (loadMore && !_hasMoreData) return;
    if (loadMore && _isLoadingMore) return;

    setState(() {
      if (loadMore) {
        _isLoadingMore = true;
      } else {
        _isLoading = true;
        _currentPage = 1;
        products.clear();
      }
    });

    try {
      final response = await ProductService.fetchProducts(
        query: _searchController.text.isEmpty ? null : _searchController.text,
        page: _currentPage,
        limit: _pageSize,
        sortBy: _getSortByValue(_sortBy),
        sortOrder: _sortOrder,
        brandId: _selectedBrandIds.isNotEmpty ? _selectedBrandIds.first : null,
        categoryId: _selectedCategoryId,
        skinType:
            _selectedSkinTypes.isNotEmpty ? _selectedSkinTypes.first : null,
        skinConcern: _selectedSkinConcerns.isNotEmpty
            ? _selectedSkinConcerns.first
            : null,
        productType: _selectedProductTypes.isNotEmpty
            ? _selectedProductTypes.first
            : null,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
        minRating: _minRating > 0 ? _minRating : null,
        inStock: _inStock,
      );

      setState(() {
        if (loadMore) {
          products.addAll(response.data?.products ?? []);
        } else {
          products = response.data?.products ?? [];
        }

        _totalProducts = response.meta?.total ?? 0;
        _totalPages = response.meta?.lastPage ?? 0;
        _hasMoreData = ProductService.hasNextPage(response);

        brands = response.data?.brands ?? [];
        attributes = response.data?.attributes ?? [];
        filteredBrands = List.from(brands);

        filteredProducts = List.from(products);
        _isLoading = false;
        _isLoadingMore = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load products: ${error.toString()}'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _loadMoreProducts() {
    if (!_hasMoreData || _isLoadingMore) return;
    _currentPage++;
    _fetchProducts(loadMore: true);
  }

  void _scrollListener() {
    if (_scrollController.offset >= 400) {
      if (!_showTopButton) setState(() => _showTopButton = true);
    } else {
      if (_showTopButton) setState(() => _showTopButton = false);
    }

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreProducts();
    }
  }

  String? _getSortByValue(String sortBy) {
    switch (sortBy) {
      case 'price':
        return SortOptions.priceAsc;
      case 'rating':
        return SortOptions.ratingDesc;
      case 'newest':
        return SortOptions.newest;
      case 'popular':
        return SortOptions.popular;
      case 'name':
        return SortOptions.nameAsc;
      default:
        return null;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _brandSearchController.dispose();
    _tabController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  int _getAppliedFiltersCount() {
    int count = 0;
    if (_selectedBrandIds.isNotEmpty) count++;
    if (_minRating > 0) count++;
    if (_minPrice != null || _maxPrice != null) count++;
    if (_selectedSkinTypes.isNotEmpty) count++;
    if (_selectedSkinConcerns.isNotEmpty) count++;
    if (_selectedProductTypes.isNotEmpty) count++;
    if (_inStock) count++;
    if (_selectedCategoryId != null) count++;
    return count;
  }

  Future<void> _openFiltersScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FiltersScreen(
          selectedBrandIds: _selectedBrandIds,
          selectedBrandNames: _selectedBrandNames,
          minRating: _minRating,
          minPrice: _minPrice,
          maxPrice: _maxPrice,
          selectedSkinTypes: _selectedSkinTypes,
          selectedSkinConcerns: _selectedSkinConcerns,
          selectedProductTypes: _selectedProductTypes,
          inStock: _inStock,
          availableBrands: brands,
          availableAttributes: attributes,
        ),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _selectedBrandIds = result['brandIds'] ?? {};
        _selectedBrandNames = result['brandNames'] ?? {};
        _minRating = result['rating'] ?? 0.0;
        _minPrice = result['minPrice'];
        _maxPrice = result['maxPrice'];
        _selectedSkinTypes = result['skinTypes'] ?? {};
        _selectedSkinConcerns = result['skinConcerns'] ?? {};
        _selectedProductTypes = result['productTypes'] ?? {};
        _inStock = result['inStock'] ?? false;
      });
      _fetchProducts(loadMore: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.grey.shade900 : Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 6,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: TabBar(
            controller: _tabController,
            tabs: [
              Tab(icon: const Icon(Icons.home), text: AppStrings.home),
              Tab(
                  icon: const Icon(Icons.account_circle),
                  text: AppStrings.profile),
            ],
            indicator: const BoxDecoration(),
            labelColor: AppTheme.secondaryColor,
            unselectedLabelColor: isDark ? Colors.white70 : Colors.black54,
            labelStyle: TextStyle(fontSize: AppFontSize.small.value),
            unselectedLabelStyle: TextStyle(fontSize: AppFontSize.small.value),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildHomeTab(),
            _buildProfileTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeTab() {
    return Stack(
      children: [
        Column(
          children: [
            _buildTopBar(),
            _buildSearchBar(),
            _buildFilterBar(),
            _buildResultsHeader(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => _fetchProducts(loadMore: false),
                child: _isLoading
                    ? _buildShimmerEffect()
                    : filteredProducts.isEmpty
                        ? _buildEmptyState()
                        : _buildProductGrid(),
              ),
            ),
          ],
        ),
        if (_showTopButton) _buildScrollToTopButton(),
      ],
    );
  }

  Widget _buildResultsHeader() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: isDark ? Colors.black : Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Showing ${filteredProducts.length} of $_totalProducts products',
            style: TextStyle(
              fontSize: 13.sp,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
          Text(
            'Page $_currentPage of $_totalPages',
            style: TextStyle(
              fontSize: 12.sp,
              color: isDark ? Colors.white60 : Colors.black45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, MediaQuery.of(context).padding.top + 10, 16, 10),
      color: isDark ? Colors.black : Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          FutureBuilder<Map<String, String?>>(
            future: StorageService.getUserData(),
            builder: (context, snapshot) {
              final userName = snapshot.data?['userName'] ?? 'User';
              return Text(
                'Hey! $userName 👋',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(
              isDark ? Icons.wb_sunny : Icons.nightlight_round,
              color: isDark ? Colors.white : Colors.black,
            ),
            onPressed: () {
              Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: isDark ? Colors.black : Colors.white,
      child: Container(
        height: 48.h,
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[850] : Colors.grey[100],
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Icon(Icons.search, color: Colors.grey[600], size: 20),
            ),
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search for skincare, toner, serum...',
                  hintStyle: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14.sp,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
                textInputAction: TextInputAction.search,
                onSubmitted: (value) {
                  _debounce?.cancel();
                  _fetchProducts(loadMore: false);
                },
                onChanged: (value) {
                  setState(() {});

                  if (_debounce?.isActive ?? false) _debounce!.cancel();

                  _debounce =
                      Timer(Duration(milliseconds: _debounceDuration), () {
                    if (value.length >= 2 || value.isEmpty) {
                      _fetchProducts(loadMore: false);
                    }
                  });
                },
              ),
            ),
            if (_searchController.text.isNotEmpty)
              IconButton(
                icon: Icon(Icons.clear, color: Colors.grey[600], size: 20),
                onPressed: () {
                  _searchController.clear();
                  _debounce?.cancel();
                  _fetchProducts(loadMore: false);
                  setState(() {});
                },
              )
            else
              IconButton(
                icon: Icon(Icons.search,
                    color: AppTheme.secondaryColor, size: 20),
                onPressed: () {
                  if (_searchController.text.isNotEmpty) {
                    _debounce?.cancel();
                    _fetchProducts(loadMore: false);
                  }
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filterCount = _getAppliedFiltersCount();

    return Container(
      height: 50.h,
      color: isDark ? Colors.black : Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip(
                    'Filters${filterCount > 0 ? " ($filterCount)" : ""}',
                    Icons.tune,
                    _openFiltersScreen,
                    isActive: filterCount > 0,
                  ),
                  SizedBox(width: 8),
                  _buildSortDropdown(),
                  SizedBox(width: 8),
                  if (_selectedBrandIds.isNotEmpty)
                    _buildActiveFilterChip(
                        'Brands: ${_selectedBrandIds.length}', () {
                      setState(() {
                        _selectedBrandIds.clear();
                        _selectedBrandNames.clear();
                      });
                      _fetchProducts(loadMore: false);
                    }),
                  if (_minRating > 0)
                    _buildActiveFilterChip('${_minRating.toInt()}★ & up', () {
                      setState(() => _minRating = 0);
                      _fetchProducts(loadMore: false);
                    }),
                  if (_minPrice != null || _maxPrice != null)
                    _buildActiveFilterChip('Price', () {
                      setState(() {
                        _minPrice = null;
                        _maxPrice = null;
                      });
                      _fetchProducts(loadMore: false);
                    }),
                  if (_inStock)
                    _buildActiveFilterChip('In Stock', () {
                      setState(() => _inStock = false);
                      _fetchProducts(loadMore: false);
                    }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, IconData icon, VoidCallback onTap,
      {bool isActive = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive
              ? AppTheme.secondaryColor.withOpacity(0.1)
              : (isDark ? Colors.grey[850] : Colors.grey[200]),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? AppTheme.secondaryColor : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 16,
                color: isActive ? AppTheme.secondaryColor : Colors.grey[700]),
            SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                color: isActive
                    ? AppTheme.secondaryColor
                    : (isDark ? Colors.white70 : Colors.black87),
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveFilterChip(String label, VoidCallback onRemove) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      margin: EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: AppTheme.secondaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.secondaryColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              color: AppTheme.secondaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: 4),
          InkWell(
            onTap: onRemove,
            child: Icon(Icons.close, size: 16, color: AppTheme.secondaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildSortDropdown() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return PopupMenuButton<String>(
      initialValue: _sortBy,
      onSelected: (value) {
        setState(() {
          _sortBy = value;
          if (value == 'price') {
            _sortOrder = _sortOrder == 'asc' ? 'desc' : 'asc';
          } else if (value == 'name') {
            _sortOrder = _sortOrder == 'asc' ? 'desc' : 'asc';
          } else {
            _sortOrder = 'desc';
          }
        });
        _fetchProducts(loadMore: false);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[850] : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Sort: ${_getSortLabel(_sortBy)}',
              style: TextStyle(
                fontSize: 13.sp,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
            SizedBox(width: 4),
            Icon(Icons.arrow_drop_down, size: 18, color: Colors.grey[700]),
          ],
        ),
      ),
      itemBuilder: (context) => [
        PopupMenuItem(value: 'relevance', child: Text('Relevance')),
        PopupMenuItem(
            value: 'price',
            child: Text(
                'Price: ${_sortOrder == 'asc' ? 'Low to High' : 'High to Low'}')),
        PopupMenuItem(value: 'rating', child: Text('Highest Rated')),
        PopupMenuItem(value: 'popular', child: Text('Most Popular')),
        PopupMenuItem(value: 'newest', child: Text('Newest First')),
        PopupMenuItem(value: 'name', child: Text('Name: A-Z')),
      ],
    );
  }

  String _getSortLabel(String sortBy) {
    switch (sortBy) {
      case 'price':
        return _sortOrder == 'asc' ? 'Price ↑' : 'Price ↓';
      case 'rating':
        return 'Rating';
      case 'popular':
        return 'Popular';
      case 'newest':
        return 'New';
      case 'name':
        return 'Name';
      default:
        return 'Relevance';
    }
  }

  Widget _buildProductGrid() {
    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 20,
        crossAxisSpacing: 16,
        childAspectRatio: 0.53,
      ),
      itemCount: filteredProducts.length + (_hasMoreData ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == filteredProducts.length) {
          return _buildLoadingIndicator();
        }
        return ProductCard(product: filteredProducts[index]);
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Padding(padding: const EdgeInsets.all(16.0), child: AppLoader()),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            'No Products Found',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Try adjusting your filters or search query',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _searchController.clear();
                _selectedBrandIds.clear();
                _selectedBrandNames.clear();
                _selectedSkinTypes.clear();
                _selectedSkinConcerns.clear();
                _selectedProductTypes.clear();
                _minRating = 0;
                _minPrice = null;
                _maxPrice = null;
                _inStock = false;
                _sortBy = 'relevance';
              });
              _fetchProducts(loadMore: false);
            },
            icon: Icon(Icons.refresh),
            label: Text('Clear Filters'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.secondaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTab() {
    return const ProfilePage();
  }

  Widget _buildShimmerEffect() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.65,
        ),
        itemCount: 10,
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          );
        },
      ),
    );
  }

  Widget _buildScrollToTopButton() {
    return Positioned(
      bottom: 20,
      right: 20,
      child: FloatingActionButton(
        backgroundColor: AppTheme.secondaryColor,
        child: const Icon(Icons.arrow_upward, color: Colors.white),
        onPressed: () {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        },
      ),
    );
  }
}