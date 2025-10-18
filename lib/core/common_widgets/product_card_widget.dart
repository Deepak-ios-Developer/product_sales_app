import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../model/product_model.dart';
import '../routes/app_routes.dart';

class ProductCard extends StatefulWidget {
  final Products product;

  const ProductCard({
    Key? key,
    required this.product,
  }) : super(key: key);

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _isFavorite = false;

  // Helper to parse price from string format
  double parsePrice(String? priceString) {
    if (priceString == null || priceString.isEmpty) return 0.0;
    String cleaned = priceString.replaceAll(RegExp(r'[^\d.-]'), '');
    if (cleaned.contains('-')) {
      cleaned = cleaned.split('-')[0].trim();
    }
    return double.tryParse(cleaned) ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    // Get image - use heroImage or first available image
    final String imagePath =
        product.heroImage ?? product.image250 ?? product.image135 ?? '';

    final String productName =
        product.displayName ?? product.productName ?? 'No title';
    final String brandName = product.brandName ?? '';

    // Get rating from string
    final double rating = double.tryParse(product.rating ?? '0') ?? 0.0;
    final int reviewCount = int.tryParse(product.reviews ?? '0') ?? 0;

    // Get price from currentSku
    final double price = parsePrice(product.currentSku?.listPrice);
    final double salePrice = parsePrice(product.currentSku?.salePrice);
    final double currentPrice = salePrice > 0 ? salePrice : price;

    // Calculate discount percentage
    final double discount = price > 0 && currentPrice < price
        ? ((price - currentPrice) / price * 100)
        : 0.0;
    final String saveAmount = discount > 0
        ? 'Save \$${(price - currentPrice).toStringAsFixed(2)}'
        : '';

    // Check if product is new
    final bool isNew = product.currentSku?.isNew ?? false;
    final bool isSale = product.currentSku?.salePrice != null &&
        product.currentSku!.salePrice!.isNotEmpty;
    final bool isExclusive = product.currentSku?.isSephoraExclusive ?? false;

    // Determine theme
    final bool isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.productDetail,
          arguments: product,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDarkTheme ? Theme.of(context).cardColor : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withOpacity(0.1),
              blurRadius: 8,
              spreadRadius: 2,
            )
          ],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Product Image with fixed height
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                  child: imagePath.isNotEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CachedNetworkImage(
                            imageUrl: imagePath,
                            height: 120.h,
                            width: double.infinity,
                            fit: BoxFit.contain,
                            placeholder: (context, url) => Shimmer.fromColors(
                              baseColor: isDarkTheme
                                  ? Colors.grey.shade800
                                  : Colors.grey.shade300,
                              highlightColor: isDarkTheme
                                  ? Colors.grey.shade700
                                  : Colors.grey.shade100,
                              child: Container(
                                height: 120.h,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: isDarkTheme
                                  ? Colors.grey.shade800
                                  : Colors.grey.shade200,
                              height: 120.h,
                              width: double.infinity,
                              child: const Icon(
                                Icons.broken_image,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        )
                      : Container(
                          color: isDarkTheme
                              ? Colors.grey.shade800
                              : Colors.grey.shade200,
                          height: 120.h,
                          width: double.infinity,
                          child: const Icon(Icons.image,
                              color: Colors.grey, size: 40),
                        ),
                ),

                // Product Info - Flexible content area
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 4, 10, 10),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Brand Name
                        if (brandName.isNotEmpty) ...[
                          Text(
                            brandName.toUpperCase(),
                            style: TextStyle(
                              fontSize: 9.sp,
                              fontWeight: FontWeight.w600,
                              color: isDarkTheme
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade600,
                              letterSpacing: 0.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 3),
                        ],

                        // Product Name - Limited to 2 lines
                        Flexible(
                          child: Text(
                            productName,
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color,
                              height: 1.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        SizedBox(height: 4),

                        // Rating - Compact
                        if (rating > 0)
                          Row(
                            children: [
                              Icon(Icons.star, color: Colors.amber, size: 12),
                              SizedBox(width: 2),
                              Text(
                                rating.toStringAsFixed(1),
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.color,
                                ),
                              ),
                              SizedBox(width: 3),
                              Text(
                                '($reviewCount)',
                                style: TextStyle(
                                  fontSize: 9.sp,
                                  color: isDarkTheme
                                      ? Colors.grey.shade400
                                      : Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),

                        // Spacer to push price to bottom
                        Spacer(),

                        // Price Section
                        buildPriceWidget(
                          originalPrice: price,
                          discountedPrice: currentPrice,
                          discount: discount,
                          saveAmount: saveAmount,
                          showStrikeOut: discount > 0,
                          context: context,
                        ),

                        // Color variants indicator - Compact
                        if (product.moreColors != null &&
                            product.moreColors! > 0) ...[
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.palette,
                                size: 10,
                                color: isDarkTheme
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade600,
                              ),
                              SizedBox(width: 3),
                              Text(
                                '${product.moreColors} colors',
                                style: TextStyle(
                                  fontSize: 9.sp,
                                  color: isDarkTheme
                                      ? Colors.grey.shade400
                                      : Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Top Badges
            Positioned(
              top: 8,
              left: 8,
              right: 8,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left badges (New, Sale, Exclusive)
                  Flexible(
                    child: Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: [
                        if (isNew)
                          _buildBadge('NEW', Colors.blue, isDarkTheme),
                        if (isSale && discount > 0)
                          _buildBadge('${discount.toInt()}% OFF', Colors.red,
                              isDarkTheme),
                        if (isExclusive)
                          _buildBadge('EXCLUSIVE', Colors.purple, isDarkTheme),
                      ],
                    ),
                  ),

                  // Favorite button
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        _isFavorite ? Icons.favorite : Icons.favorite_border,
                        size: 16,
                        color: _isFavorite ? Colors.red : Colors.grey.shade700,
                      ),
                      padding: EdgeInsets.all(4),
                      constraints:
                          BoxConstraints(minWidth: 32, minHeight: 32),
                      onPressed: () {
                        setState(() {
                          _isFavorite = !_isFavorite;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget to build badges
  Widget _buildBadge(String text, Color color, bool isDarkTheme) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.9),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 8.sp,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

Widget buildPriceWidget({
  required double originalPrice,
  required double discountedPrice,
  required double discount,
  required String saveAmount,
  required bool showStrikeOut,
  required BuildContext context,
}) {
  final bool isDarkTheme = Theme.of(context).brightness == Brightness.dark;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Current Price
          Text(
            '\$${discountedPrice.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: showStrikeOut
                  ? Colors.green
                  : (isDarkTheme ? Colors.white : Colors.black87),
            ),
          ),
          SizedBox(width: 4),

          // Original Price (struck through)
          if (showStrikeOut)
            Flexible(
              child: Text(
                '\$${originalPrice.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 11.sp,
                  color: isDarkTheme
                      ? Colors.grey.shade500
                      : Colors.grey.shade600,
                  decoration: TextDecoration.lineThrough,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),

      // Save amount
      if (showStrikeOut && saveAmount.isNotEmpty) ...[
        SizedBox(height: 2),
        Text(
          saveAmount,
          style: TextStyle(
            fontSize: 9.sp,
            color: Colors.green.shade700,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    ],
  );
}