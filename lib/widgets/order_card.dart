import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pika_food_cutomer/global/global.dart';
import 'package:pika_food_cutomer/mainScreens/order_details_screen.dart';
import 'package:pika_food_cutomer/models/items.dart';

class OrderCard extends StatelessWidget
{
  final int? itemCount;
  final List<DocumentSnapshot>? data;
  final String? orderID;
  final List<String>? seperateQuantitiesList;

  OrderCard({
    this.itemCount,
    this.data,
    this.orderID,
    this.seperateQuantitiesList,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: ()
      {
        Navigator.push(context, MaterialPageRoute(builder: (c)=> OrderDetailsScreen(orderID: orderID)));
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            orderID.toString(),
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontFamily: "Acme",
            ),
          ),
          Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.black12
            ),
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.all(20),
            height: itemCount! * 125,
            child: Stack(
              children: [
                Padding(padding: EdgeInsets.all(10)),
                ListView.builder(
                  itemCount: itemCount,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index)
                  {
                    Items model = Items.fromJson(data![index].data()! as Map<String, dynamic>);
                    return placedOrderDesignWidget(model, context, seperateQuantitiesList![index]);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget placedOrderDesignWidget(Items model, BuildContext context, seperateQuantitiesList)
{
  return Container(
    width: MediaQuery.of(context).size.width,
    height: 110,
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
                      model.name! + "x " + seperateQuantitiesList,
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
        ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: Image.asset("images/preparing.gif", width: 100,),
        ),
      ],
    ),
  );
}
