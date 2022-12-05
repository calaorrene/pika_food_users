import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pika_food_cutomer/global/global.dart';


deleteItem({String? itemID})
{
  FirebaseFirestore.instance
      .collection("users")
      .doc(sharedPreferences!.getString("uid"))
      .collection("userCart")
      .doc(itemID)
      .delete().then((value) {
    print("Success!");
  });
}


