import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:product_sale_app/core/model/product_detail_model.dart';
import 'package:product_sale_app/core/service/product_service.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../common_widgets/share_pdf_button.dart';
import '../constants/common_strings.dart';
import '../model/product_model.dart';
import '../themes/app_theme.dart';
import 'package:carousel_slider/carousel_slider.dart';

class ProductDetailScreen extends StatefulWidget {
  final String? productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen>
    with SingleTickerProviderStateMixin {
  int _activeIndex = 0;
  int _quantity = 1;
  bool _isFavorite = false;
  late TabController _tabController;

  bool _isLoadingProduct = true;
  bool _isLoadingReviews = true;
  Product? _product;
  List<Data> _reviews = [];
  int _totalReviews = 0;
  int _currentPage = 1;
  String? _errorMessage;

  static const String _imageBaseUrl =
      'https://beautybarn.blr1.cdn.digitaloceanspaces.com/';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _fetchProductDetails();
    _fetchProductReviews();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchProductDetails() async {
    setState(() {
      _isLoadingProduct = true;
      _errorMessage = null;
    });

    try {
      final productId = widget.productId;

      final productResponse = await ProductService.fetchProducts(
        productId: productId,
        limit: 50,
      );

      if (productResponse.data?.products != null &&
          productResponse.data!.products!.isNotEmpty) {
        Product? matchedProduct;

        for (var product in productResponse.data!.products!) {
          if (product.id == productId) {
            matchedProduct = product;
            break;
          }
        }

        if (matchedProduct != null) {
          setState(() {
            _product = matchedProduct;
            _isLoadingProduct = false;
          });
        } else {
          setState(() {
            _errorMessage = 'Product with ID "$productId" not found';
            _isLoadingProduct = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = 'No products found in response';
          _isLoadingProduct = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching product: $e';
        _isLoadingProduct = false;
      });
    }
  }

  Future<void> _fetchProductReviews() async {
    setState(() {
      _isLoadingReviews = true;
    });

    try {
      final reviewResponse = await ProductService.fetchProductReviews(
        productId: widget.productId ?? '',
        page: _currentPage,
        limit: 10,
      );

      setState(() {
        _reviews = reviewResponse.data ?? [];
        _totalReviews = reviewResponse.meta?.total ?? 0;
        _isLoadingReviews = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingReviews = false;
      });
    }
  }

  String _getImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return '';
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return imagePath;
    }
    return '$_imageBaseUrl$imagePath';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkTheme = theme.brightness == Brightness.dark;

    if (_isLoadingProduct) {
      return Scaffold(
        backgroundColor: isDarkTheme ? Colors.black : Colors.white,
        body: Center(
          child: CircularProgressIndicator(
            color: AppTheme.secondaryColor,
          ),
        ),
      );
    }

    if (_errorMessage != null || _product == null) {
      return Scaffold(
        backgroundColor: isDarkTheme ? Colors.black : Colors.white,
        appBar: AppBar(
          backgroundColor: isDarkTheme ? Colors.black : Colors.white,
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text(
                _errorMessage ?? 'Product not found',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: isDarkTheme ? Colors.white70 : Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _fetchProductDetails,
                child: Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final product = _product!;

    final variant = product.variants?.first;
    final int originalPrice = variant?.originalPrice ?? 0;
    final int currentPrice = variant?.currentPrice ?? 0;
    final int specialPrice = variant?.specialPrice ?? 0;

    final double discount = originalPrice > 0 && currentPrice < originalPrice
        ? ((originalPrice - currentPrice) / originalPrice * 100)
        : 0.0;

    final List<String> images = [
      if (product.thumbnail?.isNotEmpty ?? false)
        _getImageUrl(product.thumbnail),
      if (product.productImages != null)
        ...product.productImages!
            .map((img) => _getImageUrl(img.image))
            .where((url) => url.isNotEmpty),
    ].toSet().toList();

    final String thumbnailUrl = images.isNotEmpty ? images.first : '';

    final double rating = product.averageRating ?? 0.0;
    final int reviewsCount =
        _totalReviews > 0 ? _totalReviews : (product.reviewsCount ?? 0);

    final String brandName = product.brand?.title ?? product.brand?.name ?? '';

    bool isNew = false;
    if (product.createdAt != null) {
      try {
        final createdDate = DateTime.parse(product.createdAt!);
        isNew = DateTime.now().difference(createdDate).inDays < 30;
      } catch (e) {
        isNew = false;
      }
    }

    final bool isSale = specialPrice > 0 && specialPrice < originalPrice;

    final int inventoryQty = variant?.inventoryQuantity ?? 0;
    final bool inStock = inventoryQty > 0;

    return Scaffold(
      backgroundColor: isDarkTheme ? Colors.black : Colors.white,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(product, thumbnailUrl, isDarkTheme),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImageCarousel(images, isDarkTheme, theme),
                _buildProductInfo(product, brandName, rating, reviewsCount,
                    isNew, isSale, isDarkTheme),
                _buildPriceSection(
                    originalPrice, currentPrice, discount, isDarkTheme),
                _buildRewardsSection(currentPrice, isDarkTheme),
                _buildQuantityAndAddToBag(inStock, isDarkTheme),
                _buildTabSection(product, isDarkTheme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(Product product, String thumbnailUrl, bool isDarkTheme) {
    return SliverAppBar(
      backgroundColor: isDarkTheme ? Colors.black : Colors.white,
      surfaceTintColor: Colors.transparent,
      pinned: true,
      floating: false,
      expandedHeight: 60,
      leading: Container(
        margin: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDarkTheme ? Colors.grey[850] : Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
            ),
          ],
        ),
        child: IconButton(
          icon: Icon(Icons.arrow_back,
              color: isDarkTheme ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      actions: [
        Container(
          margin: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDarkTheme ? Colors.grey[850] : Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite
                  ? Colors.red
                  : (isDarkTheme ? Colors.white : Colors.black),
            ),
            onPressed: () {
              setState(() => _isFavorite = !_isFavorite);
            },
          ),
        ),
        Container(
          margin: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDarkTheme ? Colors.grey[850] : Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
              ),
            ],
          ),
          child: ShareAsPDFButton(
            title: product.title ?? AppStrings.title,
            description: product.description ?? AppStrings.description,
            imageUrl: thumbnailUrl,
            discountedPrice:
                product.variants?.first.currentPrice?.toDouble() ?? 0.0,
            brandName: product.brand?.title,
            productId: product.id,
            skuId: product.variants?.first.id,
            originalPrice: product.variants?.first.originalPrice?.toDouble(),
            rating: product.averageRating,
            reviewsCount: product.reviewsCount,
            isNew: product.createdAt != null,
            pickupEligible: product.variants?.first.inventoryQuantity != null &&
                product.variants!.first.inventoryQuantity! > 0,
          ),
        ),
      ],
    );
  }

  Widget _buildImageCarousel(
      List<String> images, bool isDarkTheme, ThemeData theme) {
    return Container(
      color: isDarkTheme ? Colors.grey[900] : Colors.grey[50],
      child: Column(
        children: [
          if (images.isNotEmpty)
            Stack(
              children: [
                CarouselSlider.builder(
                  itemCount: images.length,
                  itemBuilder: (context, index, realIndex) {
                    final imageUrl = images[index];
                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.contain,
                          placeholder: (_, __) => Shimmer.fromColors(
                            baseColor: isDarkTheme
                                ? Colors.grey.shade800
                                : Colors.grey.shade300,
                            highlightColor: isDarkTheme
                                ? Colors.grey.shade700
                                : Colors.grey.shade100,
                            child: Container(
                              height: 350.h,
                              color: isDarkTheme
                                  ? Colors.grey.shade900
                                  : Colors.white,
                            ),
                          ),
                          errorWidget: (_, __, ___) => Icon(
                            Icons.broken_image,
                            color: theme.colorScheme.error,
                          ),
                        ),
                      ),
                    );
                  },
                  options: CarouselOptions(
                    height: 350.h,
                    viewportFraction: 1,
                    enableInfiniteScroll: images.length > 1,
                    onPageChanged: (index, reason) {
                      setState(() => _activeIndex = index);
                    },
                  ),
                ),
              ],
            )
          else
            Container(
              height: 350.h,
              margin: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color:
                    isDarkTheme ? Colors.grey.shade800 : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(
                  Icons.image,
                  size: 100,
                  color:
                      isDarkTheme ? Colors.grey.shade600 : Colors.grey.shade400,
                ),
              ),
            ),
          if (images.isNotEmpty && images.length > 1) ...[
            SizedBox(height: 16),
            AnimatedSmoothIndicator(
              activeIndex: _activeIndex,
              count: images.length,
              effect: ExpandingDotsEffect(
                dotWidth: 8,
                dotHeight: 8,
                activeDotColor: AppTheme.secondaryColor,
                dotColor:
                    isDarkTheme ? Colors.grey.shade700 : Colors.grey.shade400,
              ),
            ),
            SizedBox(height: 16),
          ],
          if (images.length > 1)
            Container(
              height: 80,
              padding: EdgeInsets.symmetric(vertical: 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16),
                itemCount: images.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() => _activeIndex = index);
                    },
                    child: Container(
                      width: 60,
                      margin: EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _activeIndex == index
                              ? AppTheme.secondaryColor
                              : Colors.transparent,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: CachedNetworkImage(
                          imageUrl: images[index],
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProductInfo(Product product, String brandName, double rating,
      int reviewsCount, bool isNew, bool isSale, bool isDarkTheme) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (brandName.isNotEmpty)
            Text(
              brandName.toUpperCase(),
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey[600],
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
          SizedBox(height: 8),
          Text(
            product.title ?? AppStrings.title,
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: isDarkTheme ? Colors.white : Colors.black,
              height: 1.3,
            ),
          ),
          if (product.subtitle?.isNotEmpty ?? false) ...[
            SizedBox(height: 4),
            Text(
              product.subtitle!,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
            ),
          ],
          SizedBox(height: 12),
          if (rating > 0)
            Row(
              children: [
                ...List.generate(5, (index) {
                  return Icon(
                    index < rating.floor()
                        ? Icons.star
                        : (index < rating
                            ? Icons.star_half
                            : Icons.star_border),
                    color: Colors.amber,
                    size: 18,
                  );
                }),
                SizedBox(width: 8),
                Text(
                  '${rating.toStringAsFixed(1)} / 5.0',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: isDarkTheme ? Colors.white : Colors.black87,
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  '($reviewsCount reviews)',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (isNew) _buildTag('NEW', Colors.green, isDarkTheme),
              if (product.tags != null && product.tags!.isNotEmpty)
                ...product.tags!.take(3).map((tagObj) {
                  final tag = tagObj.tag;
                  if (tag?.title != null) {
                    return _buildTag(tag!.title!, Colors.green, isDarkTheme);
                  }
                  return SizedBox.shrink();
                }).toList(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String label, Color color, bool isDarkTheme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.check_circle, size: 14, color: color),
        SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceSection(
      int originalPrice, int currentPrice, double discount, bool isDarkTheme) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDarkTheme ? Colors.grey[900] : Colors.grey[50],
      ),
      child: Row(
        children: [
          Text(
            '₹$currentPrice',
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.bold,
              color: isDarkTheme ? Colors.white : Colors.black,
            ),
          ),
          SizedBox(width: 12),
          if (discount > 0) ...[
            Text(
              '₹$originalPrice',
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey[600],
                decoration: TextDecoration.lineThrough,
              ),
            ),
            SizedBox(width: 12),
            Text(
              '${discount.toStringAsFixed(0)}% OFF',
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRewardsSection(int price, bool isDarkTheme) {
    final points = (price * 0.1).toInt();
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:
            isDarkTheme ? Colors.pink[900]?.withOpacity(0.3) : Colors.pink[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDarkTheme ? Colors.pink[700]! : Colors.pink[200]!,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.card_giftcard, color: Colors.pink[700], size: 20),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Earn $points Reward Points from this Purchase',
              style: TextStyle(
                fontSize: 13.sp,
                color: isDarkTheme ? Colors.pink[200] : Colors.pink[900],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityAndAddToBag(bool inStock, bool isDarkTheme) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                  color: isDarkTheme ? Colors.grey[700]! : Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.remove, size: 18),
                  onPressed: () {
                    if (_quantity > 1) {
                      setState(() => _quantity--);
                    }
                  },
                ),
                Container(
                  width: 40,
                  alignment: Alignment.center,
                  child: Text(
                    '$_quantity',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add, size: 18),
                  color: AppTheme.cartButtonColour,
                  onPressed: () {
                    setState(() => _quantity++);
                  },
                ),
              ],
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: inStock
                  ? () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('$_quantity item(s) added to bag'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    inStock ? AppTheme.cartButtonColour : Colors.grey,
                disabledBackgroundColor: Colors.grey,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                inStock ? AppStrings.addToBag : 'Out of Stock',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSection(Product product, bool isDarkTheme) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isDarkTheme ? Colors.grey[800]! : Colors.grey[300]!,
              ),
            ),
          ),
          child: TabBar(
            tabAlignment: TabAlignment.start,
            controller: _tabController,
            isScrollable: true,
            labelColor: isDarkTheme ? Colors.white : Colors.black,
            unselectedLabelColor: Colors.grey[600],
            indicatorColor: AppTheme.secondaryColor,
            indicatorWeight: 3,
            labelStyle: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
            tabs: [
              Tab(text: 'Description'),
              Tab(text: 'Details'),
              Tab(text: 'Categories'),
              Tab(text: 'Reviews ($_totalReviews)'),
              Tab(text: 'Shipping'),
            ],
          ),
        ),
        Container(
          height: 400.h,
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildDescriptionTab(product, isDarkTheme),
              _buildDetailsTab(product, isDarkTheme),
              _buildCategoriesTab(product, isDarkTheme),
              _buildReviewsTab(isDarkTheme),
              _buildShippingTab(isDarkTheme),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionTab(Product product, bool isDarkTheme) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (product.description?.isNotEmpty ?? false)
            Text(
              product.description!.replaceAll(RegExp(r'<[^>]*>'), ''),
              style: TextStyle(
                fontSize: 14.sp,
                color: isDarkTheme ? Colors.white70 : Colors.black87,
                height: 1.6,
              ),
            )
          else
            Text(
              'No description available.',
              style: TextStyle(
                fontSize: 14.sp,
                color: isDarkTheme ? Colors.white70 : Colors.black87,
                height: 1.6,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailsTab(Product product, bool isDarkTheme) {
    final variant = product.variants?.first;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (product.brand?.title != null) ...[
            _buildDetailRow('Brand', product.brand!.title!, isDarkTheme),
            Divider(height: 24),
          ],
          if (product.id != null) ...[
            _buildDetailRow('Product ID', product.id!, isDarkTheme),
            Divider(height: 24),
          ],
          if (variant?.id != null) ...[
            _buildDetailRow('Variant ID', variant!.id!, isDarkTheme),
            Divider(height: 24),
          ],
          if (variant?.inventoryQuantity != null) ...[
            _buildDetailRow(
                'Stock', '${variant!.inventoryQuantity!} units', isDarkTheme),
            Divider(height: 24),
          ],
          if (product.status != null) ...[
            _buildDetailRow('Status', product.status!, isDarkTheme),
            Divider(height: 24),
          ],
          if (product.publishedAt != null) ...[
            _buildDetailRow(
              'Published',
              DateTime.parse(product.publishedAt!).toString().split(' ')[0],
              isDarkTheme,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCategoriesTab(Product product, bool isDarkTheme) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (product.productCategories != null &&
              product.productCategories!.isNotEmpty) ...[
            Text(
              'Product Categories:',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: isDarkTheme ? Colors.white : Colors.black87,
              ),
            ),
            SizedBox(height: 12),
            ...product.productCategories!.map((categoryObj) {
              final category = categoryObj.category;
              if (category?.name != null) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Icon(Icons.label,
                          size: 16, color: AppTheme.secondaryColor),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          category!.name!,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color:
                                isDarkTheme ? Colors.white70 : Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return SizedBox.shrink();
            }).toList(),
          ] else
            Text(
              'No categories available.',
              style: TextStyle(
                fontSize: 14.sp,
                color: isDarkTheme ? Colors.white70 : Colors.black87,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildReviewsTab(bool isDarkTheme) {
    if (_isLoadingReviews) {
      return Center(
        child: CircularProgressIndicator(
          color: AppTheme.secondaryColor,
        ),
      );
    }

    if (_reviews.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.rate_review_outlined, size: 48, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              'No reviews yet',
              style: TextStyle(
                fontSize: 16.sp,
                color: isDarkTheme ? Colors.white70 : Colors.black87,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Be the first to review this product',
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.all(16),
      itemCount: _reviews.length,
      separatorBuilder: (context, index) => Divider(height: 24),
      itemBuilder: (context, index) {
        final review = _reviews[index];
        final customerName =
            '${review.firstName ?? ''} ${review.lastName ?? ''}'.trim();
        final rating = review.rating ?? 0;
        final comment = review.comment ?? '';
        final createdAt =
            review.createdAt != null ? DateTime.parse(review.createdAt!) : null;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppTheme.secondaryColor,
                  child: Text(
                    customerName.isNotEmpty? customerName[0].toUpperCase()
                        : 'U',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customerName.isNotEmpty ? customerName : 'Anonymous',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: isDarkTheme ? Colors.white : Colors.black87,
                        ),
                      ),
                      if (createdAt != null)
                        Text(
                          '${createdAt.day}/${createdAt.month}/${createdAt.year}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: List.generate(5, (starIndex) {
                return Icon(
                  starIndex < rating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 16,
                );
              }),
            ),
            if (comment.isNotEmpty) ...[
              SizedBox(height: 8),
              Text(
                comment,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: isDarkTheme ? Colors.white70 : Colors.black87,
                  height: 1.4,
                ),
              ),
            ],
            if (review.isPurchased == true) ...[
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.green),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified, size: 14, color: Colors.green),
                    SizedBox(width: 4),
                    Text(
                      'Verified Purchase',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, bool isDarkTheme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: isDarkTheme ? Colors.white : Colors.black87,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              color: isDarkTheme ? Colors.white70 : Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShippingTab(bool isDarkTheme) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildShippingInfo(AppStrings.standardDelivery,
              AppStrings.standardDeliveryTime, isDarkTheme),
          SizedBox(height: 12),
          _buildShippingInfo(AppStrings.expressDelivery,
              AppStrings.expressDeliveryTime, isDarkTheme),
          SizedBox(height: 12),
          _buildShippingInfo(
              AppStrings.returnPolicy, AppStrings.returnPolicy, isDarkTheme),
        ],
      ),
    );
  }

  Widget _buildShippingInfo(String title, String subtitle, bool isDarkTheme) {
    return Row(
      children: [
        Icon(Icons.local_shipping, color: AppTheme.secondaryColor, size: 20),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: isDarkTheme ? Colors.white : Colors.black87,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}