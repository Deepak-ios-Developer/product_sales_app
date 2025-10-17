import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:product_sale_app/core/themes/app_theme.dart';

class FiltersScreen extends StatefulWidget {
  final Set<String> selectedBrands;
  final double minRating;
  final String? priceRange;
  final Set<String> selectedBenefits;
  final Set<String> selectedSkinTypes;
  final Set<String> selectedIngredients;
  final bool onSale;
  final bool newOnly;
  final bool cleanAtSephora;
  final Set<String> selectedColorFamily;
  final List<String> availableBrands;

  const FiltersScreen({
    super.key,
    required this.selectedBrands,
    required this.minRating,
    this.priceRange,
    required this.selectedBenefits,
    required this.selectedSkinTypes,
    required this.selectedIngredients,
    required this.onSale,
    required this.newOnly,
    required this.cleanAtSephora,
    required this.selectedColorFamily,
    required this.availableBrands,
  });

  @override
  State<FiltersScreen> createState() => _FiltersScreenState();
}

class _FiltersScreenState extends State<FiltersScreen> {
  late Set<String> _selectedBrands;
  late double _minRating;
  late String? _priceRange;
  late Set<String> _selectedBenefits;
  late Set<String> _selectedSkinTypes;
  late Set<String> _selectedIngredients;
  late bool _onSale;
  late bool _newOnly;
  late bool _cleanAtSephora;
  late Set<String> _selectedColorFamily;

  String _selectedCategory = 'Brand';
  final TextEditingController _brandSearchController = TextEditingController();
  List<String> _filteredBrands = [];

  final List<String> _categories = [
    'Brand',
    'Color',
    'Price',
    'Rating',
    'Benefits',
    'Skin Type',
    'Ingredients',
    'More Filters',
  ];

  final List<Map<String, dynamic>> _colorFamilies = [
    {'name': 'Nude', 'color': Color(0xFFE8CDB2)},
    {'name': 'Pink', 'color': Colors.pink},
    {'name': 'Red', 'color': Colors.red},
    {'name': 'Brown', 'color': Colors.brown},
    {'name': 'Purple', 'color': Colors.purple},
    {'name': 'Berry', 'color': Color(0xFF8B2252)},
    {'name': 'Coral', 'color': Color(0xFFFF7F50)},
    {'name': 'Orange', 'color': Colors.orange},
  ];

  final List<Map<String, String>> _priceRanges = [
    {'label': 'Under \$25', 'value': 'pl=min&ph=25'},
    {'label': '\$25 to \$50', 'value': 'pl=25&ph=50'},
    {'label': '\$50 to \$100', 'value': 'pl=50&ph=100'},
    {'label': '\$100 and above', 'value': 'pl=100&ph=max'},
  ];

  final List<String> _benefits = [
    'Hydrating',
    'Long-wearing',
    'Transfer-resistant',
    'Plumping',
    'Moisturizing',
  ];

  final List<String> _skinTypes = [
    'Normal',
    'Dry',
    'Oily',
    'Combination',
    'Sensitive',
  ];

  final List<String> _ingredients = [
    'Vegan',
    'Clean at Sephora',
    'Paraben-free',
    'Cruelty-Free',
    'Sulfate-free',
    'Fragrance Free',
  ];

  @override
  void initState() {
    super.initState();
    _selectedBrands = Set.from(widget.selectedBrands);
    _minRating = widget.minRating;
    _priceRange = widget.priceRange;
    _selectedBenefits = Set.from(widget.selectedBenefits);
    _selectedSkinTypes = Set.from(widget.selectedSkinTypes);
    _selectedIngredients = Set.from(widget.selectedIngredients);
    _onSale = widget.onSale;
    _newOnly = widget.newOnly;
    _cleanAtSephora = widget.cleanAtSephora;
    _selectedColorFamily = Set.from(widget.selectedColorFamily);
    _filteredBrands = List.from(widget.availableBrands);
  }

