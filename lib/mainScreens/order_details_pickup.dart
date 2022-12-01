import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:pika_food_cutomer/assistantMethods/assistant_methods.dart';
import 'package:pika_food_cutomer/global/global.dart';
import 'package:pika_food_cutomer/models/address.dart';
import 'package:pika_food_cutomer/widgets/order_card.dart';
import 'package:pika_food_cutomer/widgets/progress_bar.dart';
import 'package:pika_food_cutomer/widgets/shipment_address_design.dart';
import 'package:pika_food_cutomer/widgets/status_banner.dart';


class OrderDetailsPickup extends StatefulWidget
{
  final String? orderID;
  late String? sellerUID;

  OrderDetailsPickup({this.orderID, this.sellerUID});

  @override
  _OrderDetailsPickupState createState() => _OrderDetailsPickupState();
}

class _OrderDetailsPickupState extends State<OrderDetailsPickup>
{
  String ratingID = DateTime.now().millisecondsSinceEpoch.toString();

  String orderStatus = "";

  getOrderInfo()
  {
    FirebaseFirestore.instance
        .collection("orders")
        .doc(widget.orderID).get().then((DocumentSnapshot)
    {
      orderStatus = DocumentSnapshot.data()!["status"].toString();
    }).then((value) {
      FirebaseFirestore.instance
          .collection("orders")
          .doc(widget.orderID)
          .update({
        "status": "torate"
      });
    }).then((value) {
      FirebaseFirestore.instance
          .collection("users")
          .doc(sharedPreferences!.getString("uid"))
          .collection("orders")
          .doc(widget.orderID)
          .update({
        "status": "torate",
      });
    });
    Navigator.pop(context);
  }

  addRating()
  {
    FirebaseFirestore.instance
        .collection("orders")
        .doc(widget.orderID)
        .get()
        .then((snap) {

      widget.sellerUID = snap.data()!["sellerUID"].toString();

    }).then((value) {
      FirebaseFirestore.instance
          .collection("sellers")
          .doc(widget.sellerUID)
          .get()
          .then((snap) {

      }).then((value) {
        FirebaseFirestore.instance
            .collection("sellers")
            .doc(widget.sellerUID).get().then((snap)
        {
          debugPrint("Seller ID: " + widget.sellerUID.toString());

        }).then((value) {

          writeRating({
            "sellerUID": widget.sellerUID,
            "orderBy": sharedPreferences!.getString("uid"),
            "productIDs": sharedPreferences!.getStringList("userCart"),
            "paymentDetails": "Cash on Delivery",
            "rateTime": ratingID,
            "1_oneStar": "",
            "2_twoStar": "",
            "3_threeStar": "",
            "4_fourStar": "",
            "5_fiveStar": "",
            "rating": "",
          }).whenComplete((){
            setState(() {
              ratingID="";
              Fluttertoast.showToast(msg: "Congratulations, Order has been placed successfully.");
            });
          });
        });
      });
    });
  }

  Future writeRating(Map<String, dynamic> data) async
  {
    await FirebaseFirestore.instance
        .collection("rating")
        .doc(widget.sellerUID)
        .set(data);
  }

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      body: SingleChildScrollView(
        child: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection("users")
              .doc(sharedPreferences!.getString("uid"))
              .collection("orders")
              .doc(widget.orderID)
              .get(),
          builder: (c, snapshot)
          {
            Map? dataMap;
            if(snapshot.hasData)
            {
              dataMap = snapshot.data!.data()! as Map<String, dynamic>;
              orderStatus = dataMap["status"].toString();
            }
            return snapshot.hasData
                ? Container(
              child: Column(
                children: [
                  StatusBanner(
                    status: dataMap!["isSuccess"],
                    orderStatus: orderStatus,
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),

                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Order Id = " + widget.orderID!,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        "₱  " + dataMap["totalAmount"].toString(),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Order at: " +
                          DateFormat("dd MMMM, yyyy - hh:mm aa")
                              .format(DateTime.fromMillisecondsSinceEpoch(int.parse(dataMap["orderTime"]))),
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),

                  // Image.asset("images/check.png", scale: 2,),

                  const Divider(thickness: 4,),
                  FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection("users")
                        .doc(sharedPreferences!.getString("uid"))
                        .collection("userAddress")
                        .doc(dataMap["addressID"])
                        .get(),
                    builder: (c, snapshot)
                    {
                      return snapshot.hasData
                          ? ShipmentAddressDesign(
                        model: Address.fromJson(
                            snapshot.data!.data()! as Map<String, dynamic>
                        ),
                        orderStatus: orderStatus,
                      )
                          : Center(child: circularProgress(),);
                    },
                  ),

                  orderStatus == "preparing"
                      ? Container(child: Text("Preparing..."))
                      : Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Center(
                      child: InkWell(
                        onTap: ()
                        {
                          getOrderInfo();
                          addRating();
                        },
                        child: Container(
                          decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.redAccent,
                                  Colors.orangeAccent,
                                ],
                                begin:  FractionalOffset(0.0, 0.0),
                                end:  FractionalOffset(1.0, 0.0),
                                stops: [0.0, 1.0],
                                tileMode: TileMode.clamp,
                              )
                          ),
                          width: MediaQuery.of(context).size.width - 40,
                          height: 50,
                          child: const Center(
                            child: Text(
                              "Pick Up",
                              style: TextStyle(color: Colors.white, fontSize: 15.0),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
                : Center(child: circularProgress(),);
          },
        ),

      ),
    );
  }
}
