import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
import 'downloaded_pdf_screen.dart';

class ProductListingScreen extends StatefulWidget {
  const ProductListingScreen({super.key});

  @override
  State<ProductListingScreen> createState() => _ProductListingScreenState();
}

class _ProductListingScreenState extends State<ProductListingScreen>
    with SingleTickerProviderStateMixin {
  List<Products> products = [];
  List<Products> filteredProducts = [];
  Set<String> brands = {};
  List<String> filteredBrands = [];
  Timer? _debounce;
  final int _debounceDuration = 800; // milliseconds

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _brandSearchController = TextEditingController();

  bool _showTopButton = false;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;

  // Pagination variables
  int _currentPage = 1;
  final int _pageSize = 60;
  int _totalProducts = 0;

  String _sortBy = 'relevance';
  double _minRating = 0;
  Set<String> _selectedBrands = {};

  late TabController _tabController;

  // Filter properties
  Set<String> _selectedBenefits = {};
  Set<String> _selectedSkinTypes = {};
  Set<String> _selectedIngredients = {};
  bool _onSale = false;
  bool _newOnly = false;
  bool _cleanAtSephora = false;
  Set<String> _selectedColorFamily = {};
  String? _priceRange;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
    _scrollController.addListener(_scrollListener);
    _tabController = TabController(length: 3, vsync: this);
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
      final fetchedProductData = await ProductService.fetchProducts(
        query: _searchController.text.isEmpty
            ? 'lipstick'
            : _searchController.text,
        currentPage: _currentPage,
        pageSize: _pageSize,
        sortBy: _getSortByValue(_sortBy),
        brand: _selectedBrands.isNotEmpty ? _selectedBrands.first : null,
        rating: _minRating > 0 ? '"${_minRating.toInt()}"-"inf"' : null,
        priceRange: _priceRange,
        onSale: _onSale,
        newOnly: _newOnly,
        cleanAtSephora: _cleanAtSephora,
      );

      setState(() {
        if (loadMore) {
          products.addAll(fetchedProductData.products ?? []);
        } else {
          products = fetchedProductData.products ?? [];
        }

        _totalProducts = fetchedProductData.totalProducts ?? 0;
        _hasMoreData = products.length < _totalProducts;

        // Extract unique brands
        brands = products
            .where((p) => p.brandName != null && p.brandName!.isNotEmpty)
            .map((p) => p.brandName!)
            .toSet();
        filteredBrands = brands.toList()..sort();

        _applyFiltersAndSort();
        _isLoading = false;
        _isLoadingMore = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
      });
      if (kDebugMode) {
        print('Error fetching products: $error');
      }
    }
  }

  void _loadMoreProducts() {
    if (!_hasMoreData || _isLoadingMore) return;
    _currentPage++;
    _fetchProducts(loadMore: true);
  }

  void _scrollListener() {
    // Show/hide scroll to top button
    if (_scrollController.offset >= 400) {
      if (!_showTopButton) setState(() => _showTopButton = true);
    } else {
      if (_showTopButton) setState(() => _showTopButton = false);
    }

    // Auto-load more when near bottom
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreProducts();
    }
  }

  String? _getSortByValue(String sortBy) {
    switch (sortBy) {
      case 'price_low':
        return SortOptions.priceLowToHigh;
      case 'price_high':
        return SortOptions.priceHighToLow;
      case 'rating':
        return SortOptions.topRated;
      case 'newest':
        return SortOptions.newest;
      default:
        return SortOptions.relevance;
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

  double _parsePrice(String? priceString) {
    if (priceString == null || priceString.isEmpty) return 0.0;

    String cleaned = priceString.replaceAll(RegExp(r'[^\d.-]'), '');
    if (cleaned.contains('-')) {
      cleaned = cleaned.split('-')[0].trim();
    }
    return double.tryParse(cleaned) ?? 0.0;
  }

  void _applyFiltersAndSort() {
    List<Products> results = List.from(products);

    // Note: Search is already handled by the API, so we don't need to filter here
    // unless we want additional client-side filtering

    // Apply brand filter (for client-side filtering of multiple brands)
    if (_selectedBrands.isNotEmpty && _selectedBrands.length > 1) {
      results = results.where((product) {
        final brandName = product.brandName ?? '';
        return _selectedBrands.contains(brandName);
      }).toList();
    }

    // Apply rating filter (backup client-side filter)
    if (_minRating > 0) {
      results = results.where((product) {
        final rating = double.tryParse(product.rating ?? '0') ?? 0.0;
        return rating >= _minRating;
      }).toList();
    }

    // Client-side sorting (backup if API sorting fails)
    switch (_sortBy) {
      case 'price_low':
        results.sort((a, b) {
          final priceA =
              _parsePrice(a.currentSku?.salePrice ?? a.currentSku?.listPrice);
          final priceB =
              _parsePrice(b.currentSku?.salePrice ?? b.currentSku?.listPrice);
          return priceA.compareTo(priceB);
        });
        break;
      case 'price_high':
        results.sort((a, b) {
          final priceA =
              _parsePrice(a.currentSku?.salePrice ?? a.currentSku?.listPrice);
          final priceB =
              _parsePrice(b.currentSku?.salePrice ?? b.currentSku?.listPrice);
          return priceB.compareTo(priceA);
        });
        break;
      case 'rating':
        results.sort((a, b) {
          final ratingA = double.tryParse(a.rating ?? '0') ?? 0.0;
          final ratingB = double.tryParse(b.rating ?? '0') ?? 0.0;
          return ratingB.compareTo(ratingA);
        });
        break;
      case 'reviews':
        results.sort((a, b) {
          final reviewsA = int.tryParse(a.reviews ?? '0') ?? 0;
          final reviewsB = int.tryParse(b.reviews ?? '0') ?? 0;
          return reviewsB.compareTo(reviewsA);
        });
        break;
      case 'newest':
        results.sort((a, b) {
          final isNewA = a.currentSku?.isNew ?? false;
          final isNewB = b.currentSku?.isNew ?? false;
          if (isNewA && !isNewB) return -1;
          if (!isNewA && isNewB) return 1;
          return 0;
        });
        break;
    }

    setState(() {
      filteredProducts = results;
    });
  }

  void _filterBrands(String query) {
    if (query.isEmpty) {
      setState(() => filteredBrands = brands.toList()..sort());
    } else {
      setState(() {
        filteredBrands = brands
            .where((brand) => brand.toLowerCase().contains(query.toLowerCase()))
            .toList()
          ..sort();
      });
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
              // Tab(icon: const Icon(Icons.download), text: AppStrings.downloads),
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
            // _buildDownloadTab(),
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
          if (_hasMoreData && !_isLoadingMore)
            TextButton.icon(
              onPressed: _loadMoreProducts,
              icon: Icon(Icons.refresh, size: 16),
              label: Text('Load More'),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.secondaryColor,
                textStyle: TextStyle(fontSize: 12.sp),
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
                  hintText: 'Search for lipstick, brands...',
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
                  setState(() {}); // Update UI to show/hide clear button

                  // Cancel previous timer
                  if (_debounce?.isActive ?? false) _debounce!.cancel();

                  // Start new timer for debounced search
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

  int _getAppliedFiltersCount() {
    int count = 0;
    if (_selectedBrands.isNotEmpty) count++;
    if (_minRating > 0) count++;
    if (_priceRange != null) count++;
    if (_selectedBenefits.isNotEmpty) count++;
    if (_selectedSkinTypes.isNotEmpty) count++;
    if (_selectedIngredients.isNotEmpty) count++;
    if (_onSale) count++;
    if (_newOnly) count++;
    if (_cleanAtSephora) count++;
    if (_selectedColorFamily.isNotEmpty) count++;
    return count;
  }

  Future<void> _openFiltersScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FiltersScreen(
          selectedBrands: _selectedBrands,
          minRating: _minRating,
          priceRange: _priceRange,
          selectedBenefits: _selectedBenefits,
          selectedSkinTypes: _selectedSkinTypes,
          selectedIngredients: _selectedIngredients,
          onSale: _onSale,
          newOnly: _newOnly,
          cleanAtSephora: _cleanAtSephora,
          selectedColorFamily: _selectedColorFamily,
          availableBrands: brands.toList(),
        ),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _selectedBrands = result['brands'] ?? {};
        _minRating = result['rating'] ?? 0.0;
        _priceRange = result['priceRange'];
        _selectedBenefits = result['benefits'] ?? {};
        _selectedSkinTypes = result['skinTypes'] ?? {};
        _selectedIngredients = result['ingredients'] ?? {};
        _onSale = result['onSale'] ?? false;
        _newOnly = result['newOnly'] ?? false;
        _cleanAtSephora = result['cleanAtSephora'] ?? false;
        _selectedColorFamily = result['colorFamily'] ?? {};
      });
      _fetchProducts(loadMore: false);
    }
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
                  if (_selectedBrands.isNotEmpty)
                    _buildActiveFilterChip('Brands: ${_selectedBrands.length}',
                        () {
                      setState(() => _selectedBrands.clear());
                      _fetchProducts(loadMore: false);
                    }),
                  if (_minRating > 0)
                    _buildActiveFilterChip('${_minRating.toInt()}★ & up', () {
                      setState(() => _minRating = 0);
                      _fetchProducts(loadMore: false);
                    }),
                  if (_priceRange != null)
                    _buildActiveFilterChip('Price', () {
                      setState(() => _priceRange = null);
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
        setState(() => _sortBy = value);
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
        PopupMenuItem(value: 'price_low', child: Text('Price: Low to High')),
        PopupMenuItem(value: 'price_high', child: Text('Price: High to Low')),
        PopupMenuItem(value: 'rating', child: Text('Highest Rated')),
        PopupMenuItem(value: 'reviews', child: Text('Most Reviewed')),
        PopupMenuItem(value: 'newest', child: Text('New Arrivals')),
      ],
    );
  }

  String _getSortLabel(String sortBy) {
    switch (sortBy) {
      case 'price_low':
        return 'Price ↑';
      case 'price_high':
        return 'Price ↓';
      case 'rating':
        return 'Rating';
      case 'reviews':
        return 'Reviews';
      case 'newest':
        return 'New';
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
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.65,
      ),
      itemCount: filteredProducts.length + (_hasMoreData ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == filteredProducts.length) {
          return _buildLoadingIndicator();
        }
        return buildProductCard(
            product: filteredProducts[index], context: context);
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.secondaryColor),
        ),
      ),
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
            'Try adjusting your filters',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTab() {
    return const ProfilePage();
  }

  Widget _buildDownloadTab() {
    return DownloadedPDFsScreen();
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
