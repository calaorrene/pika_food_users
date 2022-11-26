import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:pika_food_cutomer/assistantMethods/assistant_methods.dart';
import 'package:pika_food_cutomer/global/global.dart';
import 'package:pika_food_cutomer/models/address.dart';
import 'package:pika_food_cutomer/widgets/order_card.dart';
import 'package:pika_food_cutomer/widgets/progress_bar.dart';
import 'package:pika_food_cutomer/widgets/shipment_address_design.dart';
import 'package:pika_food_cutomer/widgets/status_banner.dart';


class OrderDetailsRate extends StatefulWidget
{
  final String? orderID;
  final String? sellerUID;


  OrderDetailsRate({this.orderID, this.sellerUID});

  @override
  _OrderDetailsRateState createState() => _OrderDetailsRateState();
}

class _OrderDetailsRateState extends State<OrderDetailsRate>
{
  String orderTotalAmount = "";
  String orderStatus = "";
  double _rating = 0;

  getPreviousEarnings(){
    FirebaseFirestore.instance
        .collection("sellers")
        .doc(widget.sellerUID).get().then((snap)
    {
      previousEarnings = snap.data()!["earnings"].toString();
    });
  }

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
        "status": "done",
      });
    }).then((value) {
      FirebaseFirestore.instance
          .collection("users")
          .doc(sharedPreferences!.getString("uid"))
          .collection("orders")
          .doc(widget.orderID)
          .update({
        "status": "done",
        }).then((value) {
        FirebaseFirestore.instance
            .collection("sellers")
            .doc(widget.sellerUID).update({
          "earnings": (double.parse(orderTotalAmount) + (double.parse(previousEarnings))).toString()
        });
      });
    });
    Navigator.pop(context);
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
                    child: Text(
                      "Seller ID = " + dataMap["sellerUID"],
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

                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Center(
                      child: InkWell(
                        onTap: ()
                        {
                          getOrderInfo();
                          getPreviousEarnings();
                        },
                        child: Column(
                          children: [
                            Text("Rate: $_rating"),
                            RatingBar.builder(
                              minRating: 1,
                              itemSize: 40,
                              itemBuilder: (context, _) => Icon(Icons.star, color: Colors.amber),
                              onRatingUpdate: (rating) => setState(() {
                                this._rating = rating ;
                              }),
                            ),
                            SizedBox(height: 10,),

                            _rating == 0
                                ? Container(
                              decoration: const BoxDecoration(
                                  color: Colors.grey
                              ),
                              width: MediaQuery.of(context).size.width - 40,
                              height: 50,
                              child: const Center(
                                child: Text(
                                  "Rate",
                                  style: TextStyle(color: Colors.white, fontSize: 15.0),
                                ),
                              ),
                            )
                                : Container(
                              decoration: const BoxDecoration(
                                  color: Colors.orangeAccent
                              ),
                              width: MediaQuery.of(context).size.width - 40,
                              height: 50,
                              child: const Center(
                                child: Text(
                                  "Rate",
                                  style: TextStyle(color: Colors.white, fontSize: 15.0),
                                ),
                              ),
                            )
                          ],
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
