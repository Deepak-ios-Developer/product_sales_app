import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:product_sale_app/core/model/product_detail_model.dart';
import '../model/product_model.dart';

class ProductService {
  // Base URLs
  static const String _baseUrl = 'https://www.stryce.com/api/v1/store/product-search';

  /// Fetch products with comprehensive search and filter options
  static Future<ProductResponse> fetchProducts({
    String? query,
    int page = 1,
    int limit = 20,
    bool inStock = false,
    String? brandId,
    String? categoryId,
    String? skinType,
    String? skinConcern,
    String? productType,
    int? minPrice,
    int? maxPrice,
    double? minRating,
    String? sortBy,
    String? sortOrder,
    String? productId,
  }) async {
    try {
      // Build query parameters
      final Map<String, String> queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        'inStock': inStock.toString(),
      };

      // Add search query if provided
      if (query != null && query.isNotEmpty) {
        queryParams['q'] = query;
      }

      // Add product ID if provided
      if (productId != null && productId.isNotEmpty) {
        queryParams['id'] = productId;
      }

      // Add filters if provided
      if (brandId != null && brandId.isNotEmpty) {
        queryParams['brandId'] = brandId;
      }

      if (categoryId != null && categoryId.isNotEmpty) {
        queryParams['categoryId'] = categoryId;
      }

      if (skinType != null && skinType.isNotEmpty) {
        queryParams['skinType'] = skinType;
      }

      if (skinConcern != null && skinConcern.isNotEmpty) {
        queryParams['skinConcern'] = skinConcern;
      }

      if (productType != null && productType.isNotEmpty) {
        queryParams['productType'] = productType;
      }

      if (minPrice != null) {
        queryParams['minPrice'] = minPrice.toString();
      }

      if (maxPrice != null) {
        queryParams['maxPrice'] = maxPrice.toString();
      }

      if (minRating != null) {
        queryParams['minRating'] = minRating.toString();
      }

      if (sortBy != null && sortBy.isNotEmpty) {
        queryParams['sortBy'] = sortBy;
      }

      if (sortOrder != null && sortOrder.isNotEmpty) {
        queryParams['sortOrder'] = sortOrder;
      }

      // Build URI with query parameters
      final uri = Uri.parse(_baseUrl).replace(queryParameters: queryParams);
      print('🌐 Fetching from: $uri');

      // Make the API request
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        print('✅ Success: Loaded ${jsonData['meta']?['items'] ?? 0} products');
        return ProductResponse.fromJson(jsonData);
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

  /// Fetch product reviews
  static Future<ProductDetailResponseData> fetchProductReviews({
    required String productId,
    int page = 1,
    int limit = 10,
    String? search,
    String? searchFields,
    String? sort,
  }) async {
    try {
      final Map<String, String> queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        'search': search ?? '',
        'searchFields': searchFields ?? '',
        'sort': sort ?? '',
      };

      final url = '$_baseUrl/product/$productId';
      final uri = Uri.parse(url).replace(queryParameters: queryParams);

      print('🌐 Fetching reviews from: $uri');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        print('✅ Success: Loaded ${jsonData['meta']?['total'] ?? 0} reviews');
        return ProductDetailResponseData.fromJson(jsonData);
      } else {
        print('❌ Error Response: ${response.statusCode}');
        throw Exception('Failed to load reviews: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching reviews: $e');
      throw Exception('Error fetching reviews: $e');
    }
  }

  /// Fetch all products (default search)
  static Future<ProductResponse> fetchAllProducts({
    int page = 1,
    int limit = 20,
    bool inStock = false,
  }) async {
    return fetchProducts(
      page: page,
      limit: limit,
      inStock: inStock,
    );
  }

  /// Fetch product detail by ID
  static Future<ProductResponse> fetchProductDetail({
    required String productId,
  }) async {
    return fetchProducts(
      productId: productId,
      limit: 1,
    );
  }

  /// Search products by query
  static Future<ProductResponse> searchProducts(
    String searchQuery, {
    int page = 1,
    int limit = 20,
    bool inStock = false,
    String? sortBy,
    String? sortOrder,
  }) async {
    return fetchProducts(
      query: searchQuery,
      page: page,
      limit: limit,
      inStock: inStock,
      sortBy: sortBy,
      sortOrder: sortOrder,
    );
  }

  /// Fetch products by brand
  static Future<ProductResponse> fetchProductsByBrand(
    String brandId, {
    String? query,
    int page = 1,
    int limit = 20,
    bool inStock = false,
  }) async {
    return fetchProducts(
      query: query,
      page: page,
      limit: limit,
      inStock: inStock,
      brandId: brandId,
    );
  }

  /// Fetch products by category
  static Future<ProductResponse> fetchProductsByCategory(
    String categoryId, {
    String? query,
    int page = 1,
    int limit = 20,
    bool inStock = false,
  }) async {
    return fetchProducts(
      query: query,
      page: page,
      limit: limit,
      inStock: inStock,
      categoryId: categoryId,
    );
  }

