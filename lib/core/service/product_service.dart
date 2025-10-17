import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/product_model.dart';

class ProductService {
  // Sephora Base URL
  static const String _baseUrl = 'https://www.sephora.com/api/v2/catalog/search/';
  
  /// Fetch products with comprehensive search and filter options
  static Future<Product> fetchProducts({
    String? query,
    int currentPage = 1,
    int pageSize = 60,
    String? brand,
    String? priceRange,
    String? rating,
    String? sortBy,
    List<String>? benefits,
    List<String>? skinType,
    List<String>? ingredientPreferences,
    bool? onSale,
    bool? newOnly,
    bool? cleanAtSephora,
    bool? pickupEligible,
    bool? sameDayEligible,
  }) async {
    try {
      // Build query parameters
      final Map<String, String> queryParams = {
        'type': 'keyword',
        'q': query ?? 'lipstick',
        'includeEDD': 'true',
        'content': 'true',
        'includeRegionsMap': 'true',
        'page': pageSize.toString(),
        'currentPage': currentPage.toString(),
        'loc': 'en-US',
        'ch': 'rwd',
        'countryCode': 'US',
        'callAdSvc': 'true',
        'adSvcSlot': '2503111',
        'targetSearchEngine': 'nlp',
      };
      
      // Add filters if provided
      final List<String> filters = [];
      
      if (brand != null && brand.isNotEmpty) {
        filters.add('filters[Brand]=$brand');
      }
      
      if (priceRange != null && priceRange.isNotEmpty) {
        filters.add(priceRange);
      }
      
      if (rating != null && rating.isNotEmpty) {
        filters.add('filters[Rating]=$rating');
      }
      
      if (onSale == true) {
        filters.add('filters[on_sale]=true');
      }
      
      if (newOnly == true) {
        filters.add('filters[isNew]=true');
      }
      
      if (cleanAtSephora == true) {
        filters.add('filters[ingredientPreferences]=cleanAtSephora');
      }
      
      if (pickupEligible == true) {
        filters.add('filters[Pickup]=');
      }
      
      if (sameDayEligible == true) {
        filters.add('filters[SameDay]=');
      }
      
      if (benefits != null && benefits.isNotEmpty) {
        for (var benefit in benefits) {
          filters.add('filters[benefits]=$benefit');
        }
      }
      
      if (skinType != null && skinType.isNotEmpty) {
        for (var type in skinType) {
          filters.add('filters[skinType]=$type');
        }
      }
      
      if (ingredientPreferences != null && ingredientPreferences.isNotEmpty) {
        for (var pref in ingredientPreferences) {
          filters.add('filters[ingredientPreferences]=$pref');
        }
      }
      
      // Add sorting
      if (sortBy != null && sortBy.isNotEmpty) {
        queryParams['sort'] = sortBy;
      }
      
      // Build URI with query parameters
      var uri = Uri.parse(_baseUrl).replace(queryParameters: queryParams);
      
      // Add filters to URI if any
      if (filters.isNotEmpty) {
        String uriString = uri.toString();
        uriString += '&${filters.join('&')}';
        uri = Uri.parse(uriString);
      }
      
      print('🌐 Fetching from: $uri');
      
      // Make the API request
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return Product.fromJson(jsonData);
      } else {
        print('❌ Error Response: ${response.statusCode}');
        print('Response Body: ${response.body}');
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching products: $e');
      throw Exception('Error fetching products: $e');
    }
  }
  
  /// Fetch all products (default lipstick)
  static Future<Product> fetchAllProducts({
    int currentPage = 1,
    int pageSize = 60,
  }) async {
    return fetchProducts(
      query: 'lipstick',
      currentPage: currentPage,
      pageSize: pageSize,
    );
  }
  
  /// Search products by query
  static Future<Product> searchProducts(
    String searchQuery, {
    int currentPage = 1,
    int pageSize = 60,
    String? sortBy,
  }) async {
    return fetchProducts(
      query: searchQuery,
      currentPage: currentPage,
      pageSize: pageSize,
      sortBy: sortBy,
    );
  }
  
  /// Fetch products with brand filter
  static Future<Product> fetchProductsByBrand(
    String brand, {
    String? query,
    int currentPage = 1,
    int pageSize = 60,
  }) async {
    return fetchProducts(
      query: query ?? 'lipstick',
      currentPage: currentPage,
      pageSize: pageSize,
      brand: brand,
    );
  }
  
  /// Fetch products by price range
  static Future<Product> fetchProductsByPriceRange(
    String priceRange, {
    String? query,
    int currentPage = 1,
    int pageSize = 60,
  }) async {
    // Price range format: "pl=min&ph=max"
    // Examples:
    // Under $25: "pl=min&ph=25"
    // $25 to $50: "pl=25&ph=50"
    // $50 to $100: "pl=50&ph=100"
    // $100 and above: "pl=100&ph=max"
    
    return fetchProducts(
      query: query ?? 'lipstick',
      currentPage: currentPage,
      pageSize: pageSize,
      priceRange: priceRange,
    );
  }
  
