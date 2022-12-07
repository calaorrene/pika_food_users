import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:number_inc_dec/number_inc_dec.dart';
import 'package:pika_food_cutomer/assistantMethods/assistant_methods.dart';
import 'package:pika_food_cutomer/models/items.dart';

import '../global/global.dart';

class CartItemDesign extends StatefulWidget
{
  final Items? model;
  BuildContext? context;
  final int? quanNumber;

  CartItemDesign({
    this.model,
    this.context,
    this.quanNumber,
  });

  @override
  _CartItemDesignState createState() => _CartItemDesignState();
}

class _CartItemDesignState extends State<CartItemDesign> {

  TextEditingController counterTextEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.cyan,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Container(
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
          height: 100,
          width: MediaQuery.of(context).size.width,
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(10), bottomLeft: Radius.circular(10)), //add border radius
                child: Image.network(
                  widget.model!.thumbnailUrl!,
                  height: 100.0,
                  width: 100.0,
                  fit: BoxFit.cover,
                ),
              ),
              //image

              const SizedBox(width: 10,),

              Expanded(
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  //title
                  Text(
                    widget.model!.name!,
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
                      Container(
                        width: 100,
                        height: 30,
                        child: Padding(
                          padding: const EdgeInsets.all(5),
                          child: NumberInputPrefabbed.squaredButtons(
                            buttonArrangement: ButtonArrangement.incRightDecLeft,
                            controller: counterTextEditingController,
                            incDecBgColor: Colors.white,
                            incIcon: Icons.add,
                            incIconSize: 20,
                            decIconSize: 20,
                            decIcon: Icons.remove,
                            min: 1,
                            max: widget.model!.quantity!,
                            initialValue: int.parse(widget.quanNumber.toString()),
                          ),
                        ),
                      ),
                    ],
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
                    clearCartNow(context);

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
