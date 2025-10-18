class ProductDetailResponseData {
  int? statusCode;
  bool? success;
  List<Data>? data;
  String? path;
  String? message;
  Meta? meta;

  ProductDetailResponseData(
      {this.statusCode,
      this.success,
      this.data,
      this.path,
      this.message,
      this.meta});

  ProductDetailResponseData.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    success = json['success'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
    path = json['path'];
    message = json['message'];
    meta = json['meta'] != null ? new Meta.fromJson(json['meta']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['statusCode'] = this.statusCode;
    data['success'] = this.success;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['path'] = this.path;
    data['message'] = this.message;
    if (this.meta != null) {
      data['meta'] = this.meta!.toJson();
    }
    return data;
  }
}

class Data {
  String? id;
  int? rating;
  String? comment;
  Null? createdById;
  String? approvedAt;
  String? createdAt;
  String? customerId;
  Null? deletedAt;
  String? firstName;
  String? lastName;
  String? productId;
  String? updatedAt;
  Null? title;
  bool? spam;
  bool? isPurchased;
  Customer? customer;

  Data(
      {this.id,
      this.rating,
      this.comment,
      this.createdById,
      this.approvedAt,
      this.createdAt,
      this.customerId,
      this.deletedAt,
      this.firstName,
      this.lastName,
      this.productId,
      this.updatedAt,
      this.title,
      this.spam,
      this.isPurchased,
      this.customer});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    rating = json['rating'];
    comment = json['comment'];
    createdById = json['createdById'];
    approvedAt = json['approvedAt'];
    createdAt = json['createdAt'];
    customerId = json['customerId'];
    deletedAt = json['deletedAt'];
    firstName = json['firstName'];
    lastName = json['lastName'];
    productId = json['productId'];
    updatedAt = json['updatedAt'];
    title = json['title'];
    spam = json['spam'];
    isPurchased = json['isPurchased'];
    customer = json['customer'] != null
        ? new Customer.fromJson(json['customer'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['rating'] = this.rating;
    data['comment'] = this.comment;
    data['createdById'] = this.createdById;
    data['approvedAt'] = this.approvedAt;
    data['createdAt'] = this.createdAt;
    data['customerId'] = this.customerId;
    data['deletedAt'] = this.deletedAt;
    data['firstName'] = this.firstName;
    data['lastName'] = this.lastName;
    data['productId'] = this.productId;
    data['updatedAt'] = this.updatedAt;
    data['title'] = this.title;
    data['spam'] = this.spam;
    data['isPurchased'] = this.isPurchased;
    if (this.customer != null) {
      data['customer'] = this.customer!.toJson();
    }
    return data;
  }
}

class Customer {
  String? id;
  String? firstName;
  String? lastName;
  String? email;
  String? phone;
  String? provider;
  Null? avatarUrl;
  Metadata? metadata;
  String? password;
  Null? providerId;
  Null? verifiedAt;
  String? createdAt;
  String? updatedAt;
  Null? bannedAt;
  Null? bannedById;
  Null? bannedReason;
  Null? middleName;
  Null? deletedAt;
  String? username;
  int? totalOrders;
  int? totalSpent;
  int? averageOrderValue;
  Null? lastOrderAt;

  Customer(
      {this.id,
      this.firstName,
      this.lastName,
      this.email,
      this.phone,
      this.provider,
      this.avatarUrl,
      this.metadata,
      this.password,
      this.providerId,
      this.verifiedAt,
      this.createdAt,
      this.updatedAt,
      this.bannedAt,
      this.bannedById,
      this.bannedReason,
      this.middleName,
      this.deletedAt,
      this.username,
      this.totalOrders,
      this.totalSpent,
      this.averageOrderValue,
      this.lastOrderAt});

  Customer.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    firstName = json['firstName'];
    lastName = json['lastName'];
    email = json['email'];
    phone = json['phone'];
    provider = json['provider'];
    avatarUrl = json['avatarUrl'];
    metadata = json['metadata'] != null
        ? new Metadata.fromJson(json['metadata'])
        : null;
    password = json['password'];
    providerId = json['providerId'];
    verifiedAt = json['verifiedAt'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    bannedAt = json['bannedAt'];
    bannedById = json['bannedById'];
    bannedReason = json['bannedReason'];
    middleName = json['middleName'];
    deletedAt = json['deletedAt'];
    username = json['username'];
    totalOrders = json['totalOrders'];
    totalSpent = json['totalSpent'];
    averageOrderValue = json['averageOrderValue'];
    lastOrderAt = json['lastOrderAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['firstName'] = this.firstName;
    data['lastName'] = this.lastName;
    data['email'] = this.email;
    data['phone'] = this.phone;
    data['provider'] = this.provider;
    data['avatarUrl'] = this.avatarUrl;
    if (this.metadata != null) {
      data['metadata'] = this.metadata!.toJson();
    }
    data['password'] = this.password;
    data['providerId'] = this.providerId;
    data['verifiedAt'] = this.verifiedAt;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['bannedAt'] = this.bannedAt;
    data['bannedById'] = this.bannedById;
    data['bannedReason'] = this.bannedReason;
    data['middleName'] = this.middleName;
    data['deletedAt'] = this.deletedAt;
    data['username'] = this.username;
    data['totalOrders'] = this.totalOrders;
    data['totalSpent'] = this.totalSpent;
    data['averageOrderValue'] = this.averageOrderValue;
    data['lastOrderAt'] = this.lastOrderAt;
    return data;
  }
}

class Metadata {
  String? userUrl;
  String? userLogin;
  int? customerId;
  String? displayName;
  int? wordpressId;
  String? userNicename;

  Metadata(
      {this.userUrl,
      this.userLogin,
      this.customerId,
      this.displayName,
      this.wordpressId,
      this.userNicename});

  Metadata.fromJson(Map<String, dynamic> json) {
    userUrl = json['user_url'];
    userLogin = json['user_login'];
    customerId = json['customer_id'];
    displayName = json['display_name'];
    wordpressId = json['wordpress_id'];
    userNicename = json['user_nicename'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['user_url'] = this.userUrl;
    data['user_login'] = this.userLogin;
    data['customer_id'] = this.customerId;
    data['display_name'] = this.displayName;
    data['wordpress_id'] = this.wordpressId;
    data['user_nicename'] = this.userNicename;
    return data;
  }
}

class Meta {
  int? total;
  int? items;
  int? currentPage;
  int? perPage;
  int? lastPage;

  Meta({this.total, this.items, this.currentPage, this.perPage, this.lastPage});

  Meta.fromJson(Map<String, dynamic> json) {
    total = json['total'];
    items = json['items'];
    currentPage = json['currentPage'];
    perPage = json['perPage'];
    lastPage = json['lastPage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['total'] = this.total;
    data['items'] = this.items;
    data['currentPage'] = this.currentPage;
    data['perPage'] = this.perPage;
    data['lastPage'] = this.lastPage;
    return data;
  }
}
