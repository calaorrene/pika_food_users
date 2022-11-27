import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pika_food_cutomer/assistantMethods/address_changer.dart';
import 'package:pika_food_cutomer/mainScreens/home_screen.dart';
import 'package:pika_food_cutomer/maps/maps.dart';
import 'package:pika_food_cutomer/models/address.dart';
import 'package:provider/provider.dart';

import '../assistantMethods/assistant_methods.dart';
import '../global/global.dart';

class AddressDesign extends StatefulWidget
{
  final Address? model;
  final int? currentIndex;
  final int? value;
  final String? addressID;
  final double? totalAmount;
  final String? sellerUID;
  final String? sellerName;

  AddressDesign({
    this.model,
    this.currentIndex,
    this.value,
    this.addressID,
    this.totalAmount,
    this.sellerUID,
    this.sellerName
  });

  @override
  _AddressDesignState createState() => _AddressDesignState();
}

class _AddressDesignState extends State<AddressDesign>
{
  String orderId = DateTime.now().millisecondsSinceEpoch.toString();
  String _sellerName = "";

  addOrderDetails()
  {
    FirebaseFirestore.instance
        .collection("sellers")
        .doc(widget.sellerUID).get().then((snap)
    {

      _sellerName = snap.data()!["sellerName"].toString();

    }).then((value) {
      writeOrderDetailsForUser({
        "addressID": widget.addressID,
        "totalAmount": widget.totalAmount,
        "orderBy": sharedPreferences!.getString("uid"),
        "productIDs": sharedPreferences!.getStringList("userCart"),
        "paymentDetails": "Cash on Delivery",
        "orderTime": orderId,
        "isSuccess": true,
        "sellerUID": widget.sellerUID,
        "sellerName": _sellerName,
        "status": "preparing",
        "orderId": orderId,
      });

      writeOrderDetailsForSeller({
        "addressID": widget.addressID,
        "totalAmount": widget.totalAmount,
        "orderBy": sharedPreferences!.getString("uid"),
        "productIDs": sharedPreferences!.getStringList("userCart"),
        "paymentDetails": "Cash on Delivery",
        "orderTime": orderId,
        "isSuccess": true,
        "sellerUID": widget.sellerUID,
        "sellerName": _sellerName,
        "status": "preparing",
        "orderId": orderId,
      }).whenComplete((){
        clearCartNow(context);
        setState(() {
          orderId="";
          Navigator.push(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
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
  Widget build(BuildContext context) {
    return InkWell(
      onTap: ()
      {
        //select this address
        Provider.of<AddressChanger>(context, listen: false).displayResult(widget.value);
      },
      child: Card(
        color: Colors.cyan.withOpacity(0.4),
        child: Column(
          children: [
            //address info
            Row(
              children: [
                Radio(
                  groupValue: widget.currentIndex!,
                  value: widget.value!,
                  activeColor: Colors.amber,
                  onChanged: (val)
                  {
                    //provider
                    Provider.of<AddressChanger>(context, listen: false).displayResult(val);
                    print(val);
                  },
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: Table(
                        children: [
                          TableRow(
                            children: [
                              const Text(
                                "Name: ",
                                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                              ),
                              Text(widget.model!.name.toString()),
                            ],
                          ),
                          TableRow(
                            children: [
                              const Text(
                                "Phone Number: ",
                                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                              ),
                              Text(widget.model!.phoneNumber.toString()),
                            ],
                          ),
                          TableRow(
                            children: [
                              const Text(
                                "Flat Number: ",
                                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                              ),
                              Text(widget.model!.flatNumber.toString()),
                            ],
                          ),
                          TableRow(
                            children: [
                              const Text(
                                "City: ",
                                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                              ),
                              Text(widget.model!.city.toString()),
                            ],
                          ),
                          TableRow(
                            children: [
                              const Text(
                                "State: ",
                                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                              ),
                              Text(widget.model!.state.toString()),
                            ],
                          ),
                          TableRow(
                            children: [
                              const Text(
                                "Full Address: ",
                                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                              ),
                              Text(widget.model!.fullAddress.toString()),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            //button
            ElevatedButton(
              child: const Text("Check on Maps"),
              style: ElevatedButton.styleFrom(
                primary: Colors.black54,
              ),
              onPressed: ()
              {
                MapsUtils.openMapWithPosition(widget.model!.lat!, widget.model!.lng!);
                //MapsUtils.openMapWithAddress(widget.model!.fullAddress!);
              },
            ),

            //button
            widget.value == Provider.of<AddressChanger>(context).count 
                ? ElevatedButton(
                      child: const Text("Place Order"),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.green,
                      ),
                      onPressed: ()
                      {
                        addOrderDetails();
                        debugPrint("Cart Screen SellerName: " +  _sellerName.toString());
                        debugPrint("Cart Screen SellerUID: " +  widget.sellerUID.toString());
                      },
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
