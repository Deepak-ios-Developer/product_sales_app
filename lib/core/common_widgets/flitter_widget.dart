import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:product_sale_app/core/themes/app_theme.dart';
import '../model/product_model.dart';

class FiltersScreen extends StatefulWidget {
  final Set<String> selectedBrandIds;
  final Set<String> selectedBrandNames;
  final double minRating;
  final int? minPrice;
  final int? maxPrice;
  final Set<String> selectedSkinTypes;
  final Set<String> selectedSkinConcerns;
  final Set<String> selectedProductTypes;
  final bool inStock;
  final List<Brand> availableBrands;
  final List<AttributeFilter> availableAttributes;

  const FiltersScreen({
    super.key,
    required this.selectedBrandIds,
    required this.selectedBrandNames,
    required this.minRating,
    this.minPrice,
    this.maxPrice,
    required this.selectedSkinTypes,
    required this.selectedSkinConcerns,
    required this.selectedProductTypes,
    required this.inStock,
    required this.availableBrands,
    required this.availableAttributes,
  });

  @override
  State<FiltersScreen> createState() => _FiltersScreenState();
}

class _FiltersScreenState extends State<FiltersScreen> {
  late Set<String> _selectedBrandIds;
  late Set<String> _selectedBrandNames;
  late double _minRating;
  late int? _minPrice;
  late int? _maxPrice;
  late Set<String> _selectedSkinTypes;
  late Set<String> _selectedSkinConcerns;
  late Set<String> _selectedProductTypes;
  late bool _inStock;

  String _selectedCategory = 'Brand';
  final TextEditingController _brandSearchController = TextEditingController();
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();
  
  List<Brand> _filteredBrands = [];

  final List<String> _categories = [
    'Brand',
    'Price',
    'Rating',
    'Skin Type',
    'Skin Concern',
    'Product Type',
    'More Filters',
  ];

  final List<Map<String, dynamic>> _priceRanges = [
    {'label': 'Under ₹500', 'min': null, 'max': 500},
    {'label': '₹500 - ₹1000', 'min': 500, 'max': 1000},
    {'label': '₹1000 - ₹1500', 'min': 1000, 'max': 1500},
    {'label': '₹1500 - ₹2000', 'min': 1500, 'max': 2000},
    {'label': '₹2000 and above', 'min': 2000, 'max': null},
  ];

  // Get available options from attributes
  List<String> _skinTypeOptions = [];
  List<String> _skinConcernOptions = [];
  List<String> _productTypeOptions = [];

  @override
  void initState() {
    super.initState();
    _selectedBrandIds = Set.from(widget.selectedBrandIds);
    _selectedBrandNames = Set.from(widget.selectedBrandNames);
    _minRating = widget.minRating;
    _minPrice = widget.minPrice;
    _maxPrice = widget.maxPrice;
    _selectedSkinTypes = Set.from(widget.selectedSkinTypes);
    _selectedSkinConcerns = Set.from(widget.selectedSkinConcerns);
    _selectedProductTypes = Set.from(widget.selectedProductTypes);
    _inStock = widget.inStock;
    _filteredBrands = List.from(widget.availableBrands);

    // Initialize price controllers
    if (_minPrice != null) {
      _minPriceController.text = _minPrice.toString();
    }
    if (_maxPrice != null) {
      _maxPriceController.text = _maxPrice.toString();
    }

    // Extract options from attributes
    _extractAttributeOptions();
  }

  void _extractAttributeOptions() {
    for (var attribute in widget.availableAttributes) {
      if (attribute.code == 'SKIN_TYPE') {
        _skinTypeOptions = attribute.values?.map((v) => v.value ?? '').where((v) => v.isNotEmpty).toList() ?? [];
      } else if (attribute.code == 'SKIN_CONCERN') {
        _skinConcernOptions = attribute.values?.map((v) => v.value ?? '').where((v) => v.isNotEmpty).toList() ?? [];
      } else if (attribute.code == 'PRODUCT_TYPE') {
        _productTypeOptions = attribute.values?.map((v) => v.value ?? '').where((v) => v.isNotEmpty).toList() ?? [];
      }
    }
  }

