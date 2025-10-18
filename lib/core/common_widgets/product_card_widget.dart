import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:product_sale_app/core/themes/app_theme.dart';
import 'package:shimmer/shimmer.dart';
import '../model/product_model.dart';
import '../routes/app_routes.dart';

class ProductCard extends StatefulWidget {
  final Product product;

  const ProductCard({
    Key? key,
    required this.product,
  }) : super(key: key);

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _isFavorite = false;

  static const String _imageBaseUrl =
      'https://beautybarn.blr1.cdn.digitaloceanspaces.com/';

  String getImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return '';
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return imagePath;
    }
    return '$_imageBaseUrl$imagePath';
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    String imagePath = '';
    if (product.thumbnail != null && product.thumbnail!.isNotEmpty) {
      imagePath = getImageUrl(product.thumbnail);
    } else if (product.productImages != null &&
        product.productImages!.isNotEmpty) {
      imagePath = getImageUrl(product.productImages!.first.image);
    }

    final String productName = product.title ?? 'No title';
    final String brandName = product.brand?.title ?? '';

    final double rating = product.averageRating ?? 0.0;
    final int reviewCount = product.reviewsCount ?? 0;

    final int price = product.variants?.first.originalPrice ?? 0;
    final int currentPrice = product.variants?.first.currentPrice ?? 0;
    final int specialPrice = product.variants?.first.specialPrice ?? 0;

    final double discount = price > 0 && currentPrice < price
        ? ((price - currentPrice) / price * 100)
        : 0.0;

    bool isNew = false;
    if (product.createdAt != null) {
      try {
        final createdDate = DateTime.parse(product.createdAt!);
        final daysSinceCreation = DateTime.now().difference(createdDate).inDays;
        isNew = daysSinceCreation < 30;
      } catch (e) {
        isNew = false;
      }
    }

    final bool isSale = specialPrice > 0 && specialPrice < price;

    final bool isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.productDetail,
          arguments: product.id,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDarkTheme ? Theme.of(context).cardColor : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                  child: imagePath.isNotEmpty
                      ? Container(
                          color: Colors.white,
                          padding: const EdgeInsets.all(10.0),
                          height: 150.h,
                          child: CachedNetworkImage(
                            imageUrl: imagePath,
                            width: double.infinity,
                            fit: BoxFit.contain,
                            placeholder: (context, url) => Shimmer.fromColors(
                              baseColor: Colors.grey.shade200,
                              highlightColor: Colors.grey.shade100,
                              child: Container(
                                width: double.infinity,
                                color: Colors.white,
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: Colors.grey.shade100,
                              width: double.infinity,
                              child: const Icon(
                                Icons.broken_image,
                                color: Colors.grey,
                                size: 40,
                              ),
                            ),
                          ),
                        )
                      : Container(
                          color: Colors.grey.shade100,
                          height: 180.h,
                          width: double.infinity,
                          child: const Icon(Icons.image,
                              color: Colors.grey, size: 40),
                        ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 5, 10, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (brandName.isNotEmpty)
                          Text(
                            brandName.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade600,
                              letterSpacing: 0.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        SizedBox(height: 7),
                        Text(
                          productName,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                            color: isDarkTheme ? Colors.white : Colors.black87,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 7),
                        if (rating > 0)
                          Row(
                            children: [
                              ...List.generate(
                                5,
                                (index) => Icon(
                                  index < rating.floor()
                                      ? Icons.star
                                      : (index < rating
                                          ? Icons.star_half
                                          : Icons.star_border),
                                  color: Colors.amber.shade700,
                                  size: 13,
                                ),
                              ),
                              SizedBox(width: 4),
                              Text(
                                rating.toStringAsFixed(1),
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w600,
                                  color: isDarkTheme
                                      ? Colors.white70
                                      : Colors.black87,
                                ),
                              ),
                              SizedBox(width: 2),
                              Text(
                                '($reviewCount)',
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '₹${currentPrice.toString()}',
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.bold,
                                  color: isDarkTheme
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                              ),
                              SizedBox(width: 6),
                              if (discount > 0)
                                Text(
                                  '₹${price.toString()}',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.grey.shade600,
                                    decoration: TextDecoration.lineThrough,
                                    decorationColor: Colors.grey.shade600,
                                  ),
                                ),
                              if (discount > 0) ...[
                                SizedBox(width: 6),
                                Text(
                                  '${discount.toInt()}% OFF',
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.green.shade700,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        SizedBox(height: 6),
                        SizedBox(
                          width: double.infinity,
                          height: 34,
                          child: OutlinedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('$productName added to bag'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: isDarkTheme
                                    ? Colors.white70
                                    : AppTheme.cartButtonColour,
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              padding: EdgeInsets.zero,
                            ),
                            child: Text(
                              'Add to Bag',
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: isDarkTheme
                                    ? Colors.white70
                                    : AppTheme.cartButtonColour,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              top: 8,
              left: 8,
              right: 8,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      if (discount > 0)
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.yellow.shade600,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'SAVE ${discount.toInt()}% OFF',
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      if (isNew && discount == 0)
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.shade600,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'NEW',
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      _isFavorite ? Icons.favorite : Icons.favorite_border,
                      size: 18,
                      color: _isFavorite ? Colors.red : Colors.grey.shade700,
                    ),
                    padding: EdgeInsets.all(6),
                    constraints: BoxConstraints(minWidth: 36, minHeight: 36),
                    onPressed: () {
                      setState(() {
                        _isFavorite = !_isFavorite;
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}