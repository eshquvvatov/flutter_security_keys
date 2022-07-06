import 'package:flutter/material.dart';
import 'package:flutter_config/flutter_config.dart';
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}


class _HomePageState extends State<HomePage> {
  var serverKey ="";
  @override
  void initState() {
    // TODO: implement initState
    serverKey =FlutterConfig.get("SERVER_KEY");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Seceru Key"),

      ),
      body: Center(
        child: Text(serverKey),
      ),
    );
  }
}
