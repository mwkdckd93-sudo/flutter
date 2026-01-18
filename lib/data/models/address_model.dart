/// User Address Model
class AddressModel {
  final String? id;
  final String? label;
  final String? city;
  final String? area;
  final String? street;
  final String? building;
  final String? notes;
  final bool isPrimary;
  
  // Legacy fields for compatibility
  final String? province;
  final String? landmark;
  final double? latitude;
  final double? longitude;
  final String? fullAddress;
  final bool isDefault;

  const AddressModel({
    this.id,
    this.label,
    this.city,
    this.area,
    this.street,
    this.building,
    this.notes,
    this.isPrimary = false,
    this.province,
    this.landmark,
    this.latitude,
    this.longitude,
    this.fullAddress,
    this.isDefault = false,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    // Helper to convert int/bool to bool
    bool toBool(dynamic value) {
      if (value == null) return false;
      if (value is bool) return value;
      if (value is int) return value == 1;
      if (value is String) return value == '1' || value.toLowerCase() == 'true';
      return false;
    }

    return AddressModel(
      id: json['id']?.toString(),
      label: json['label'] as String?,
      city: json['city'] as String?,
      area: json['area'] as String?,
      street: json['street'] as String?,
      building: json['building'] as String?,
      notes: json['notes'] as String?,
      isPrimary: toBool(json['isPrimary'] ?? json['is_primary']),
      province: json['province'] as String?,
      landmark: json['landmark'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      fullAddress: json['fullAddress'] as String?,
      isDefault: toBool(json['isDefault'] ?? json['is_default']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (label != null) 'label': label,
      if (city != null) 'city': city,
      if (area != null) 'area': area,
      if (street != null) 'street': street,
      if (building != null) 'building': building,
      if (notes != null) 'notes': notes,
      'isPrimary': isPrimary,
      if (province != null) 'province': province,
      if (landmark != null) 'landmark': landmark,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (fullAddress != null) 'fullAddress': fullAddress,
      'isDefault': isDefault,
    };
  }

  AddressModel copyWith({
    String? id,
    String? label,
    String? city,
    String? area,
    String? street,
    String? building,
    String? notes,
    bool? isPrimary,
    String? province,
    String? landmark,
    double? latitude,
    double? longitude,
    String? fullAddress,
    bool? isDefault,
  }) {
    return AddressModel(
      id: id ?? this.id,
      label: label ?? this.label,
      city: city ?? this.city,
      area: area ?? this.area,
      street: street ?? this.street,
      building: building ?? this.building,
      notes: notes ?? this.notes,
      isPrimary: isPrimary ?? this.isPrimary,
      province: province ?? this.province,
      landmark: landmark ?? this.landmark,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      fullAddress: fullAddress ?? this.fullAddress,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  String get displayAddress {
    final parts = <String>[];
    if (city != null && city!.isNotEmpty) parts.add(city!);
    if (area != null && area!.isNotEmpty) parts.add(area!);
    if (street != null && street!.isNotEmpty) parts.add(street!);
    if (parts.isEmpty && province != null) {
      return '$province - ${landmark ?? ''}';
    }
    return parts.join(' - ');
  }
}
