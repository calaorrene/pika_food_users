import 'package:cloud_firestore/cloud_firestore.dart';

class UserCart
{
  String? itemID;
  String? sellerUID;
  String? productName;
  int? quantity;
  String? sellerName;
  String? thumbnail;
  DateTime? addedTime;
  double? price;
  double? totalAmount;

  UserCart({
    this.itemID,
    this.sellerUID,
    this.productName,
    this.quantity,
    this.sellerName,
    this.thumbnail,
    this.addedTime,
    this.price,
    this.totalAmount,
  });

  UserCart.fromJson(Map<String, dynamic> json)
  {
    itemID = json['itemID'];
    sellerUID = json['sellerUID'];
    productName = json['productName'];
    quantity = json['quantity'];
    sellerName = json['sellerName'];
    thumbnail = json['thumbnail'];
    addedTime = json['addedTime'].toDate();
    price = json['price'].toDouble();
    totalAmount = json['totalAmount'].toDouble();
  }

  Map<String, dynamic> toJson()
  {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['itemID'] = itemID;
    data['sellerUID'] = sellerUID;
    data['productName'] = productName;
    data['quantity'] = quantity;
    data['sellerName'] = sellerName;
    data['thumbnail'] = thumbnail;
    data['addedTime'] = addedTime;
    data['price'] = price;
    data['totalAmount'] = totalAmount;

    return data;
  }
}