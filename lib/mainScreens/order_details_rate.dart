import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:pika_food_cutomer/global/global.dart';
import 'package:pika_food_cutomer/models/address.dart';
import 'package:pika_food_cutomer/widgets/progress_bar.dart';
import 'package:pika_food_cutomer/widgets/shipment_address_design.dart';
import 'package:pika_food_cutomer/widgets/status_banner.dart';


class OrderDetailsRate extends StatefulWidget
{
  final String? orderID;
  late String? sellerUID;

  OrderDetailsRate({this.orderID, this.sellerUID});

  @override
  _OrderDetailsRateState createState() => _OrderDetailsRateState();
}

class _OrderDetailsRateState extends State<OrderDetailsRate>
{
  late TextEditingController _controllerComment = TextEditingController();

  String ratingID = DateTime.now().millisecondsSinceEpoch.toString();
  String orderTotalAmount = "";
  String orderStatus = "";
  double _rating = 0;
  double _totalRating = 0;
  var shouldAbsorb = true;

  getOrderTotalAmount() {
    FirebaseFirestore.instance
        .collection("orders")
        .doc(widget.orderID)
        .get()
        .then((snap) {
      orderTotalAmount = snap.data()!["totalAmount"].toString();
      widget.sellerUID = snap.data()!["sellerUID"].toString();

    }).then((value) {
      FirebaseFirestore.instance
          .collection("sellers")
          .doc(widget.sellerUID)
          .get()
          .then((snap)
      {
        previousEarnings = snap.data()!["earnings"].toString();

      }).then((value) {
        FirebaseFirestore.instance
            .collection("sellers")
            .doc(widget.sellerUID)
            .update(
            {
              "earnings" : (double.parse(orderTotalAmount) + (double.parse(previousEarnings))).toString(),
            });
      });
    });
  }

