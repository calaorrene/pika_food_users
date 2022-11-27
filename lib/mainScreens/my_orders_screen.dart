import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pika_food_cutomer/assistantMethods/assistant_methods.dart';
import 'package:pika_food_cutomer/global/global.dart';
import 'package:pika_food_cutomer/widgets/order_card.dart';
import 'package:pika_food_cutomer/widgets/order_card_pickup.dart';
import 'package:pika_food_cutomer/widgets/order_card_rate.dart';
import 'package:pika_food_cutomer/widgets/progress_bar.dart';
import 'package:pika_food_cutomer/widgets/simple_app_bar.dart';


class MyOrdersScreen extends StatefulWidget
{
  @override
  _MyOrdersScreenState createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen>
    with TickerProviderStateMixin
{
  @override
  Widget build(BuildContext context) {

    TabController _tabController = TabController(length: 3, vsync: this);

    return Scaffold(
      appBar: SimpleAppBar(title: "My Orders",),
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            child: Align(
              alignment: Alignment.centerLeft,
              child: TabBar(
                controller: _tabController,
                //isScrollable: true,
                //labelPadding: EdgeInsets.only(left: 20, right: 20),
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.orangeAccent,
                tabs: [
                  Tab(text: "Preparing",),
                  Tab(text: "For Pickup",),
                  Tab(text: "Rate",)
                ],
              ),
            ),
          ),
          Container(
            width: double.maxFinite,
            height: 500,
            child: TabBarView(
              controller: _tabController,
              children: [
                //Preparing
                Container(
                  child: Scaffold(
                    body: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection("users")
                          .doc(sharedPreferences!.getString("uid"))
                          .collection("orders")
                          .where("status", isEqualTo: "preparing")
                          .orderBy("orderTime", descending: true)
                          .snapshots(),
                      builder: (c, snapshot)
                      {
                        return snapshot.hasData
                            ? ListView.builder(
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (c, index)
                          {
                            return FutureBuilder<QuerySnapshot>(
                              future: FirebaseFirestore.instance
                                  .collection("items")
                                  .where("itemID", whereIn: separateOrderItemIDs((snapshot.data!.docs[index].data()! as Map<String, dynamic>) ["productIDs"]))
                                  .where("orderBy", whereIn: (snapshot.data!.docs[index].data()! as Map<String, dynamic>)["uid"])
                                  .orderBy("publishedDate", descending: true)
                                  .get(),
                              builder: (c, snap)
                              {
                                return snap.hasData
                                    ? OrderCard(
                                  itemCount: snap.data!.docs.length,
                                  data: snap.data!.docs,
                                  orderID: snapshot.data!.docs[index].id,
                                  seperateQuantitiesList: separateOrderItemQuantities((snapshot.data!.docs[index].data()! as Map<String, dynamic>)["productIDs"]),
                                )
                                    : Center(child: circularProgress());
                              },
                            );
                          },
                        )
                            : Center(child: circularProgress(),);
                      },
                    ),

                  ),
                ),
                //Pick up
                Container(
                  child: Scaffold(
                    body: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection("users")
                          .doc(sharedPreferences!.getString("uid"))
                          .collection("orders")
                          .where("status", isEqualTo: "pickup")
                          .orderBy("orderTime", descending: true)
                          .snapshots(),
                      builder: (c, snapshot)
                      {
                        return snapshot.hasData
                            ? ListView.builder(
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (c, index)
                          {
                            return FutureBuilder<QuerySnapshot>(
                              future: FirebaseFirestore.instance
                                  .collection("items")
                                  .where("itemID", whereIn: separateOrderItemIDs((snapshot.data!.docs[index].data()! as Map<String, dynamic>) ["productIDs"]))
                                  .where("orderBy", whereIn: (snapshot.data!.docs[index].data()! as Map<String, dynamic>)["uid"])
                                  .orderBy("publishedDate", descending: true)
                                  .get(),
                              builder: (c, snap)
                              {
                                return snap.hasData
                                    ? OrderCardPickup(
                                  itemCount: snap.data!.docs.length,
                                  data: snap.data!.docs,
                                  orderID: snapshot.data!.docs[index].id,
                                  seperateQuantitiesList: separateOrderItemQuantities((snapshot.data!.docs[index].data()! as Map<String, dynamic>)["productIDs"]),
                                )
                                    : Center(child: circularProgress());
                              },
                            );
                          },
                        )
                            : Center(child: circularProgress(),);
                      },
                    ),

                  ),
                ),
                //Rate
                Container(
                  child: Scaffold(
                    body: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection("users")
                          .doc(sharedPreferences!.getString("uid"))
                          .collection("orders")
                          .where("status", isEqualTo: "torate")
                          .orderBy("orderTime", descending: true)
                          .snapshots(),
                      builder: (c, snapshot)
                      {
                        return snapshot.hasData
                            ? ListView.builder(
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (c, index)
                          {
                            return FutureBuilder<QuerySnapshot>(
                              future: FirebaseFirestore.instance
                                  .collection("items")
                                  .where("itemID", whereIn: separateOrderItemIDs((snapshot.data!.docs[index].data()! as Map<String, dynamic>) ["productIDs"]))
                                  .where("orderBy", whereIn: (snapshot.data!.docs[index].data()! as Map<String, dynamic>)["uid"])
                                  .orderBy("publishedDate", descending: true)
                                  .get(),
                              builder: (c, snap)
                              {
                                return snap.hasData
                                    ? OrderCardRate(
                                  itemCount: snap.data!.docs.length,
                                  data: snap.data!.docs,
                                  orderID: snapshot.data!.docs[index].id,
                                  seperateQuantitiesList: separateOrderItemQuantities((snapshot.data!.docs[index].data()! as Map<String, dynamic>)["productIDs"]),
                                )
                                    : Center(child: circularProgress());
                              },
                            );
                          },
                        )
                            : Center(child: circularProgress(),);
                      },
                    ),

                  ),
                )
              ],
            ),
          ),

        ],
      ),
    );
  }
}
