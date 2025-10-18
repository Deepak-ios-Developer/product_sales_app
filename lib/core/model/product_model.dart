class ProductResponse {
  int? statusCode;
  bool? success;
  ProductData? data;
  String? path;
  String? message;
  Meta? meta;

  ProductResponse({
    this.statusCode,
    this.success,
    this.data,
    this.path,
    this.message,
    this.meta,
  });

  ProductResponse.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    success = json['success'];
    data = json['data'] != null ? ProductData.fromJson(json['data']) : null;
    path = json['path'];
    message = json['message'];
    meta = json['meta'] != null ? Meta.fromJson(json['meta']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['statusCode'] = statusCode;
    data['success'] = success;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['path'] = path;
    data['message'] = message;
    if (meta != null) {
      data['meta'] = meta!.toJson();
    }
    return data;
  }
}

class ProductData {
  List<Product>? products;
  List<Brand>? brands;
  List<AttributeFilter>? attributes;
  Map<String, int>? ratingsCounts;

  ProductData({
    this.products,
    this.brands,
    this.attributes,
    this.ratingsCounts,
  });

  ProductData.fromJson(Map<String, dynamic> json) {
    if (json['products'] != null) {
      products = <Product>[];
      json['products'].forEach((v) {
        products!.add(Product.fromJson(v));
      });
    }
    if (json['brands'] != null) {
      brands = <Brand>[];
      json['brands'].forEach((v) {
        brands!.add(Brand.fromJson(v));
      });
    }
    if (json['attributes'] != null) {
      attributes = <AttributeFilter>[];
      json['attributes'].forEach((v) {
        attributes!.add(AttributeFilter.fromJson(v));
      });
    }
    ratingsCounts = json['ratingsCounts'] != null
        ? Map<String, int>.from(json['ratingsCounts'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (products != null) {
      data['products'] = products!.map((v) => v.toJson()).toList();
    }
    if (brands != null) {
      data['brands'] = brands!.map((v) => v.toJson()).toList();
    }
    if (attributes != null) {
      data['attributes'] = attributes!.map((v) => v.toJson()).toList();
    }
    data['ratingsCounts'] = ratingsCounts;
    return data;
  }
}

class Product {
  String? id;
  String? title;
  String? subtitle;
  String? description;
  String? handle;
  String? thumbnail;
  String? status;
  String? visibility;
  String? publishedAt;
  String? createdAt;
  double? averageRating;
  int? reviewsCount;
  int? ordersCount;
  Brand? brand;
  List<ProductCategory>? productCategories;
  List<ProductCollection>? productCollections;
  List<ProductAttributeValue>? productValuesForAttribute;
  List<ProductTag>? tags;
  List<ProductVariant>? variants;
  List<ProductImage>? productImages;
  int? priceStart;
  int? priceEnd;

  Product({
    this.id,
    this.title,
    this.subtitle,
    this.description,
    this.handle,
    this.thumbnail,
    this.status,
    this.visibility,
    this.publishedAt,
    this.createdAt,
    this.averageRating,
    this.reviewsCount,
    this.ordersCount,
    this.brand,
    this.productCategories,
    this.productCollections,
    this.productValuesForAttribute,
    this.tags,
    this.variants,
    this.productImages,
    this.priceStart,
    this.priceEnd,
  });

  Product.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    subtitle = json['subtitle'];
    description = json['description'];
    handle = json['handle'];
    thumbnail = json['thumbnail'];
    status = json['status'];
    visibility = json['visibility'];
    publishedAt = json['publishedAt'];
    createdAt = json['createdAt'];
    averageRating = json['averageRating']?.toDouble();
    reviewsCount = json['reviewsCount'];
    ordersCount = json['ordersCount'];
    brand = json['brand'] != null ? Brand.fromJson(json['brand']) : null;
    if (json['productCategories'] != null) {
      productCategories = <ProductCategory>[];
      json['productCategories'].forEach((v) {
        productCategories!.add(ProductCategory.fromJson(v));
      });
    }
    if (json['productCollections'] != null) {
      productCollections = <ProductCollection>[];
      json['productCollections'].forEach((v) {
        productCollections!.add(ProductCollection.fromJson(v));
      });
    }
    if (json['productValuesForAttribute'] != null) {
      productValuesForAttribute = <ProductAttributeValue>[];
      json['productValuesForAttribute'].forEach((v) {
        productValuesForAttribute!.add(ProductAttributeValue.fromJson(v));
      });
    }
    if (json['tags'] != null) {
      tags = <ProductTag>[];
      json['tags'].forEach((v) {
        tags!.add(ProductTag.fromJson(v));
      });
    }
    if (json['variants'] != null) {
      variants = <ProductVariant>[];
      json['variants'].forEach((v) {
        variants!.add(ProductVariant.fromJson(v));
      });
    }
    if (json['productImages'] != null) {
      productImages = <ProductImage>[];
      json['productImages'].forEach((v) {
        productImages!.add(ProductImage.fromJson(v));
      });
    }
    priceStart = json['priceStart'];
    priceEnd = json['priceEnd'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['subtitle'] = subtitle;
    data['description'] = description;
    data['handle'] = handle;
    data['thumbnail'] = thumbnail;
    data['status'] = status;
    data['visibility'] = visibility;
    data['publishedAt'] = publishedAt;
    data['createdAt'] = createdAt;
    data['averageRating'] = averageRating;
    data['reviewsCount'] = reviewsCount;
    data['ordersCount'] = ordersCount;
    if (brand != null) {
      data['brand'] = brand!.toJson();
    }
    if (productCategories != null) {
      data['productCategories'] =
          productCategories!.map((v) => v.toJson()).toList();
    }
    if (productCollections != null) {
      data['productCollections'] =
          productCollections!.map((v) => v.toJson()).toList();
    }
    if (productValuesForAttribute != null) {
      data['productValuesForAttribute'] =
          productValuesForAttribute!.map((v) => v.toJson()).toList();
    }
    if (tags != null) {
      data['tags'] = tags!.map((v) => v.toJson()).toList();
    }
    if (variants != null) {
      data['variants'] = variants!.map((v) => v.toJson()).toList();
    }
    if (productImages != null) {
      data['productImages'] = productImages!.map((v) => v.toJson()).toList();
    }
    data['priceStart'] = priceStart;
    data['priceEnd'] = priceEnd;
    return data;
  }
}

class Brand {
  String? id;
  String? handle;
  String? title;
  String? name;
  int? productCount;

  Brand({
    this.id,
    this.handle,
    this.title,
    this.name,
    this.productCount,
  });

  Brand.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    handle = json['handle'];
    title = json['title'];
    name = json['name'];
    productCount = json['productCount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['handle'] = handle;
    data['title'] = title;
    data['name'] = name;
    data['productCount'] = productCount;
    return data;
  }
}

class ProductCategory {
  Category? category;

  ProductCategory({this.category});

  ProductCategory.fromJson(Map<String, dynamic> json) {
    category =
        json['category'] != null ? Category.fromJson(json['category']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (category != null) {
      data['category'] = category!.toJson();
    }
    return data;
  }
}

class Category {
  String? id;
  String? name;
  String? handle;
  Category? parent;

  Category({
    this.id,
    this.name,
    this.handle,
    this.parent,
  });

  Category.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    handle = json['handle'];
    parent = json['parent'] != null ? Category.fromJson(json['parent']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['handle'] = handle;
    if (parent != null) {
      data['parent'] = parent!.toJson();
    }
    return data;
  }
}

class ProductCollection {
  // Add fields if needed based on your API response

  ProductCollection();

  ProductCollection.fromJson(Map<String, dynamic> json) {
    // Parse fields if needed
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{};
  }
}

class ProductAttributeValue {
  String? value;
  ProductAttribute? productAttribute;
  AttributeValue? productAttributeValue;

  ProductAttributeValue({
    this.value,
    this.productAttribute,
    this.productAttributeValue,
  });

  ProductAttributeValue.fromJson(Map<String, dynamic> json) {
    value = json['value'];
    productAttribute = json['productAttribute'] != null
        ? ProductAttribute.fromJson(json['productAttribute'])
        : null;
    productAttributeValue = json['productAttributeValue'] != null
        ? AttributeValue.fromJson(json['productAttributeValue'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['value'] = value;
    if (productAttribute != null) {
      data['productAttribute'] = productAttribute!.toJson();
    }
    if (productAttributeValue != null) {
      data['productAttributeValue'] = productAttributeValue!.toJson();
    }
    return data;
  }
}

class ProductAttribute {
  String? code;
  String? title;

  ProductAttribute({this.code, this.title});

  ProductAttribute.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    title = json['title'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['code'] = code;
    data['title'] = title;
    return data;
  }
}

class AttributeValue {
  String? value;
  int? productCount;

  AttributeValue({this.value, this.productCount});

  AttributeValue.fromJson(Map<String, dynamic> json) {
    value = json['value'];
    productCount = json['productCount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['value'] = value;
    data['productCount'] = productCount;
    return data;
  }
}

class ProductTag {
  Tag? tag;

  ProductTag({this.tag});

  ProductTag.fromJson(Map<String, dynamic> json) {
    tag = json['tag'] != null ? Tag.fromJson(json['tag']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (tag != null) {
      data['tag'] = tag!.toJson();
    }
    return data;
  }
}

class Tag {
  String? id;
  String? title;
  String? slug;
  String? description;

  Tag({this.id, this.title, this.slug, this.description});

  Tag.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    slug = json['slug'];
    description = json['description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['slug'] = slug;
    data['description'] = description;
    return data;
  }
}

class ProductVariant {
  String? id;
  int? price;
  int? specialPrice;
  String? specialPriceStartDate;
  String? specialPriceEndDate;
  int? inventoryQuantity;
  List<dynamic>? prices;
  int? originalPrice;
  int? currentPrice;
  int? specialPriceActive;
  Map<String, dynamic>? salePrices;

  ProductVariant({
    this.id,
    this.price,
    this.specialPrice,
    this.specialPriceStartDate,
    this.specialPriceEndDate,
    this.inventoryQuantity,
    this.prices,
    this.originalPrice,
    this.currentPrice,
    this.specialPriceActive,
    this.salePrices,
  });

  ProductVariant.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    price = json['price'];
    specialPrice = json['specialPrice'];
    specialPriceStartDate = json['specialPriceStartDate'];
    specialPriceEndDate = json['specialPriceEndDate'];
    inventoryQuantity = json['inventoryQuantity'];
    prices = json['prices'];
    originalPrice = json['originalPrice'];
    currentPrice = json['currentPrice'];
    specialPriceActive = json['specialPriceActive'];
    salePrices = json['salePrices'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['price'] = price;
    data['specialPrice'] = specialPrice;
    data['specialPriceStartDate'] = specialPriceStartDate;
    data['specialPriceEndDate'] = specialPriceEndDate;
    data['inventoryQuantity'] = inventoryQuantity;
    data['prices'] = prices;
    data['originalPrice'] = originalPrice;
    data['currentPrice'] = currentPrice;
    data['specialPriceActive'] = specialPriceActive;
    data['salePrices'] = salePrices;
    return data;
  }
}

class ProductImage {
  String? id;
  String? image;

  ProductImage({this.id, this.image});

  ProductImage.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['image'] = image;
    return data;
  }
}

class AttributeFilter {
  String? title;
  String? code;
  List<AttributeValue>? values;

  AttributeFilter({this.title, this.code, this.values});

  AttributeFilter.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    code = json['code'];
    if (json['values'] != null) {
      values = <AttributeValue>[];
      json['values'].forEach((v) {
        values!.add(AttributeValue.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['code'] = code;
    if (values != null) {
      data['values'] = values!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Meta {
  int? total;
  int? items;
  int? perPage;
  int? currentPage;
  int? lastPage;

  Meta({
    this.total,
    this.items,
    this.perPage,
    this.currentPage,
    this.lastPage,
  });

  Meta.fromJson(Map<String, dynamic> json) {
    total = json['total'];
    items = json['items'];
    perPage = json['perPage'];
    currentPage = json['currentPage'];
    lastPage = json['lastPage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total'] = total;
    data['items'] = items;
    data['perPage'] = perPage;
    data['currentPage'] = currentPage;
    data['lastPage'] = lastPage;
    return data;
  }
}