  getOrderInfo() {
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
        });
    });

    Navigator.pop(context);
  }

  getRating() {
    FirebaseFirestore.instance
        .collection("sellers")
        .doc(widget.sellerUID)
        .get()
        .then((snap)
    {
      previousRating = snap.data()!["1_oneStar"].toString();
    }).then((value)
    {
      if (_rating <= 1) {
        FirebaseFirestore.instance
            .collection("sellers")
            .doc(widget.sellerUID)
            .update({ "1_oneStar": int.parse(previousRating.toString()) + 1});
      }
      else if (_rating <= 2) {
        FirebaseFirestore.instance
            .collection("sellers")
            .doc(widget.sellerUID)
            .get()
            .then((snap)
        {
          previousRating = snap.data()!["2_twoStar"].toString();

        }).then((value) {
          FirebaseFirestore.instance
              .collection("sellers")
              .doc(widget.sellerUID)
              .update({ "2_twoStar" : int.parse(previousRating.toString()) + 1
          });
        });
      }
      else if (_rating <= 3) {
        FirebaseFirestore.instance
            .collection("sellers")
            .doc(widget.sellerUID)
            .get()
            .then((snap)
        {
          previousRating = snap.data()!["3_threeStar"].toString();

        }).then((value) {
          FirebaseFirestore.instance
              .collection("sellers")
              .doc(widget.sellerUID)
              .update({ "3_threeStar" : int.parse(previousRating.toString()) + 1
          });
        });
      }
      else if (_rating <= 4) {
        FirebaseFirestore.instance
            .collection("sellers")
            .doc(widget.sellerUID)
            .get()
            .then((snap)
        {
          previousRating = snap.data()!["4_fourStar"].toString();

        }).then((value) {
          FirebaseFirestore.instance
              .collection("sellers")
              .doc(widget.sellerUID)
              .update({ "4_fourStar" : int.parse(previousRating.toString()) + 1
          });
        });
      }
      else if (_rating <= 5) {
        FirebaseFirestore.instance
            .collection("sellers")
            .doc(widget.sellerUID)
            .get()
            .then((snap) {
          previousRating = snap.data()!["5_fiveStar"].toString();
        }).then((value) {
          FirebaseFirestore.instance
              .collection("sellers")
              .doc(widget.sellerUID)
              .update({ "5_fiveStar": int.parse(previousRating.toString()) + 1
          });
        });

      }
    });
  }

  getOverallRating() {
    FirebaseFirestore.instance
        .collection("sellers")
        .doc(widget.sellerUID)
        .get()
        .then((snap) {

      var one = snap.data()!["1_oneStar"].toString();
      var two = snap.data()!["2_twoStar"].toString();
      var three = snap.data()!["3_threeStar"].toString();
      var four = snap.data()!["4_fourStar"].toString();
      var five = snap.data()!["5_fiveStar"].toString();

      _totalRating = (5 * int.parse(five) + 4 * int.parse(four) + 3 * int.parse(three) + 2 * int.parse(two) + 1 * int.parse(one)) / (int.parse(five) + int.parse(four) + int.parse(three) + int.parse(two) + int.parse(one));

      // previousOverallRating = snap.data()!["rating"].toString();

    }).then((value) {
      FirebaseFirestore.instance
          .collection("sellers")
          .doc(widget.sellerUID)
          .update({
        "rating": _totalRating.toStringAsFixed(1),
      });
    }).then((value) {
      FirebaseFirestore.instance
          .collection("orders")
          .doc(widget.orderID)
          .update({"comment" : _controllerComment.text});
    }).then((value) {
      FirebaseFirestore.instance
          .collection("orders")
          .doc(widget.orderID)
          .update({"rate" : _rating});
    });;
    debugPrint("Test " + widget.orderID.toString());

  }

  addOrderDetails()
  {
    FirebaseFirestore.instance
        .collection("sellers")
        .doc(widget.sellerUID).get().then((snap)
    {

    }).then((value) {
      writeOrderDetailsForUser({
        "orderBy": sharedPreferences!.getString("uid"),
        "productIDs": sharedPreferences!.getStringList("userCart"),
        "paymentDetails": "Cash on Delivery",
        "orderTime": widget.orderID,
        "isSuccess": true,
        "sellerUID": widget.sellerUID,
        "status": "torate",
        "orderId": widget.orderID,
        "comment": _controllerComment.text
      });

      writeOrderDetailsForSeller({
        "orderBy": sharedPreferences!.getString("uid"),
        "productIDs": sharedPreferences!.getStringList("userCart"),
        "paymentDetails": "Cash on Delivery",
        "orderTime": widget.orderID,
        "isSuccess": true,
        "sellerUID": widget.sellerUID,
        "status": "ended",
        "orderId": widget.orderID,
        "comment": _controllerComment.text
      }).whenComplete((){
        setState(() {
          Fluttertoast.showToast(msg: "Congratulations, Order has been placed successfully.");
        });
      });
    });
  }

  Future writeOrderDetailsForUser(Map<String, dynamic> data) async
  {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(sharedPreferences!.getString("uid"))
        .collection("orders")
        .doc(widget.orderID)
        .set(data);
  }

  Future writeOrderDetailsForSeller(Map<String, dynamic> data) async
  {
    await FirebaseFirestore.instance
        .collection("orders")
        .doc(widget.orderID)
        .set(data);
  }


  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      body: SingleChildScrollView(
        child:
        FutureBuilder<DocumentSnapshot>(
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
                      "Order ID = " + widget.orderID!,
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

                  Text("Rate: $_rating"),

                  RatingBar.builder(
                    minRating: 1,
                    itemSize: 40,
                    itemBuilder: (context, _) => Icon(Icons.star, color: Colors.amber),
                    onRatingUpdate: (rating) => setState(() {

                      if (rating <= 1){
                        shouldAbsorb = false;
                        this._rating = 1;
                      }
                      else if (rating <= 2){
                        shouldAbsorb = false;
                        this._rating = 2;
                      }
                      else if (rating <= 3){
                        shouldAbsorb = false;
                        this._rating = 3;
                      }
                      else if (rating <= 4){
                        shouldAbsorb = false;
                        this._rating = 4;
                      }
                      else if (rating <= 5){
                        shouldAbsorb = false;
                        this._rating = 5;
                      }
                    }),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      children: [
                        Center(
                          child: InkWell(
                            child: AbsorbPointer(
                              absorbing: shouldAbsorb,
                              child: GestureDetector(
                                onTap: ()
                                {
                                  //getOrderTotalAmount();
                                  getOrderInfo();
                                  getRating();
                                  getOverallRating();
                                },
                                child: Container(
                                  color: (_rating == 0) ? Colors.grey : Colors.orangeAccent,
                                  width: MediaQuery.of(context).size.width - 40,
                                  height: 50,
                                  child: const Center(
                                    child: Text(
                                      "Rate",
                                      style: TextStyle(color: Colors.white, fontSize: 15.0),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        Container(
                          height: 500,
                          child: TextField(
                            style: TextStyle(
                              fontSize: 15,
                            ),
                            controller: _controllerComment,
                            textAlign: TextAlign.center,
                            textAlignVertical: TextAlignVertical.center,
                            decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.green, width: 2.0),
                                ),
                                border: InputBorder.none,
                                hintText: ("Add Comment(Optional)"),
                                hintStyle: TextStyle(color: Colors.grey.shade500)),
                          ),
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
      ),
    );
  }
}
