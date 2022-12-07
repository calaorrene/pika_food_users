import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pika_food_cutomer/global/global.dart';
import 'package:pika_food_cutomer/models/UserCart.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:pika_food_cutomer/widgets/progress_bar.dart';
import '../assistantMethods/assistant_methods.dart';
import '../widgets/cart_card.dart';

class MyCartScreen extends StatefulWidget {

  final UserCart? model;
  final BuildContext? context;

  final String? sellerUID;
  final double? price;

  MyCartScreen({this.model, this.context, this.sellerUID, this.price});

  @override
  State<MyCartScreen> createState() => _MyCartScreenState();
}

class _MyCartScreenState extends State<MyCartScreen> {

  String orderId = DateTime.now().millisecondsSinceEpoch.toString();
  String _sellerName = "";
  double _price = 0.0;

  List<String> _userCartList = [];

  Future getAmount() async {
    String totalAmount;
    List<double> totalAmounts = [];

    String quantity;
    List<int> quantities = [];

    List<String> IDs = [];

    double _totalAmount = 0;

    Future getDocs() async {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(sharedPreferences!.getString("uid"))
          .collection("userCart").get();

      for (int i = 0; i < querySnapshot.docs.length; i++) {

        var itemIDs = querySnapshot.docs[i];

        await FirebaseFirestore.instance
            .collection('users')
            .doc(sharedPreferences!.getString('uid'))
            .collection("userCart")
            .doc(itemIDs.id)
            .get().then((snap)
        {
          quantity = snap.data()!["quantity"].toString();
          quantities.add(int.parse(quantity));

          totalAmount = snap.data()!["totalAmount"].toString();
          totalAmounts.add(double.parse(totalAmount));

          IDs.add(itemIDs.id + ":$quantity");

          _totalAmount += totalAmounts[i];
        });
      }

      print(IDs);
      print(quantities);
      print(_totalAmount);

      await sharedPreferences!.setDouble("totalAmount", _totalAmount);
      List<String> userCartList = IDs.toList().cast<String>();
      _userCartList = userCartList;
      await sharedPreferences!.setStringList("myUserCart", userCartList);
    }
    getDocs();
  }

  addOrderDetails() {
    FirebaseFirestore.instance
        .collection("sellers")
        .doc(widget.sellerUID)
        .get().then((snap)
    {
      _sellerName = snap.data()!["sellerName"].toString();

      print(_sellerName);

    }).then((value) {
      writeOrderDetailsForUser({
        "totalAmount": sharedPreferences!.getDouble("totalAmount"),
        "orderBy": sharedPreferences!.getString("uid"),
        "productIDs": _userCartList,
        "paymentDetails": "Cash on Delivery",
        "orderTime": orderId,
        "isSuccess": true,
        "sellerUID": widget.sellerUID,
        "sellerName": _sellerName,
        "status": "preparing",
        "orderId": orderId,
        "comment": "",
        "rate": 0.0,
      });
      writeOrderDetailsForSeller({
        "totalAmount": sharedPreferences!.getDouble("totalAmount"),
        "orderBy": sharedPreferences!.getString("uid"),
        "productIDs": _userCartList,
        "paymentDetails": "Cash on Delivery",
        "orderTime": orderId,
        "isSuccess": true,
        "sellerUID": widget.sellerUID,
        "sellerName": _sellerName,
        "status": "preparing",
        "orderId": orderId,
        "comment": "",
        "rate": 0.0,
      }).whenComplete(() {
        setState(() {
          orderId = "";
          Navigator.pop(context);
          Fluttertoast.showToast(msg: "Congratulations, Order has been placed successfully.");
        });
      });
    });
  }

  Future writeOrderDetailsForUser(Map<String, dynamic> data) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(sharedPreferences!.getString("uid"))
        .collection("orders")
        .doc(orderId)
        .set(data);
  }

  Future writeOrderDetailsForSeller(Map<String, dynamic> data) async {
    await FirebaseFirestore.instance
        .collection("orders")
        .doc(orderId)
        .set(data);
  }

  @override
  void initState() {
    getAmount();
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
                clearCartNow2(context);

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
                //debugPrint("Cart Screen TestID: " +  widget.model!.sellerUID.toString());
                //Navigator.push(context, MaterialPageRoute(builder: (c)=> AddressScreen(totalAmount: totalAmount.toDouble(), sellerUID: widget.sellerUID, sellerName: widget.sellerName,),));
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: EdgeInsets.fromLTRB(10, 10, 0, 20),
        child: Text(
          "Total Price: ₱ " + sharedPreferences!.getDouble('totalAmount').toString(),
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight:  FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

final usersRef = FirebaseFirestore.instance.collection('users')
    .doc(sharedPreferences!.getString('uid'))
    .collection('userCart');

