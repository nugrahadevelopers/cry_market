import 'package:flutter/material.dart';
import 'package:cry_market/pages/home_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crypto Coin Market',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          elevation: 0,
          leading: IconButton(onPressed: () {}, icon: Icon(Icons.menu)),
        ),
        body: Center(
          child: HomePage(),
        ),
      ),
    );
  }
}
