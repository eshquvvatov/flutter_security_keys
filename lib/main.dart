import 'package:flutter/material.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:secur_keys/pages/home_page.dart';
import 'package:secur_keys/pages/my_home_page.dart';
void main()async{
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterConfig.loadEnvVariables();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

