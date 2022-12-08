import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pika_food_cutomer/global/global.dart';
import 'package:pika_food_cutomer/mainScreens/order_details_screen.dart';
import 'package:pika_food_cutomer/models/items.dart';
import 'package:pika_food_cutomer/widgets/progress_bar.dart';

class OrderCard extends StatelessWidget
{
  final List<DocumentSnapshot>? data;
  final List<String>? seperateQuantitiesList;
  final int? itemCount;
  final String? orderID;
  final String? sellerUID;
  late String? sellerName;
  late String? totalAmount;

  OrderCard({
    this.data,
    this.seperateQuantitiesList,
    this.itemCount,
    this.orderID,
    this.sellerUID,
    this.sellerName,
    this.totalAmount,
  });

  @override
  Widget build(BuildContext context) {

    return InkWell(
      onTap: ()
      {
        Navigator.push(context, MaterialPageRoute(builder: (c)=> OrderDetailsScreen(orderID: orderID, sellerUID: sellerUID)));
      },
      child: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection("users")
            .doc(sharedPreferences!.getString("uid"))
            .collection("orders")
            .doc(orderID)
            .get(),
        builder: (c, snapshot)
        {
          Map? dataMap;
          if(snapshot.hasData)
          {
            dataMap = snapshot.data!.data()! as Map<String, dynamic>;
            totalAmount = dataMap["totalAmount"].toString();
            sellerName = dataMap["sellerName"].toString();
          }
          return snapshot.hasData
              ? Container( margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10,),
                Text(
                  sellerName.toString(),
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
                  height: itemCount! * 70,
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
                            child: OrderCardDesignWidget(model, context, seperateQuantitiesList![index]),
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
    );
  }
}

Widget OrderCardDesignWidget(Items model, BuildContext context, seperateQuantitiesList)
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