  /// Fetch products by rating
  static Future<Product> fetchProductsByRating(
    double minRating, {
    String? query,
    int currentPage = 1,
    int pageSize = 60,
  }) async {
    // Rating format: "4"-"inf", "3"-"inf", "2"-"inf", "1"-"inf"
    final ratingFilter = '"${minRating.toInt()}"-"inf"';
    
    return fetchProducts(
      query: query ?? 'lipstick',
      currentPage: currentPage,
      pageSize: pageSize,
      rating: ratingFilter,
    );
  }
  
  /// Fetch new products only
  static Future<Product> fetchNewProducts({
    String? query,
    int currentPage = 1,
    int pageSize = 60,
  }) async {
    return fetchProducts(
      query: query ?? 'lipstick',
      currentPage: currentPage,
      pageSize: pageSize,
      newOnly: true,
    );
  }
  
  /// Fetch products on sale
  static Future<Product> fetchSaleProducts({
    String? query,
    int currentPage = 1,
    int pageSize = 60,
  }) async {
    return fetchProducts(
      query: query ?? 'lipstick',
      currentPage: currentPage,
      pageSize: pageSize,
      onSale: true,
    );
  }
  
  /// Fetch Clean at Sephora products
  static Future<Product> fetchCleanProducts({
    String? query,
    int currentPage = 1,
    int pageSize = 60,
  }) async {
    return fetchProducts(
      query: query ?? 'lipstick',
      currentPage: currentPage,
      pageSize: pageSize,
      cleanAtSephora: true,
    );
  }
  
  /// Fetch products with multiple filters
  static Future<Product> fetchFilteredProducts({
    String? query,
    int currentPage = 1,
    int pageSize = 60,
    List<String>? brands,
    String? priceMin,
    String? priceMax,
    double? minRating,
    String? sortBy,
    List<String>? benefits,
    List<String>? skinType,
    List<String>? ingredientPreferences,
    bool? onSale,
    bool? newOnly,
    bool? cleanAtSephora,
    bool? pickupEligible,
    bool? sameDayEligible,
  }) async {
    // Build price range if provided
    String? priceRange;
    if (priceMin != null || priceMax != null) {
      priceRange = 'pl=${priceMin ?? "min"}&ph=${priceMax ?? "max"}';
    }
    
    // Build rating filter if provided
    String? ratingFilter;
    if (minRating != null) {
      ratingFilter = '"${minRating.toInt()}"-"inf"';
    }
    
    // For multiple brands, we need to call the API multiple times
    // or filter the results client-side
    // For now, using the first brand if multiple are provided
    final brand = brands != null && brands.isNotEmpty ? brands.first : null;
    
    return fetchProducts(
      query: query ?? 'lipstick',
      currentPage: currentPage,
      pageSize: pageSize,
      brand: brand,
      priceRange: priceRange,
      rating: ratingFilter,
      sortBy: sortBy,
      benefits: benefits,
      skinType: skinType,
      ingredientPreferences: ingredientPreferences,
      onSale: onSale,
      newOnly: newOnly,
      cleanAtSephora: cleanAtSephora,
      pickupEligible: pickupEligible,
      sameDayEligible: sameDayEligible,
    );
  }
  
  
}

/// Sort options helper
   class SortOptions {
    static const String relevance = '';
    static const String priceLowToHigh = 'price_asc';
    static const String priceHighToLow = 'price_desc';
    static const String topRated = 'rating_desc';
    static const String newest = 'date_desc';
    static const String bestSelling = 'bestselling';
  }
  
  /// Price range helper
   class PriceRanges {
    static const String under25 = 'pl=min&ph=25';
    static const String range25to50 = 'pl=25&ph=50';
    static const String range50to100 = 'pl=50&ph=100';
    static const String above100 = 'pl=100&ph=max';
    
    static String custom(String min, String max) => 'pl=$min&ph=$max';
  }
  
  /// Benefits filter options
   class Benefits {
    static const String hydrating = 'hydrating';
    static const String longWearing = 'longWearing';
    static const String transferResistant = 'transferResistant';
    static const String plumping = 'plumping';
    static const String moisturizing = 'moisturizing';
    static const String transferProof = 'transferProof';
  }
  
  /// Skin type filter options
   class SkinTypes {
    static const String normal = 'normalSk';
    static const String dry = 'drySk';
    static const String oily = 'oilySk';
    static const String combination = 'comboSk';
    static const String sensitive = 'sensitiveSk';
  }
  
  /// Ingredient preferences filter options
   class IngredientPreferences {
    static const String vegan = 'vegan';
    static const String cleanAtSephora = 'cleanAtSephora';
    static const String parabenFree = 'parabenFree';
    static const String crueltyFree = 'crueltyFree';
    static const String sulfateFree = 'sulfateFree';
    static const String alcoholFree = 'alcoholFree';
    static const String fragranceFree = 'fragranceFree';
    static const String siliconeFree = 'siliconeFree';
  }