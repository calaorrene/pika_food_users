import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:number_inc_dec/number_inc_dec.dart';
import 'package:pika_food_cutomer/global/global.dart';
import 'package:pika_food_cutomer/models/UserCart.dart';
import 'package:pika_food_cutomer/widgets/progress_bar.dart';
import '../assistantMethods/assistant_methods.dart';

class CartCard extends StatefulWidget
{
  final UserCart? model;
  final BuildContext? context;

  CartCard({
    this.model,
    this.context
  });

  @override
  State<CartCard> createState() => _CartCardState();
}

class _CartCardState extends State<CartCard> {


  final TextEditingController counterTextEditingController = TextEditingController();

  late TextEditingController _controllerQuantity = TextEditingController();

  int quantity = 0;
  double price = 0;
  double totalAmount = 0;

  getPrice() {
    FirebaseFirestore.instance
        .collection("users")
        .doc(sharedPreferences!.getString("uid"))
        .collection("userCart")
        .doc(widget.model!.itemID)
        .get()
        .then((snap)
    {
          price = double.parse(snap.data()!["price"].toString());
    });
  }

  getQuantity() {
    FirebaseFirestore.instance
        .collection("users")
        .doc(sharedPreferences!.getString("uid"))
        .collection("userCart")
        .doc(widget.model!.itemID)
        .get()
        .then((snap)
    {
      _controllerQuantity.text = snap.data()!["quantity"].toString();
    }).then((value) {
      quantity = int.parse(_controllerQuantity.text);
    });
  }

  incQuantity(){
    quantity++;
    _controllerQuantity.text = quantity.toString();

    FirebaseFirestore.instance
        .collection("users")
        .doc(sharedPreferences!.getString("uid"))
        .collection("userCart")
        .doc(widget.model!.itemID)
        .update({
      "quantity": int.parse(_controllerQuantity.text),

    }).then((value) {
      debugPrint("Price: " + price.toString());
      totalAmount = price * int.parse(_controllerQuantity.text);
      FirebaseFirestore.instance
          .collection("users")
          .doc(sharedPreferences!.getString("uid"))
          .collection("userCart")
          .doc(widget.model!.itemID)
          .update({
        "totalAmount": totalAmount,
      });
    });
  }

  decQuantity(){
    quantity--;
    _controllerQuantity.text = quantity.toString();

    FirebaseFirestore.instance
        .collection("users")
        .doc(sharedPreferences!.getString("uid"))
        .collection("userCart")
        .doc(widget.model!.itemID)
        .update({
      "quantity": int.parse(_controllerQuantity.text),

    }).then((value) {
      debugPrint("Price: " + price.toString());
      totalAmount = price * int.parse(_controllerQuantity.text);
      FirebaseFirestore.instance
          .collection("users")
          .doc(sharedPreferences!.getString("uid"))
          .collection("userCart")
          .doc(widget.model!.itemID)
          .update({
        "totalAmount": totalAmount,
      });
    });
  }

  onChangeQuantity() {
  }

  @override
  void initState() {
    getQuantity();
    getPrice();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Container(
          height: 100,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: Colors.white,
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

          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(10), bottomLeft: Radius.circular(10)), //add border radius
                child: Image.network(
                  widget.model!.thumbnail.toString(),
                  height: 100.0,
                  width: 100.0,
                  fit: BoxFit.cover,
                ),
              ),

              const SizedBox(width: 10,),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    //title

                    Text(
                      widget.model!.sellerName.toString(),
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontFamily: "Kiwi",
                      ),
                    ),

                    const SizedBox(
                      height: 5,
                    ),

                    //price
                    Row(
                      children: [
                        const Text(
                          "Price: ",
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey,
                          ),
                        ),
                        const Text(
                          "₱ ",
                          style: TextStyle(
                              color: Colors.blue,
                              fontSize: 16.0
                          ),
                        ),
                        Text(
                            widget.model!.price.toString(),
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.blue,
                            )
                        ),
                      ],
                    ),

                    //quantity number // x 7
                    Row(
                      children: [
                        Text(
                          "Quantity:",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 15,
                            fontFamily: "Acme",
                          ),
                        ),

                        Spacer(),

                        Container(
                            width: 100,
                            height: 25,
                            decoration: BoxDecoration(
                              border: Border.all(
                                  width: 1,
                                  color: Colors.grey),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [

                                Container(
                                  width: 25,
                                  child: IconButton(
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.zero,
                                    onPressed: () {
                                      decQuantity();
                                    },
                                    icon: Icon(
                                      Icons.remove,
                                      size: 20,
                                      color: Colors.black,),
                                  ),
                                ),

                                Container(
                                  width: 40,
                                  child: TextField(
                                    style: TextStyle(
                                      fontSize: 15,
                                    ),
                                    controller: _controllerQuantity,
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    textAlignVertical: TextAlignVertical.center,
                                    decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintStyle: TextStyle(color: Colors.grey.shade500)),
                                  ),
                                ),

                                Container(
                                  width: 25,
                                  child: IconButton(
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.zero,
                                    onPressed: () {
                                      incQuantity();
                                    },
                                    icon: Icon(
                                      Icons.add,
                                      size: 20,
                                      color: Colors.black,),
                                  ),
                                ),
                              ],
                            )
                        ),

                        Spacer(),
                      ],
                    ),

                    Text(
                      widget.model!.totalAmount.toString(),
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                        fontFamily: "Acme",
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(topRight: Radius.circular(10.0), bottomRight: Radius.circular(10.0)),
                  color: Colors.black12,
                ),
                child: IconButton(
                  icon: const Icon(Icons.delete_forever_outlined, size: 50, color: Colors.grey,),
                  onPressed: () async
                  {
                    deleteItem(itemID: widget.model!.itemID);
                    Fluttertoast.showToast(msg: "Deleted.");
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