  /// Fetch products by price range
  static Future<ProductResponse> fetchProductsByPriceRange({
    String? query,
    int? minPrice,
    int? maxPrice,
    int page = 1,
    int limit = 20,
    bool inStock = false,
  }) async {
    return fetchProducts(
      query: query,
      page: page,
      limit: limit,
      inStock: inStock,
      minPrice: minPrice,
      maxPrice: maxPrice,
    );
  }

  /// Fetch products by rating
  static Future<ProductResponse> fetchProductsByRating(
    double minRating, {
    String? query,
    int page = 1,
    int limit = 20,
    bool inStock = false,
  }) async {
    return fetchProducts(
      query: query,
      page: page,
      limit: limit,
      inStock: inStock,
      minRating: minRating,
    );
  }

  /// Fetch products by skin type
  static Future<ProductResponse> fetchProductsBySkinType(
    String skinType, {
    String? query,
    int page = 1,
    int limit = 20,
    bool inStock = false,
  }) async {
    return fetchProducts(
      query: query,
      page: page,
      limit: limit,
      inStock: inStock,
      skinType: skinType,
    );
  }

  /// Fetch products by skin concern
  static Future<ProductResponse> fetchProductsBySkinConcern(
    String skinConcern, {
    String? query,
    int page = 1,
    int limit = 20,
    bool inStock = false,
  }) async {
    return fetchProducts(
      query: query,
      page: page,
      limit: limit,
      inStock: inStock,
      skinConcern: skinConcern,
    );
  }

  /// Fetch products by product type
  static Future<ProductResponse> fetchProductsByType(
    String productType, {
    String? query,
    int page = 1,
    int limit = 20,
    bool inStock = false,
  }) async {
    return fetchProducts(
      query: query,
      page: page,
      limit: limit,
      inStock: inStock,
      productType: productType,
    );
  }

  /// Fetch in-stock products only
  static Future<ProductResponse> fetchInStockProducts({
    String? query,
    int page = 1,
    int limit = 20,
  }) async {
    return fetchProducts(
      query: query,
      page: page,
      limit: limit,
      inStock: true,
    );
  }

  /// Fetch products with multiple filters
  static Future<ProductResponse> fetchFilteredProducts({
    String? query,
    int page = 1,
    int limit = 20,
    bool inStock = false,
    String? brandId,
    String? categoryId,
    String? skinType,
    String? skinConcern,
    String? productType,
    int? minPrice,
    int? maxPrice,
    double? minRating,
    String? sortBy,
    String? sortOrder,
  }) async {
    return fetchProducts(
      query: query,
      page: page,
      limit: limit,
      inStock: inStock,
      brandId: brandId,
      categoryId: categoryId,
      skinType: skinType,
      skinConcern: skinConcern,
      productType: productType,
      minPrice: minPrice,
      maxPrice: maxPrice,
      minRating: minRating,
      sortBy: sortBy,
      sortOrder: sortOrder,
    );
  }

  /// Fetch available brands
  static List<Brand>? getBrands(ProductResponse response) {
    return response.data?.brands;
  }

  /// Fetch available attributes (filters)
  static List<AttributeFilter>? getAttributes(ProductResponse response) {
    return response.data?.attributes;
  }

  /// Get total products count
  static int getTotalProducts(ProductResponse response) {
    return response.meta?.total ?? 0;
  }

  /// Get current page
  static int getCurrentPage(ProductResponse response) {
    return response.meta?.currentPage ?? 1;
  }

  /// Get total pages
  static int getTotalPages(ProductResponse response) {
    return response.meta?.lastPage ?? 1;
  }

  /// Check if has next page
  static bool hasNextPage(ProductResponse response) {
    final currentPage = response.meta?.currentPage ?? 1;
    final lastPage = response.meta?.lastPage ?? 1;
    return currentPage < lastPage;
  }

  /// Check if has previous page
  static bool hasPreviousPage(ProductResponse response) {
    final currentPage = response.meta?.currentPage ?? 1;
    return currentPage > 1;
  }
}

/// Sort options helper
class SortOptions {
  static const String priceAsc = 'price';
  static const String priceDesc = 'price';
  static const String nameAsc = 'name';
  static const String nameDesc = 'name';
  static const String ratingDesc = 'rating';
  static const String newest = 'createdAt';
  static const String popular = 'ordersCount';
}

/// Sort order helper
class SortOrder {
  static const String ascending = 'asc';
  static const String descending = 'desc';
}

/// Price range helper
class PriceRanges {
  static const int under500 = 500;
  static const int under1000 = 1000;
  static const int under1500 = 1500;
  static const int under2000 = 2000;
  static const int above2000 = 2000;

  static Map<String, int> range(int min, int max) => {'min': min, 'max': max};
}




