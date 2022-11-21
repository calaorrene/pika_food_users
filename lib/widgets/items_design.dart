import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:number_inc_dec/number_inc_dec.dart';
import 'package:pika_food_cutomer/mainScreens/item_detail_screen.dart';
import 'package:pika_food_cutomer/models/items.dart';

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

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: ()
      {
        //Navigator.push(context, MaterialPageRoute(builder: (c)=> ItemDetailsScreen(model: widget.model)));
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
                      incDecBgColor: Colors.amber,
                      min: 1,
                      max: widget.model!.quantity!,
                      initialValue: 1,
                    ),
                  ),
                ),
                Center(
                  child: InkWell(
                    onTap: ()
                    {
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
      },
      splashColor: Colors.amber,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black12,
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
          height: 150,
          width: MediaQuery.of(context).size.width,
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
                "₱" + widget.model!.price.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontFamily: "Train",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