  void _filterBrands(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredBrands = List.from(widget.availableBrands);
      } else {
        _filteredBrands = widget.availableBrands
            .where((brand) => brand.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _clearAllFilters() {
    setState(() {
      _selectedBrands.clear();
      _minRating = 0;
      _priceRange = null;
      _selectedBenefits.clear();
      _selectedSkinTypes.clear();
      _selectedIngredients.clear();
      _onSale = false;
      _newOnly = false;
      _cleanAtSephora = false;
      _selectedColorFamily.clear();
    });
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
                      '${widget.availableBrands.length} products',
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
                    'brands': _selectedBrands,
                    'rating': _minRating,
                    'priceRange': _priceRange,
                    'benefits': _selectedBenefits,
                    'skinTypes': _selectedSkinTypes,
                    'ingredients': _selectedIngredients,
                    'onSale': _onSale,
                    'newOnly': _newOnly,
                    'cleanAtSephora': _cleanAtSephora,
                    'colorFamily': _selectedColorFamily,
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
      case 'Color':
        return _buildColorFilter();
      case 'Price':
        return _buildPriceFilter();
      case 'Rating':
        return _buildRatingFilter();
      case 'Benefits':
        return _buildBenefitsFilter();
      case 'Skin Type':
        return _buildSkinTypeFilter();
      case 'Ingredients':
        return _buildIngredientsFilter();
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
              'Popular Filters',
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
          child: ListView.builder(
            itemCount: _filteredBrands.length,
            itemBuilder: (context, index) {
              final brand = _filteredBrands[index];
              final isSelected = _selectedBrands.contains(brand);
              
              return CheckboxListTile(
                title: Text(
                  brand,
                  style: TextStyle(fontSize: 14.sp),
                ),
                value: isSelected,
                activeColor: AppTheme.secondaryColor,
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      _selectedBrands.add(brand);
                    } else {
                      _selectedBrands.remove(brand);
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

  Widget _buildColorFilter() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return ListView(
      padding: EdgeInsets.all(16),
      children: _colorFamilies.map((colorData) {
        final colorName = colorData['name'] as String;
        final color = colorData['color'] as Color;
        final isSelected = _selectedColorFamily.contains(colorName.toLowerCase());
        
        return CheckboxListTile(
          title: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey[300]!, width: 1),
                ),
              ),
              SizedBox(width: 12),
              Text(colorName, style: TextStyle(fontSize: 14.sp)),
            ],
          ),
          value: isSelected,
          activeColor: AppTheme.secondaryColor,
          onChanged: (value) {
            setState(() {
              if (value == true) {
                _selectedColorFamily.add(colorName.toLowerCase());
              } else {
                _selectedColorFamily.remove(colorName.toLowerCase());
              }
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildPriceFilter() {
    return ListView(
      padding: EdgeInsets.all(16),
      children: _priceRanges.map((range) {
        final isSelected = _priceRange == range['value'];
        
        return RadioListTile<String>(
          title: Text(range['label']!, style: TextStyle(fontSize: 14.sp)),
          value: range['value']!,
          groupValue: _priceRange,
          activeColor: AppTheme.secondaryColor,
          onChanged: (value) {
            setState(() => _priceRange = value);
          },
        );
      }).toList(),
    );
  }

  Widget _buildRatingFilter() {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [4, 3, 2, 1].map((rating) {
        final isSelected = _minRating == rating.toDouble();
        
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

  Widget _buildBenefitsFilter() {
    return ListView(
      padding: EdgeInsets.all(16),
      children: _benefits.map((benefit) {
        final isSelected = _selectedBenefits.contains(benefit.toLowerCase());
        
        return CheckboxListTile(
          title: Text(benefit, style: TextStyle(fontSize: 14.sp)),
          value: isSelected,
          activeColor: AppTheme.secondaryColor,
          onChanged: (value) {
            setState(() {
              if (value == true) {
                _selectedBenefits.add(benefit.toLowerCase());
              } else {
                _selectedBenefits.remove(benefit.toLowerCase());
              }
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildSkinTypeFilter() {
    return ListView(
      padding: EdgeInsets.all(16),
      children: _skinTypes.map((type) {
        final isSelected = _selectedSkinTypes.contains(type.toLowerCase());
        
        return CheckboxListTile(
          title: Text(type, style: TextStyle(fontSize: 14.sp)),
          value: isSelected,
          activeColor: AppTheme.secondaryColor,
          onChanged: (value) {
            setState(() {
              if (value == true) {
                _selectedSkinTypes.add(type.toLowerCase());
              } else {
                _selectedSkinTypes.remove(type.toLowerCase());
              }
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildIngredientsFilter() {
    return ListView(
      padding: EdgeInsets.all(16),
      children: _ingredients.map((ingredient) {
        final isSelected = _selectedIngredients.contains(ingredient.toLowerCase());
        
        return CheckboxListTile(
          title: Text(ingredient, style: TextStyle(fontSize: 14.sp)),
          value: isSelected,
          activeColor: AppTheme.secondaryColor,
          onChanged: (value) {
            setState(() {
              if (value == true) {
                _selectedIngredients.add(ingredient.toLowerCase());
              } else {
                _selectedIngredients.remove(ingredient.toLowerCase());
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
          title: Text('On Sale', style: TextStyle(fontSize: 14.sp)),
          value: _onSale,
          activeColor: AppTheme.secondaryColor,
          onChanged: (value) {
            setState(() => _onSale = value);
          },
        ),
        SwitchListTile(
          title: Text('New Arrivals', style: TextStyle(fontSize: 14.sp)),
          value: _newOnly,
          activeColor: AppTheme.secondaryColor,
          onChanged: (value) {
            setState(() => _newOnly = value);
          },
        ),
        SwitchListTile(
          title: Text('Clean at Sephora', style: TextStyle(fontSize: 14.sp)),
          value: _cleanAtSephora,
          activeColor: AppTheme.secondaryColor,
          onChanged: (value) {
            setState(() => _cleanAtSephora = value);
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    _brandSearchController.dispose();
    super.dispose();
  }
}