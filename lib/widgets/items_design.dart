import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:number_inc_dec/number_inc_dec.dart';
import 'package:pika_food_cutomer/global/global.dart';
import 'package:pika_food_cutomer/models/items.dart';
import 'package:counter_button/counter_button.dart';

import '../assistantMethods/assistant_methods.dart';


class ItemsDesignWidget extends StatefulWidget
{
  Items? model;
  BuildContext? context;

  ItemsDesignWidget({this.model, this.context});

  @override
  _ItemsDesignWidgetState createState() => _ItemsDesignWidgetState();
}

class _ItemsDesignWidgetState extends State<ItemsDesignWidget>
{
  TextEditingController counterTextEditingController = TextEditingController();
  String _sellerName = "";
  var shouldAbsorb = false;

  bool notAvailable = false;
  int _previousQuantity = 0;
  int _newQuantity = 0;
  int _counterValue = 0;
  int _quantity = 0;

  getQuantity(){
    FirebaseFirestore.instance
        .collection("items")
        .doc(widget.model!.itemID).get().then((DocumentSnapshot)
    {
      _previousQuantity = DocumentSnapshot.data()!["quantity"];
    }).then((value) {
      FirebaseFirestore.instance
          .collection("items")
          .doc(widget.model!.itemID)
          .update({
        "quantity": _newQuantity,
      });
    });
  }

  getMax() {
    if (widget.model!.quantity! >= int.parse(counterTextEditingController.toString())) {
      Fluttertoast.showToast(msg: "Out of In-App Stock");
    }
  }

  getAvailability() {
    FirebaseFirestore.instance
        .collection("sellers")
        .doc(widget.model!.sellerUID)
        .collection("menus")
        .doc(widget.model!.menuID)
        .collection("items")
        .doc(widget.model!.itemID).get().then((DocumentSnapshot)
    {
      _quantity = DocumentSnapshot.data()!["quantity"];
      debugPrint("Quantity: " + _quantity.toString());

      if (_quantity == 0){
        shouldAbsorb = false;
        Fluttertoast.showToast(msg: "Out of In-App Stock");
      }
      else {
        showDialog(context: context, builder: (context) => AlertDialog(
          contentPadding: EdgeInsets.all(0),
          content: Container(
            color: Colors.white,
            height: 250,
            width: 0,
            child: Column(
              children: [
                Image.network(widget.model!.thumbnailUrl.toString(),
                  fit:BoxFit.fill,
                  width: 100,
                  height: 100,
                ),
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Text(
                    widget.model!.name.toString() + " ₱ " + widget.model!.price.toString(),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ),
                Container(
                  width: 120,
                  height: 35,
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: NumberInputPrefabbed.squaredButtons(
                      buttonArrangement: ButtonArrangement.incRightDecLeft,
                      controller: counterTextEditingController,
                      incDecBgColor: Colors.white,
                      incIcon: Icons.add,
                      decIcon: Icons.remove,
                      min: 1,
                      max: widget.model!.quantity!,
                      initialValue: 1,
                    ),
                  ),
                ),
                SizedBox(height: 5,),
                Center(
                  child: InkWell(
                    onTap: ()
                    {
                      _newQuantity = widget.model!.quantity!.toInt() - int.parse(counterTextEditingController.text);

                      FirebaseFirestore.instance
                          .collection("sellers").doc(widget.model!.sellerUID).collection("menus").doc(widget.model!.menuID).collection("items").doc(widget.model!.itemID)
                          .update({
                        "quantity": _newQuantity,
                      });

                      debugPrint("Quantity: " +  _newQuantity.toString());

                      addUserCart();


                      int itemCounter = int.parse(counterTextEditingController.text);

                      List<String> separateItemIDsList = separateItemIDs();

                      //1.check if item exist already in cart
                      separateItemIDsList.contains(widget.model!.itemID)
                          ? Fluttertoast.showToast(msg: "Item is already in Cart.")
                          :
                      //2.add to cart

                      addItemToCart(widget.model!.itemID, context, itemCounter);

                    },
                    child: Container(
                      decoration: const BoxDecoration(
                          color: Colors.orangeAccent
                      ),
                      width: MediaQuery.of(context).size.width - 13,
                      height: 50,
                      child: const Center(
                        child: Text(
                          "Add to Cart",
                          style: TextStyle(color: Colors.white, fontSize: 15),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Center(
                  child: InkWell(
                    onTap: ()
                    {
                      Navigator.pop(context);
                    },

                    child: Container(
                      decoration: const BoxDecoration(
                      ),
                      width: MediaQuery.of(context).size.width - 13,
                      height: 20,
                      child: const Center(
                        child: Text(
                          "Cancel",
                          style: TextStyle(color: Colors.grey, fontSize: 15),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
      }
    });
  }

  addUserCart() {
    FirebaseFirestore.instance
        .collection("items")
        .doc(widget.model!.itemID)
        .get().then((snap)
    {
      _sellerName = snap.data()!["sellerName"].toString();

    }).then((value) {

      writeUserCart({
        "itemID": widget.model!.itemID,
        "sellerUID": widget.model!.sellerUID,
        "productName": widget.model!.name,
        "thumbnail": widget.model!.thumbnailUrl,
        "quantity": int.parse(counterTextEditingController.text),
        "price": widget.model!.price,
        "totalAmount" :  widget.model!.price! * double.parse(counterTextEditingController.text),
        "sellerName" : _sellerName,
        "addedTime" : FieldValue.serverTimestamp()
      }).whenComplete((){
        setState(() {
          Fluttertoast.showToast(msg: "Item added successfully.");
        });
      });
    });
  }

  Future writeUserCart(Map<String, dynamic> data) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(sharedPreferences!.getString("uid"))
        .collection("userCart")
        .doc(widget.model!.itemID)
        .set(data);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: AbsorbPointer(
        absorbing: shouldAbsorb,
        child: GestureDetector(
          onTap: ()
          {
            getAvailability();
          },
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Container(
              height: 150,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Colors.white30,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 2,
                    offset: Offset(0, 3), // changes position of shadow
                  ),
                ],
              ),
              foregroundDecoration: BoxDecoration(
                color: widget.model!.quantity != 0 ? null : Colors.grey,
                backgroundBlendMode: widget.model!.quantity != 0 ? null : BlendMode.color,
                boxShadow: widget.model!.quantity != 0 ? null : [BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 2,
                    offset: Offset(0, 3), // changes position of shadow
                  ),],
              ),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.only(topRight: Radius.circular(10.0), topLeft: Radius.circular(10.0)), //add border radius
                    child: Image.network(
                      widget.model!.thumbnailUrl!,
                      height: 100.0,
                      width: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 5.0,),
                  Text(
                    widget.model!.name.toString(),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontFamily: "Train",
                    ),
                  ),
                  Text(
                    "₱ " + widget.model!.price.toString(),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontFamily: "Train",
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

//Navigator.push(context, MaterialPageRoute(builder: (c)=> ItemDetailsScreen(model: widget.model)));
