import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey = "pk_test_51OwjBW2NV9wXFnZAfvnYYNhHzQg38X6unyuEZi1lT1lBwVtt2FRbXuV0a5hjutkfxdscWm6iED4j3tSmIOxOspNc009GvSGio6";
  Stripe.merchantIdentifier = 'any string works';
  await Stripe.instance.applySettings();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Stripe Payment Gateway'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  Map<String, dynamic>? paymentIntent;

  void makeCardPayment() async {
    try {
      paymentIntent = await createPaymentIntent();

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent!["client_secret"],
          style: ThemeMode.light,
          merchantDisplayName: "Sabir",
          allowsDelayedPaymentMethods: true,
        ),
      );

      displayPaymentSheet();
    } catch (e) {
      print("Problem occurred: $e");
    }
  }

  void displayPaymentSheet() async{
    try{
      await Stripe.instance.presentPaymentSheet();
      print("Done");
    } catch(e){
      print("Failed");
      throw Exception(e.toString());
    }
  }

  createPaymentIntent() async{
    try{
      Map<String,dynamic> body = {
        "amount" : "1000",
        "currency" : "USD",
      };

      http.Response response = await http.post(
        Uri.parse("https://api.stripe.com/v1/payment_intents"),
        body: body,
        headers: {
          "Authorization":"Bearer sk_test_51OwjBW2NV9wXFnZAALOHAg5iQb0qNDjN2lhPJYqpq5J8pqbkcLu9SSqyRA3En0ItDyoV9Zdwf3ox2dV9k4PsoLDt00zpIjcOaL",
          "Content-Type":"application/x-www-form-urlencoded",
        }
      );
      print(response.body);
      return json.decode(response.body);

    } catch(e){
      throw Exception(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        child: TextButton(
          onPressed: () {
            makeCardPayment();
          },
          child: const Text("Payment"),
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
