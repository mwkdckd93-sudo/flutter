import 'address_model.dart';

/// User Model
class UserModel {
  final String id;
  final String fullName;
  final String phone;
  final String? email;
  final String? avatarUrl;
  final String? bio;
  final String? address;
  final String? city;
  final String? province;
  final double balance;
  final AddressModel? primaryAddress;
  final List<AddressModel> addresses;
  final double walletBalance;
  final DateTime createdAt;
  final bool isVerified;
  final int totalAuctions;
  final int totalBids;
  final double rating;

  const UserModel({
    required this.id,
    required this.fullName,
    required this.phone,
    this.email,
    this.avatarUrl,
    this.bio,
    this.address,
    this.city,
    this.province,
    this.balance = 0,
    this.primaryAddress,
    this.addresses = const [],
    this.walletBalance = 0,
    required this.createdAt,
    this.isVerified = false,
    this.totalAuctions = 0,
    this.totalBids = 0,
    this.rating = 0,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Helper function to safely parse numbers from string or num
    double parseDouble(dynamic value) {
      if (value == null) return 0;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0;
      return 0;
    }
    
    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }
    
    return UserModel(
      id: json['id']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString(),
      avatarUrl: json['avatarUrl']?.toString(),
      bio: json['bio']?.toString(),
      address: json['address']?.toString(),
      city: json['city']?.toString(),
      province: json['province']?.toString(),
      balance: parseDouble(json['balance']),
      primaryAddress: json['primaryAddress'] != null
          ? AddressModel.fromJson(json['primaryAddress'])
          : null,
      addresses: (json['addresses'] as List<dynamic>?)
              ?.map((e) => AddressModel.fromJson(e))
              .toList() ??
          [],
      walletBalance: parseDouble(json['walletBalance']),
      createdAt: json['createdAt'] != null 
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      isVerified: json['isVerified'] == true || json['isVerified'] == 1,
      totalAuctions: parseInt(json['totalAuctions']),
      totalBids: parseInt(json['totalBids']),
      rating: parseDouble(json['rating']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'phone': phone,
      'email': email,
      'avatarUrl': avatarUrl,
      'bio': bio,
      'address': address,
      'city': city,
      'province': province,
      'balance': balance,
      'primaryAddress': primaryAddress?.toJson(),
      'addresses': addresses.map((e) => e.toJson()).toList(),
      'walletBalance': walletBalance,
      'createdAt': createdAt.toIso8601String(),
      'isVerified': isVerified,
      'totalAuctions': totalAuctions,
      'totalBids': totalBids,
      'rating': rating,
    };
  }

  UserModel copyWith({
    String? id,
    String? fullName,
    String? phone,
    String? email,
    String? avatarUrl,
    String? bio,
    String? address,
    String? city,
    String? province,
    double? balance,
    AddressModel? primaryAddress,
    List<AddressModel>? addresses,
    double? walletBalance,
    DateTime? createdAt,
    bool? isVerified,
    int? totalAuctions,
    int? totalBids,
    double? rating,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      address: address ?? this.address,
      city: city ?? this.city,
      province: province ?? this.province,
      balance: balance ?? this.balance,
      primaryAddress: primaryAddress ?? this.primaryAddress,
      addresses: addresses ?? this.addresses,
      walletBalance: walletBalance ?? this.walletBalance,
      createdAt: createdAt ?? this.createdAt,
      isVerified: isVerified ?? this.isVerified,
      totalAuctions: totalAuctions ?? this.totalAuctions,
      totalBids: totalBids ?? this.totalBids,
      rating: rating ?? this.rating,
    );
  }

  String get firstName => fullName.split(' ').first;
}
