import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pika_food_cutomer/assistantMethods/cart_Item_counter.dart';
import 'package:pika_food_cutomer/global/global.dart';
import 'package:pika_food_cutomer/mainScreens/my_cart_screen.dart';
import 'package:pika_food_cutomer/models/sellers.dart';
import 'package:pika_food_cutomer/splashScreen/splash_screen.dart';
import 'package:pika_food_cutomer/widgets/my_drawer.dart';
import 'package:pika_food_cutomer/widgets/progress_bar.dart';
import 'package:pika_food_cutomer/widgets/sellers_design.dart';
import 'package:provider/provider.dart';

final usersRef = FirebaseFirestore.instance.collection('users')
    .doc(sharedPreferences!.getString('uid'))
    .collection('userCart');

class HomeScreen extends StatefulWidget
{
  final Sellers? model;
  final String? sellerUID;
  const HomeScreen({this.model, this.sellerUID});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
{
  int count = 0;

  restrictBlockeduserFromUsingApp() async  {
    await FirebaseFirestore.instance.collection("users")
        .doc(firebaseAuth.currentUser!.uid)
        .get().then((snapshot)
    {
      if(snapshot.data()!["status"] != "approved")
      {
        Fluttertoast.showToast(msg: "Account has been restrict \n\n Email:customerservice@gmail.com for further assistance");

        firebaseAuth.signOut();
        Navigator.push(context, MaterialPageRoute(builder: (c)=> MySplashScreen()));
      }
    });
  }

  getUsers(){
    usersRef.get().then((QuerySnapshot snapshot) {count = snapshot.docs.length;});
  }

  @override
  void initState() {
    getUsers();
    super.initState();
    restrictBlockeduserFromUsingApp();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
              color: Colors.orangeAccent
          ),
        ),
        title: const Text(
          "Pick a Food",
          style: TextStyle(fontSize: 45, fontFamily: "Signatra"),
        ),
        centerTitle: true,
        automaticallyImplyLeading: true,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart, color: Colors.white,),
                onPressed: ()
                {
                  //send user to cart screen
                  Navigator.push(context, MaterialPageRoute(builder: (c)=> MyCartScreen()));
                },
              ),
              Positioned(
                child: Stack(
                  children: [
                    const Icon(
                      Icons.brightness_1,
                      size: 20.0,
                      color: Colors.redAccent,
                    ),
                    Positioned(
                      top: 3,
                      right: 4,
                      child: Center(
                        child: Consumer<CartItemCounter>(
                          builder: (context, counter, c)
                          {
                            return Text(
                              counter.count.toString(),
                              style: const TextStyle(color: Colors.white, fontSize: 12),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.shopping_cart, color: Colors.white,),
                onPressed: ()
                {
                  //send user to cart screen
                  Navigator.push(context, MaterialPageRoute(builder: (c)=> MyCartScreen()));
                },
              ),
            ],
          ),
        ],
      ),
      drawer: MyDrawer(),
      body: CustomScrollView(
        slivers: [
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("sellers")
                .snapshots(),
            builder: (context, snapshot)
            {
              return !snapshot.hasData
                  ? SliverToBoxAdapter(child: Center(child: circularProgress(),),)
                  : SliverStaggeredGrid.countBuilder(
                      crossAxisCount: 2,
                      staggeredTileBuilder: (c) => StaggeredTile.fit(1),
                      itemBuilder: (context, index)
                      {
                        Sellers sModel = Sellers.fromJson(
                          snapshot.data!.docs[index].data()! as Map<String, dynamic>
                        );
                        //design for display sellers-cafes-restuarents
                        return SellersDesignWidget(
                          model: sModel,
                          context: context,
                        );
                      },
                      itemCount: snapshot.data!.docs.length,
                    );
            },
          ),
        ],
      ),
    );
  }
}
