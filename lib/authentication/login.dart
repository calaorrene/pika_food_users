import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pika_food_cutomer/global/global.dart';
import 'package:pika_food_cutomer/mainScreens/home_screen.dart';
import 'package:pika_food_cutomer/widgets/custom_text_field.dart';
import 'package:pika_food_cutomer/widgets/error_dialog.dart';
import 'package:pika_food_cutomer/widgets/loading_dialog.dart';

import 'auth_screen.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}



class _LoginScreenState extends State<LoginScreen>
{
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();


  formValidation()
  {
    if(emailController.text.isNotEmpty && passwordController.text.isNotEmpty)
    {
      //login
      loginNow();
    }
    else
    {
      showDialog(
        context: context,
        builder: (c)
        {
          return ErrorDialog(
            message: "Please write email/password.",
          );
        }
      );
    }
  }


  loginNow() async
  {
    showDialog(
        context: context,
        builder: (c)
        {
          return LoadingDialog(
            message: "Checking Credentials",
          );
        }
    );

    User? currentUser;
    await firebaseAuth.signInWithEmailAndPassword(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    ).then((auth){
      currentUser = auth.user!;
    }).catchError((error){
      Navigator.pop(context);
      showDialog(
          context: context,
          builder: (c)
          {
            return ErrorDialog(
              message: error.message.toString(),
            );
          }
      );
    });
    if(currentUser != null)
    {
      readDataAndSetDataLocally(currentUser!);
      //saveUserCart(currentUser!);
      saveUserCart(currentUser!);
      getAmount(currentUser!);
    }
  }

  Future readDataAndSetDataLocally(User currentUser) async
  {
    await FirebaseFirestore.instance.collection("users")
        .doc(currentUser.uid)
        .get()
        .then((snapshot) async {
          if(snapshot.exists)
          {
            if (snapshot.data()!["status"] == "approved")
            {
              await sharedPreferences!.setString("uid", currentUser.uid);
              await sharedPreferences!.setString("email", snapshot.data()!["email"]);
              await sharedPreferences!.setString("name", snapshot.data()!["name"]);
              await sharedPreferences!.setString("photoUrl", snapshot.data()!["photoUrl"]);

              List<String> userCartList = snapshot.data()!["userCart"].cast<String>();
              await sharedPreferences!.setStringList("userCart", userCartList);

              print("Type: " + userCartList.toString());

              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (c)=> const HomeScreen()));
            }
            else
              {
                firebaseAuth.signOut();
                Navigator.pop(context);
                Fluttertoast.showToast(msg: "Account has been restrict \n\n Email:customerservice@gmail.com for further assistance");
              }
          }
          else
          {
            firebaseAuth.signOut();
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (c)=> const AuthScreen()));

            showDialog(
                context: context,
                builder: (c)
                {
                  return ErrorDialog(
                    message: "No record found.",
                  );
                }
            );
          }
        });
  }

  Future saveUserCart1(User currentUser) async
  {
    List<String> IDs = [];

    List<String> totalAmounts = [];

    Future getDocs() async {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .collection("userCart").get();

      for (int i = 0; i < querySnapshot.docs.length; i++) {

        var itemIDs = querySnapshot.docs[i];

        IDs.add(itemIDs.id);

        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .collection("userCart")
            .doc(itemIDs.id)
            .get().then((DocumentSnapshot ds){
          String totalAmount = (ds.data as DocumentSnapshot)['totalAmount'];

          totalAmounts.add(totalAmount);
        });
      }
    }
    getDocs();

    print(totalAmounts);

    List<String> userCartList = IDs.toList().cast<String>();
    await sharedPreferences!.setStringList("myUserCart", userCartList);
  }

  Future saveUserCart(User currentUser) async
  {
    Future getDocs() async {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .collection("userCart").get();

      dynamic docs = querySnapshot.docs;
      var mapData = docs.map((res) => res['itemID']);

      List<String> userCartList = mapData.toList().cast<String>();
      await sharedPreferences!.setStringList("myUserCart", userCartList);

      print("Type 2: " + userCartList.toString());
    }
    getDocs();
  }

  Future getAmount(User currentUser) async {
    List<String> _userCartList = [];
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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.all(15),
              child: Image.asset(
                  "images/icon.png",
                  height: 270,
              ),
            ),
          ),
          Form(
            key: _formKey,
            child: Column(
              children: [
                CustomTextField(
                  data: Icons.email,
                  controller: emailController,
                  hintText: "Email",
                  isObsecre: false,
                ),
                CustomTextField(
                  data: Icons.lock,
                  controller: passwordController,
                  hintText: "Password",
                  isObsecre: true,
                ),
              ],
            ),
          ),
          ElevatedButton(
            child: const Text(
              "Login",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,),
            ),
            style: ElevatedButton.styleFrom(
              primary: Colors.orangeAccent,
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
            ),
            onPressed: ()
            {
              formValidation();
            },
          ),
          const SizedBox(height: 30,),
        ],
      ),
    );
  }
}
