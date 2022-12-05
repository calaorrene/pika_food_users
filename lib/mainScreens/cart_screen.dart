import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pika_food_cutomer/assistantMethods/assistant_methods.dart';
import 'package:pika_food_cutomer/assistantMethods/cart_Item_counter.dart';
import 'package:pika_food_cutomer/assistantMethods/total_amount.dart';
import 'package:pika_food_cutomer/mainScreens/address_screen.dart';
import 'package:pika_food_cutomer/models/items.dart';
import 'package:pika_food_cutomer/splashScreen/splash_screen.dart';
import 'package:pika_food_cutomer/widgets/cart_item_design.dart';
import 'package:pika_food_cutomer/widgets/progress_bar.dart';
import 'package:pika_food_cutomer/widgets/text_widget_header.dart';
import 'package:provider/provider.dart';

import '../global/global.dart';


class CartScreen extends StatefulWidget
{
  final String? sellerUID;
  final String? sellerName;

  Items? model;
  BuildContext? context;

  CartScreen({this.model, this.sellerUID, this.sellerName, this.context});

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen>
{
  List<DocumentSnapshot>? data;
  List<String>? seperateQuantitiesList;

  int? itemCount;

  List<int>? separateItemQuantityList;
  num totalAmount = 0;
  String price = "";
  String quantity = "";


  @override
  void initState() {
    super.initState();

    totalAmount = 0;
    Provider.of<TotalAmount>(context, listen: false).displayTotalAmount(0);

    separateItemQuantityList = separateItemQuantities();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
              color: Colors.orangeAccent
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: ()
          {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "",
          style: TextStyle(fontSize: 45, fontFamily: "Signatra"),
        ),
        centerTitle: true,
        automaticallyImplyLeading: true,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart, color: Colors.black,),
                onPressed: ()
                {
                  print("clicked");
                },
              ),
              Positioned(
                child: Stack(
                  children: [
                    const Icon(
                      Icons.brightness_1,
                      size: 20.0,
                      color: Colors.redAccent,
                    ),
                    Positioned(
                      top: 3,
                      right: 4,
                      child: Center(
                        child: Consumer<CartItemCounter>(
                          builder: (context, counter, c)
                          {
                            return Text(
                              counter.count.toString(),
                              style: const TextStyle(color: Colors.white, fontSize: 12),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          const SizedBox(width: 10,),
          Align(
            alignment: Alignment.bottomLeft,
            child: FloatingActionButton.extended(
              heroTag: "btn1",
              label: const Text("Clear Cart", style: TextStyle(fontSize: 16),),
              backgroundColor: Colors.orangeAccent,
              icon: const Icon(Icons.clear_all),
              onPressed: ()
              {
                clearCartNow(context);

                Navigator.pop(context);

                Fluttertoast.showToast(msg: "Cart has been cleared.");
              },
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: FloatingActionButton.extended(
              heroTag: "btn2",
              label: const Text("Check Out", style: TextStyle(fontSize: 16),),
              backgroundColor: Colors.orangeAccent,
              icon: const Icon(Icons.navigate_next),
              onPressed: ()
              {
                //debugPrint("Cart Screen TestID: " +  widget.model!.sellerUID.toString());
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (c)=> AddressScreen(
                          totalAmount: totalAmount.toDouble(),
                          sellerUID: widget.sellerUID,
                          sellerName: widget.sellerName,
                      ),
                    )
                );
              },
            ),
          ),
        ],
      ),

      body: InkWell(
        onTap: ()
        {

        },
        child: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection("users")
              .doc(sharedPreferences!.getString("uid"))
              .collection("userCart")
              .doc(widget.model!.itemID)
              .get(),
          builder: (c, snapshot)
          {
            Map? dataMap;
            if(snapshot.hasData)
            {
              dataMap = snapshot.data!.data()! as Map<String, dynamic>;
              price = dataMap["price"].toString();
              quantity = dataMap["quantity"].toString();
            }
            return snapshot.hasData
                ? Container(
              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10,),
                  Text(
                    widget.model!.sellerName.toString(),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontFamily: "Acme",
                    ),
                  ),
                  SizedBox(height: 5,),
                  Text(
                    "Total Amount: ₱" + totalAmount.toString(),
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                      fontSize: 16,
                      fontFamily: "Acme",
                    ),
                  ),
                  SizedBox(height: 5,),
                  Text(
                    "More Info >>",
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                      fontFamily: "Acme",
                    ),
                  ),

                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white
                    ),
                    padding: const EdgeInsets.all(5),
                    margin: const EdgeInsets.all(5),
                    height: itemCount! * 50,
                    child: Stack(
                      children: [
                        Padding(padding: EdgeInsets.all(10)),
                        ListView.builder(
                          itemCount: itemCount,
                          physics: BouncingScrollPhysics(),
                          itemBuilder: (context, index)
                          {
                            Items model = Items.fromJson(data![index].data()! as Map<String, dynamic>);
                            return Align(
                              heightFactor: 0.3,
                              alignment: Alignment.topCenter,
                              child: placedOrderDesignWidget(model, context, seperateQuantitiesList![index]),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
                : Center(child: circularProgress(),);
          },
        ),
      )
    );
  }
}

Widget placedOrderDesignWidget(Items model, BuildContext context, seperateQuantitiesList)
{
  return Container(
    width: MediaQuery.of(context).size.width,
    height: 110,

    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 3,
            blurRadius: 3,
            offset: Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10.0), //add border radius
            child: Image.network(model.thumbnailUrl!, width: 90, height: 90, fit: BoxFit.cover,),
          ),
          const SizedBox(width: 10.0,),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      child: Text(
                        model.name! + " x " + seperateQuantitiesList,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontFamily: "Acme",
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                  ],
                ),

                const SizedBox(
                  height: 5,
                ),

                Text(
                  "₱ " + model.price.toString(),
                  style: TextStyle(fontSize: 16.0, color: Colors.blue),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

