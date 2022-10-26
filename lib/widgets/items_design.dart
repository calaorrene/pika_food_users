import 'package:flutter/material.dart';
import 'package:pika_food_cutomer/mainScreens/item_detail_screen.dart';
import 'package:pika_food_cutomer/models/items.dart';


class ItemsDesignWidget extends StatefulWidget
{
  Items? model;
  BuildContext? context;

  ItemsDesignWidget({this.model, this.context});

  @override
  _ItemsDesignWidgetState createState() => _ItemsDesignWidgetState();
}



class _ItemsDesignWidgetState extends State<ItemsDesignWidget> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: ()
      {
        Navigator.push(context, MaterialPageRoute(builder: (c)=> ItemDetailsScreen(model: widget.model)));
      },
      splashColor: Colors.amber,
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Container(
          height: 200,
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              Image.network(
                widget.model!.thumbnailUrl!,
                height: 150.0,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 1.0,),

              Text(
                widget.model!.name.toString()!,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                  fontFamily: "Train",
                ),
              ),

              Text(
                "₱ " + widget.model!.price.toString()!,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 15,
                  fontFamily: "Train",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
