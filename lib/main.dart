import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:classifier_app/pages/home.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Clasificador',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Home(title: 'Clasificador - GUA'),
    );
  }
}