  void _filterBrands(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredBrands = List.from(widget.availableBrands);
      } else {
        _filteredBrands = widget.availableBrands
            .where((brand) =>
                (brand.title ?? brand.name ?? '').toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _clearAllFilters() {
    setState(() {
      _selectedBrandIds.clear();
      _selectedBrandNames.clear();
      _minRating = 0;
      _minPrice = null;
      _maxPrice = null;
      _selectedSkinTypes.clear();
      _selectedSkinConcerns.clear();
      _selectedProductTypes.clear();
      _inStock = false;
      _minPriceController.clear();
      _maxPriceController.clear();
    });
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
    return count;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filterCount = _getAppliedFiltersCount();

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.grey[50],
      appBar: AppBar(
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Filters',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _clearAllFilters,
            child: Text(
              'Clear All',
              style: TextStyle(
                color: AppTheme.secondaryColor,
                fontSize: 14.sp,
              ),
            ),
          ),
        ],
      ),
      body: Row(
        children: [
          // Left sidebar - Categories
          Container(
            width: 120.w,
            color: isDark ? Colors.grey[900] : Colors.white,
            child: ListView.builder(
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category;

                return InkWell(
                  onTap: () {
                    setState(() => _selectedCategory = category);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (isDark ? Colors.grey[850] : Colors.grey[100])
                          : Colors.transparent,
                      border: Border(
                        left: BorderSide(
                          color: isSelected ? AppTheme.secondaryColor : Colors.transparent,
                          width: 3,
                        ),
                      ),
                    ),
                    child: Text(
                      category,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: isSelected
                            ? (isDark ? Colors.white : Colors.black)
                            : Colors.grey[600],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Right content area
          Expanded(
            child: Container(
              color: isDark ? Colors.black : Colors.grey[50],
              child: _buildFilterContent(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[900] : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.availableBrands.length} brands available',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    if (filterCount > 0)
                      Text(
                        '$filterCount filters applied',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(width: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, {
                    'brandIds': _selectedBrandIds,
                    'brandNames': _selectedBrandNames,
                    'rating': _minRating,
                    'minPrice': _minPrice,
                    'maxPrice': _maxPrice,
                    'skinTypes': _selectedSkinTypes,
                    'skinConcerns': _selectedSkinConcerns,
                    'productTypes': _selectedProductTypes,
                    'inStock': _inStock,
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.secondaryColor,
                  padding: EdgeInsets.symmetric(horizontal: 48, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'APPLY',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterContent() {
    switch (_selectedCategory) {
      case 'Brand':
        return _buildBrandFilter();
      case 'Price':
        return _buildPriceFilter();
      case 'Rating':
        return _buildRatingFilter();
      case 'Skin Type':
        return _buildSkinTypeFilter();
      case 'Skin Concern':
        return _buildSkinConcernFilter();
      case 'Product Type':
        return _buildProductTypeFilter();
      case 'More Filters':
        return _buildMoreFilters();
      default:
        return Container();
    }
  }

  Widget _buildBrandFilter() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Search bar
        Container(
          padding: EdgeInsets.all(16),
          color: isDark ? Colors.grey[900] : Colors.white,
          child: TextField(
            controller: _brandSearchController,
            decoration: InputDecoration(
              hintText: 'Search Brand',
              prefixIcon: Icon(Icons.search, size: 20),
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            onChanged: _filterBrands,
          ),
        ),

        // Popular filters header
        if (_brandSearchController.text.isEmpty) ...[
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: isDark ? Colors.grey[850] : Colors.grey[100],
            child: Text(
              'Popular Brands',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],

        // Brand list
        Expanded(
          child: _filteredBrands.isEmpty
              ? Center(
                  child: Text(
                    'No brands found',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                )
              : ListView.builder(
                  itemCount: _filteredBrands.length,
                  itemBuilder: (context, index) {
                    final brand = _filteredBrands[index];
                    final brandId = brand.id ?? '';
                    final brandName = brand.title ?? brand.name ?? '';
                    final isSelected = _selectedBrandIds.contains(brandId);
                    final productCount = brand.productCount ?? 0;

                    return CheckboxListTile(
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              brandName,
                              style: TextStyle(fontSize: 14.sp),
                            ),
                          ),
                          Text(
                            '($productCount)',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      value: isSelected,
                      activeColor: AppTheme.secondaryColor,
                      onChanged: (value) {
                        setState(() {
                          if (value == true) {
                            _selectedBrandIds.add(brandId);
                            _selectedBrandNames.add(brandName);
                          } else {
                            _selectedBrandIds.remove(brandId);
                            _selectedBrandNames.remove(brandName);
                          }
                        });
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildPriceFilter() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        // Predefined ranges
        ..._priceRanges.map((range) {
          final isSelected = _minPrice == range['min'] && _maxPrice == range['max'];

          return RadioListTile<String>(
            title: Text(range['label']!, style: TextStyle(fontSize: 14.sp)),
            value: range['label']!,
            groupValue: isSelected ? range['label'] : null,
            activeColor: AppTheme.secondaryColor,
            onChanged: (value) {
              setState(() {
                _minPrice = range['min'];
                _maxPrice = range['max'];
                _minPriceController.text = _minPrice?.toString() ?? '';
                _maxPriceController.text = _maxPrice?.toString() ?? '';
              });
            },
          );
        }).toList(),

        Divider(height: 32),

        // Custom range
        Text(
          'Custom Price Range',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _minPriceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Min Price',
                  prefixText: '₹',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  _minPrice = int.tryParse(value);
                },
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: TextField(
                controller: _maxPriceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Max Price',
                  prefixText: '₹',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  _maxPrice = int.tryParse(value);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRatingFilter() {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [4, 3, 2, 1].map((rating) {
        return RadioListTile<double>(
          title: Row(
            children: [
              Icon(Icons.star, size: 18, color: Colors.amber),
              SizedBox(width: 4),
              Text('$rating & up', style: TextStyle(fontSize: 14.sp)),
            ],
          ),
          value: rating.toDouble(),
          groupValue: _minRating,
          activeColor: AppTheme.secondaryColor,
          onChanged: (value) {
            setState(() => _minRating = value ?? 0);
          },
        );
      }).toList(),
    );
  }

  Widget _buildSkinTypeFilter() {
    return ListView(
      padding: EdgeInsets.all(16),
      children: _skinTypeOptions.isEmpty
          ? [
              Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    'No skin types available',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              )
            ]
          : _skinTypeOptions.map((type) {
              final isSelected = _selectedSkinTypes.contains(type);

              return CheckboxListTile(
                title: Text(type, style: TextStyle(fontSize: 14.sp)),
                value: isSelected,
                activeColor: AppTheme.secondaryColor,
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      _selectedSkinTypes.add(type);
                    } else {
                      _selectedSkinTypes.remove(type);
                    }
                  });
                },
              );
            }).toList(),
    );
  }

  Widget _buildSkinConcernFilter() {
    return ListView(
      padding: EdgeInsets.all(16),
      children: _skinConcernOptions.isEmpty
          ? [
              Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    'No skin concerns available',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              )
            ]
          : _skinConcernOptions.map((concern) {
              final isSelected = _selectedSkinConcerns.contains(concern);

              return CheckboxListTile(
                title: Text(concern, style: TextStyle(fontSize: 14.sp)),
                value: isSelected,
                activeColor: AppTheme.secondaryColor,
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      _selectedSkinConcerns.add(concern);
                    } else {
                      _selectedSkinConcerns.remove(concern);
                    }
                  });
                },
              );
            }).toList(),
    );
  }

  Widget _buildProductTypeFilter() {
    return ListView(
      padding: EdgeInsets.all(16),
      children: _productTypeOptions.isEmpty
          ? [
              Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    'No product types available',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              )
            ]
          : _productTypeOptions.map((type) {
              final isSelected = _selectedProductTypes.contains(type);

              return CheckboxListTile(
                title: Text(type, style: TextStyle(fontSize: 14.sp)),
                value: isSelected,
                activeColor: AppTheme.secondaryColor,
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      _selectedProductTypes.add(type);
                    } else {
                      _selectedProductTypes.remove(type);
                    }
                  });
                },
              );
            }).toList(),
    );
  }

  Widget _buildMoreFilters() {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        SwitchListTile(
          title: Text('In Stock Only', style: TextStyle(fontSize: 14.sp)),
          subtitle: Text('Show only products available in stock'),
          value: _inStock,
          activeColor: AppTheme.secondaryColor,
          onChanged: (value) {
            setState(() => _inStock = value);
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    _brandSearchController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }
}