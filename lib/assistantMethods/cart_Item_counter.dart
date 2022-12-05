import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:pika_food_cutomer/global/global.dart';

final usersRef = FirebaseFirestore.instance.collection('users')
    .doc(sharedPreferences!.getString('uid'))
    .collection('userCart');

class CartItemCounter extends ChangeNotifier
{
  int cartListItemCounter = 0;

  getUsers(){
    usersRef.get().then((QuerySnapshot snapshot) {cartListItemCounter = snapshot.docs.length;});
  }

  int get count => cartListItemCounter;

  Future<void> displayCartListItemsNumber() async
  {
    getUsers();
    cartListItemCounter = cartListItemCounter;

    await Future.delayed(const Duration(milliseconds: 100), () {
      notifyListeners();
    });
  }
}