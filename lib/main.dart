import 'dart:io';

import 'package:eimzo_id_example/scanner.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Eimzo Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('No data'),
              ),
              TextButton(
                style: ButtonStyle(
                    minimumSize: MaterialStateProperty.resolveWith(
                        (states) => Size(156, 40)),
                    backgroundColor: MaterialStateProperty.resolveWith(
                        (states) => Colors.blue)),
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => ScannerPage()));
                },
                child: Text(
                  'Scan',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              TextButton(
                style: ButtonStyle(
                    minimumSize: MaterialStateProperty.resolveWith(
                        (states) => Size(156, 40)),
                    backgroundColor: MaterialStateProperty.resolveWith(
                        (states) => Colors.blue)),
                onPressed: () {
                  _launchURL(
                      '860b8D8C2234AB7BFF228997A3A9356E90A034B82F1AAF0D4FC0391D6DE1B2D13C7ED20CF7A738aa381d');
                  //  check Test case to understand how to generate this ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑
                  //
                  //  https://m.e-imzo.uz/demo2/#
                },
                child: Text(
                  'Deep Link',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ));
  }

  Future<bool> _launchURL(String code) async {
    var _deepLink = 'eimzo://sign?qc=$code';
    return await canLaunch(_deepLink)
        ? await launch(_deepLink)
        : throw 'Could not launch $_deepLink';
  }
}
