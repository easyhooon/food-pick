class FoodStoreModel {
  int? id;
  String storeName;
  String storeAddress;
  String storeComment;
  String? storeImgUrl;
  String uid;
  double latitude;
  double longitude;
  DateTime? createdAt;

  FoodStoreModel({
    this.id,
    required this.storeName,
    required this.storeAddress,
    required this.storeComment,
    this.storeImgUrl,
    required this.uid,
    required this.latitude,
    required this.longitude,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'store_name': storeName,
      'store_address': storeAddress,
      'store_comment': storeComment,
      'store_img_url': storeImgUrl,
      'uid': uid,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory FoodStoreModel.fromJson(Map<dynamic, dynamic> json) {
    return FoodStoreModel(
      id: json['id'],
      storeName: json['store_name'],
      storeAddress: json['store_address'],
      storeComment: json['store_comment'],
      storeImgUrl: json['store_img_url'],
      uid: json['uid'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
