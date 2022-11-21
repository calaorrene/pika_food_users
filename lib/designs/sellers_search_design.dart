import 'package:flutter/material.dart';
import 'package:pika_food_cutomer/mainScreens/menus_screen.dart';
import 'package:pika_food_cutomer/models/sellers.dart';


class SellersSearchDesign extends StatefulWidget
{
  Sellers? model;
  BuildContext? context;

  SellersSearchDesign({this.model, this.context});

  @override
  _SellersSearchDesignState createState() => _SellersSearchDesignState();
}



class _SellersSearchDesignState extends State<SellersSearchDesign> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: ()
      {
        Navigator.push(context, MaterialPageRoute(builder: (c)=> MenusScreen(model: widget.model)));
      },

      splashColor: Colors.amber,

      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black12,
            borderRadius: BorderRadius.circular(1),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 2,
                offset: Offset(0, 3), // changes position of shadow
              ),
            ],
          ),
          height: 100,
          width: MediaQuery.of(context).size.width,
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(1.0), bottomLeft: Radius.circular(1.0)), //add border radius
                child: Image.network(
                  widget.model!.sellerAvatarUrl!,
                  height: 100.0,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 5.0,),
              Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 5.0,),
                    Text(
                      widget.model!.sellerName!,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontFamily: "Train",
                      ),
                    ),
                    const SizedBox(height: 5.0,),
                    Text(
                      widget.model!.sellerEmail!,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
