import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pika_food_cutomer/global/global.dart';
import 'package:pika_food_cutomer/models/UserCart.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:pika_food_cutomer/widgets/progress_bar.dart';
import '../widgets/cart_card.dart';

final usersRef = FirebaseFirestore.instance.collection('users')
    .doc(sharedPreferences!.getString('uid'))
    .collection('userCart');

class MyCartScreen extends StatefulWidget {

  final String? sellerUID;

  final UserCart? model;
  final BuildContext? context;

  MyCartScreen({this.model, this.context, this.sellerUID});

  @override
  State<MyCartScreen> createState() => _MyCartScreenState();
}

class _MyCartScreenState extends State<MyCartScreen> {

  String orderId = DateTime.now().millisecondsSinceEpoch.toString();

  addOrderDetails()
  {
    writeOrderDetailsForUser({
      "totalAmount": "0",
      "orderBy": sharedPreferences!.getString("uid"),
      //"productIDs": sharedPreferences!.getStringList("userCart"),
      "paymentDetails": "Cash on Delivery",
      "orderTime": orderId,
      "isSuccess": true,
      "sellerUID": widget.sellerUID,
      "status": "preparing",
      "orderId": orderId,
    });

    writeOrderDetailsForSeller({
      "totalAmount": "0",
      "orderBy": sharedPreferences!.getString("uid"),
      //"productIDs": sharedPreferences!.getStringList("userCart"),
      "paymentDetails": "Cash on Delivery",
      "orderTime": orderId,
      "isSuccess": true,
      "sellerUID": widget.sellerUID,
      "status": "preparing",
      "orderId": orderId,
    }).whenComplete((){
      setState(() {
        orderId="";
        Navigator.pop(context);
        Fluttertoast.showToast(msg: "Congratulations, Order has been placed successfully.");
      });
    });
  }

  Future writeOrderDetailsForUser(Map<String, dynamic> data) async
  {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(sharedPreferences!.getString("uid"))
        .collection("orders")
        .doc(orderId)
        .set(data);
  }

  Future writeOrderDetailsForSeller(Map<String, dynamic> data) async
  {
    await FirebaseFirestore.instance
        .collection("orders")
        .doc(orderId)
        .set(data);
  }

  @override
  void initState() {
    debugPrint("Test: " + widget!.sellerUID.toString());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Cart"),
        backgroundColor: Colors.orangeAccent,
      ),
      body: CustomScrollView(
        slivers: [StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(sharedPreferences!.getString('uid'))
                .collection('userCart')
                .orderBy('addedTime', descending: true)
                .snapshots(),
            builder: (context, snapshot)
            {
              return !snapshot.hasData
                  ? SliverToBoxAdapter(child: Center(child: circularProgress(),),)
                  : SliverStaggeredGrid.countBuilder(
                crossAxisCount: 1,
                staggeredTileBuilder: (c) => StaggeredTile.fit(1),
                itemBuilder: (context, index)
                {
                  UserCart model = UserCart.fromJson(snapshot.data!.docs[index].data()! as Map<String, dynamic>,);
                  return CartCard(model: model, context: context,);
                },
                itemCount: snapshot.data!.docs.length,
              );

            },
          ),
        ],
      ),
      bottomNavigationBar: Container(
        height: 70,
        color: Colors.white30,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [

            Spacer(),

            Text("Total Amount: " ),

            Spacer(),

            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(topRight: Radius.circular(10.0), bottomRight: Radius.circular(10.0)),
                color: Colors.black12,
              ),
              child: InkWell(
                onTap: ()
                {
                  showDialog(context: context, builder: (context) => AlertDialog(
                    backgroundColor: Colors.transparent,
                    insetPadding: EdgeInsets.all(0),
                    content: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                      ),
                      padding: EdgeInsets.all(10),
                      height: 150,
                      width: 0,
                      child: Column(
                        children: [
                          Image.asset("images/question.png", width: 80) ,

                          const SizedBox(height: 20,),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [

                              InkWell(
                                onTap: ()
                                {
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  height: 30,
                                  width: 105,
                                  decoration: const BoxDecoration(
                                  ),
                                  child: Center(
                                    child: Text(
                                      "Cancel",
                                      style: TextStyle(color: Colors.grey, fontSize: 15),
                                    ),
                                  ),
                                ),
                              ),

                              InkWell(
                                onTap: ()
                                {
                                  addOrderDetails();
                                },
                                child: Container(
                                  height: 30,
                                  width: 100,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                  ),
                                  child: Center(
                                    child: Text( "Confirm",
                                      style: TextStyle(color: Colors.grey, fontSize: 15, fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                ),
                              ),

                            ],
                          ),
                        ],
                      ),
                    ),
                  ));
                },
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.orangeAccent
                  ),
                  width: MediaQuery.of(context).size.width - 40,
                  height: 50,
                  child: const Center(
                    child: Text(
                      "Place Order",
                      style: TextStyle(color: Colors.white, fontSize: 15.0),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
