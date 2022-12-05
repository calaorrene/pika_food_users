import 'package:cloud_firestore/cloud_firestore.dart';

class Items
{
  String? sellerName;
  String? menuID;
  String? sellerUID;
  String? itemID;
  String? name;
  String? description;
  Timestamp? publishedDate;
  String? thumbnailUrl;
  String? status;
  int? quantity;
  double? price;

  Items({
    this.sellerName,
    this.menuID,
    this.sellerUID,
    this.itemID,
    this.name,
    this.description,
    this.publishedDate,
    this.thumbnailUrl,
    this.status,
    this.quantity,
    this.price,
  });

  Items.fromJson(Map<String, dynamic> json)
  {
    sellerName = json['sellerName'];
    menuID = json['menuID'];
    sellerUID = json['sellerUID'];
    itemID = json['itemID'];
    name = json['name'];
    description = json['description'];
    publishedDate = json['publishedDate'];
    thumbnailUrl = json['thumbnailUrl'];
    status = json['status'];
    quantity = json['quantity'];
    price = json['price'];
  }

  Map<String, dynamic> toJson() {final Map<String, dynamic> data = Map<String, dynamic>();
    data['sellerName'] = sellerName;
    data['menuID'] = menuID;
    data['sellerUID'] = sellerUID;
    data['itemID'] = itemID;
    data['name'] = name;
    data['description'] = description;
    data['publishedDate'] = publishedDate;
    data['thumbnailUrl'] = thumbnailUrl;
    data['status'] = status;
    data['quantity'] = quantity;
    data['price'] = price;

    return data;
  }
}