import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../common_widgets/share_pdf_button.dart';
import '../constants/common_strings.dart';
import '../model/product_model.dart';
import '../themes/app_theme.dart';
import 'package:carousel_slider/carousel_slider.dart';

class ProductDetailScreen extends StatefulWidget {
  final Products product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen>
    with SingleTickerProviderStateMixin {
  int _activeIndex = 0;
  int _quantity = 1;
  bool _isFavorite = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Helper method to parse price from string format like "$26.00" or "$8.00 - $16.00"
  double _parsePrice(String? priceString) {
    if (priceString == null || priceString.isEmpty) return 0.0;

    // Remove currency symbols and extract first number
    String cleaned = priceString.replaceAll(RegExp(r'[^\d.-]'), '');
    if (cleaned.contains('-')) {
      cleaned = cleaned.split('-')[0].trim();
    }
    return double.tryParse(cleaned) ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final theme = Theme.of(context);
    final isDarkTheme = theme.brightness == Brightness.dark;

    // Get price from currentSku
    final double price = _parsePrice(product.currentSku?.listPrice);
    final double salePrice = _parsePrice(product.currentSku?.salePrice);
    final double currentPrice = salePrice > 0 ? salePrice : price;

    final double discount = price > 0 && currentPrice < price
        ? ((price - currentPrice) / price * 100)
        : 0.0;

    // Get images - create list with available images
    final List<String> images = [
      if (product.heroImage?.isNotEmpty ?? false) product.heroImage!,
      if (product.image450?.isNotEmpty ?? false) product.image450!,
      if (product.image250?.isNotEmpty ?? false) product.image250!,
      if (product.image135?.isNotEmpty ?? false) product.image135!,
      if (product.altImage?.isNotEmpty ?? false) product.altImage!,
    ].toSet().toList(); // Remove duplicates

    final String thumbnailUrl = product.heroImage ?? '';

    // Get rating and reviews
    final double rating = double.tryParse(product.rating ?? '0') ?? 0.0;
    final int reviewsCount = int.tryParse(product.reviews ?? '0') ?? 0;

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
                _buildProductInfo(product, rating, reviewsCount, isDarkTheme),
                _buildPriceSection(price, currentPrice, discount, isDarkTheme),
                _buildRewardsSection(currentPrice, isDarkTheme),
                _buildQuantityAndAddToBag(isDarkTheme),
                _buildTabSection(product, isDarkTheme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(Products product, String thumbnailUrl, bool isDarkTheme) {
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
            title: product.displayName ?? AppStrings.title,
            description:
                product.currentSku?.imageAltText ?? AppStrings.description,
            imageUrl: thumbnailUrl,
            discountedPrice: _parsePrice(
                product.currentSku?.salePrice ?? product.currentSku?.listPrice),
            // Additional optional parameters for comprehensive PDF
            brandName: product.brandName,
            productId: product.productId,
            skuId: product.currentSku?.skuId,
            originalPrice: _parsePrice(product.currentSku?.listPrice),
            rating: double.tryParse(product.rating ?? '0'),
            reviewsCount: int.tryParse(product.reviews ?? '0'),
            isNew: product.currentSku?.isNew,
            isSephoraExclusive: product.currentSku?.isSephoraExclusive,
            isLimitedEdition: product.currentSku?.isLimitedEdition,
            moreColors: product.moreColors,
            pickupEligible: product.pickupEligible,
            sameDayEligible: product.sameDayEligible,
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
          // Thumbnail strip
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

  Widget _buildProductInfo(
      Products product, double rating, int reviewsCount, bool isDarkTheme) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Brand Name
          if (product.brandName?.isNotEmpty ?? false)
            Text(
              product.brandName!,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          SizedBox(height: 8),

          // Product Title
          Text(
            product.displayName ?? product.productName ?? AppStrings.title,
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: isDarkTheme ? Colors.white : Colors.black,
            ),
          ),
          SizedBox(height: 12),

          // Rating and Reviews
          if (rating > 0)
            Row(
              children: [
                ...List.generate(5, (index) {
                  return Icon(
                    index < rating.floor() ? Icons.star : Icons.star_border,
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
                  '$reviewsCount reviews',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          SizedBox(height: 12),

          // Tags/Badges
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (product.currentSku?.isNew ?? false)
                _buildTag('New', isDarkTheme),
              if (product.currentSku?.isSephoraExclusive ?? false)
                _buildTag('Sephora Exclusive', isDarkTheme),
              if (product.currentSku?.isLimitedEdition ?? false)
                _buildTag('Limited Edition', isDarkTheme),
              if (product.moreColors != null && product.moreColors! > 0)
                _buildTag('${product.moreColors} Colors', isDarkTheme),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String label, bool isDarkTheme) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDarkTheme ? Colors.grey[850] : Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDarkTheme ? Colors.grey[700]! : Colors.grey[300]!,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, size: 14, color: Colors.green),
          SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: isDarkTheme ? Colors.white70 : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSection(
      double price, double currentPrice, double discount, bool isDarkTheme) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDarkTheme ? Colors.grey[900] : Colors.grey[50],
      ),
      child: Row(
        children: [
          Text(
            '\$${currentPrice.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.bold,
              color: isDarkTheme ? Colors.white : Colors.black,
            ),
          ),
          SizedBox(width: 12),
          if (discount > 0) ...[
            Text(
              '\$${price.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey[600],
                decoration: TextDecoration.lineThrough,
              ),
            ),
            SizedBox(width: 12),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${discount.toStringAsFixed(0)}% OFF',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRewardsSection(double price, bool isDarkTheme) {
    final points = (price * 0.1).toInt();
    return Container(
      margin: EdgeInsets.all(16),
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
              'Get $points Rewards Points from this Purchase',
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

  Widget _buildQuantityAndAddToBag(bool isDarkTheme) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          // Quantity selector
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
                  onPressed: () {
                    setState(() => _quantity++);
                  },
                ),
              ],
            ),
          ),
          SizedBox(width: 12),

          // Add to bag button
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                // generateAndSavePDF(context, widget.product);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF8B4049),
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                AppStrings.addToBag,
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

  Widget _buildTabSection(Products product, bool isDarkTheme) {
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
              Tab(text: 'Product Description'),
              Tab(text: 'Details'),
              Tab(text: 'How to Use'),
              Tab(text: 'Shipping & Handling'),
            ],
          ),
        ),
        Container(
          height: 300.h,
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildDescriptionTab(product, isDarkTheme),
              _buildDetailsTab(product, isDarkTheme),
              _buildHowToUseTab(isDarkTheme),
              _buildShippingTab(isDarkTheme),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionTab(Products product, bool isDarkTheme) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (product.currentSku?.imageAltText?.isNotEmpty ?? false)
            Text(
              product.currentSku!.imageAltText!,
              style: TextStyle(
                fontSize: 14.sp,
                color: isDarkTheme ? Colors.white70 : Colors.black87,
                height: 1.6,
              ),
            )
          else
            Text(
              AppStrings.description,
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

  Widget _buildDetailsTab(Products product, bool isDarkTheme) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (product.brandName != null) ...[
            _buildDetailRow('Brand', product.brandName!, isDarkTheme),
            Divider(height: 24),
          ],
          if (product.productId != null) ...[
            _buildDetailRow('Product ID', product.productId!, isDarkTheme),
            Divider(height: 24),
          ],
          if (product.currentSku?.skuId != null) ...[
            _buildDetailRow('SKU', product.currentSku!.skuId!, isDarkTheme),
            Divider(height: 24),
          ],
          if (product.pickupEligible != null) ...[
            _buildDetailRow(
                'Store Pickup',
                product.pickupEligible! ? 'Available' : 'Not Available',
                isDarkTheme),
            Divider(height: 24),
          ],
          if (product.sameDayEligible != null) ...[
            _buildDetailRow(
                'Same Day Delivery',
                product.sameDayEligible! ? 'Available' : 'Not Available',
                isDarkTheme),
          ],
        ],
      ),
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

  Widget _buildHowToUseTab(bool isDarkTheme) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Text(
        'Apply the product as directed. For best results, use regularly as part of your beauty routine.',
        style: TextStyle(
          fontSize: 14.sp,
          color: isDarkTheme ? Colors.white70 : Colors.black87,
          height: 1.6,
        ),
      ),
    );
  }

  Widget _buildShippingTab(bool isDarkTheme) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildShippingInfo(
              AppStrings.standardDelivery, AppStrings.standardDeliveryTime, isDarkTheme),
          SizedBox(height: 12),
          _buildShippingInfo(
              AppStrings.expressDelivery, AppStrings.expressDeliveryTime, isDarkTheme),
          SizedBox(height: 12),
          _buildShippingInfo(AppStrings.returnPolicy, AppStrings.returnPolicy, isDarkTheme),
        ],
      ),
    );
  }

  Widget _buildShippingInfo(String title, String subtitle, bool isDarkTheme) {
    return Row(
      children: [
        Icon(Icons.local_shipping, color: AppTheme.secondaryColor, size: 20),
        SizedBox(width: 12),
        Column(
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
      ],
    );
  }
}
